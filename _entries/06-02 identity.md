---
sectionid: identity
sectionclass: h2
title: Secrets
parent-id: security
---

You will be deploying the Azure Voting App to Azure Kubernetes Service (AKS). This is a simple web app that lets you vote for things and displays the vote totals. You may recognize this app from Microsoft Docs which allows you to vote for "Dogs" or "Cats".

The repo can be found here: [Azure-Samples/azure-voting-app-redis](https://github.com/Azure-Samples/azure-voting-app-redis).

The web application is written in python (front) and this web app uses Redis as the backend database (back). The web app will use credentials to connect to Redis backend.

#### Securing credentials using "Secrets"

In order to deploy the web app and redis in AKS, we need the redis password to be able to connect to redis. You could add it to the YAML file, but that would mean that it would be stored in plain text. So anyone who has access to the YAML file would be able to see the password. Instead, you are going first to use a Kubernetes secret to store the credentials in the cluster.

**Task Hints**

* It's recommended to use kubectl and the `kubectl create secret generic` command to create redis password. Refer to the docs linked in the Resources section, or run `kubectl create secret generic -h` for details

Create secret

{% collapsible %}

```sh
kubectl create secret generic <azure-voting-redis-secret> \
  --from-literal=password=<your_password> -n <your_namespace>
```

Replace azure-voting-redis-secret, your_password by the secret name and redis password of your choice and your_namespace by the namespace where you need to deploy the secret.
You should see an output similar to:

```sh
secret/azure-voting-redis-secret created
```

{% endcollapsible %}

##### Deploy the web app and redis backend

In this section, you will deploy the front web app and the redis backend. Redis password was stored in an AKS secret.

**Task Hints**

* You will use an image from bitnami for Redis backend (mcr.microsoft.com/oss/bitnami), tag 6.0.8.
* You will have to add an env variable named REDIS_PASSWORD that will find the password in AKS secret created before.
* You will use an image from azuredocs for the web app (mcr.microsoft.com/azuredocs/azure-vote-front), tag v1.
* You will have to add 2 env variables. The first, named REDIS_PWD that will find the password in AKS secret created before and the second named REDIS which is the name of your redis backend container.
* Create services to expose your pod. The backend will not be called outside of the cluster. The frontend will be called outside of the cluster but only with an internal IP, refer to [Internal Load Balancer](https://learn.microsoft.com/en-us/azure/aks/internal-lb?tabs=set-service-annotations#create-an-internal-load-balancer)

{% collapsible %}

Create your yaml file deployment.yaml.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-back
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-back
  template:
    metadata:
      labels:
        app: azure-vote-back
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: azure-vote-back
        image: mcr.microsoft.com/oss/bitnami/redis:6.0.8
        env:
        - name: REDIS_PASSWORD
          valueFrom:
            secretKeyRef:
              name: azure-voting-redis-secret
              key: password          
        ports:
        - containerPort: 6379
          name: redis
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-back
spec:
  ports:
  - port: 6379
  selector:
    app: azure-vote-back
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-front
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-front
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  minReadySeconds: 5 
  template:
    metadata:
      labels:
        app: azure-vote-front
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: azure-vote-front
        image: mcr.microsoft.com/azuredocs/azure-vote-front:v1
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 250m
          limits:
            cpu: 500m
        env:
        - name: REDIS
          value: "azure-vote-back"
        - name: REDIS_PWD
          valueFrom:
            secretKeyRef:
              name: azure-voting-redis-secret
              key: password          
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-front
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"  
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: azure-vote-front
```

Apply the deployment:

```sh
kubectl apply -f ./deployment.yaml -n <your_namespace>
```

You should see an output similar to:

```sh
deployment.apps/azure-vote-back created
service/azure-vote-back created
deployment.apps/azure-vote-front created
service/azure-vote-front created
```

{% endcollapsible %}

##### Check that the application is working fine

You will first check front logs to be sure that there is no error connecting to redis backend and then check the application in your browser.

{% collapsible %}

In order to watch logs, find the pod name with the command:

```sh
kubectl get pods -n <your_namespace>
```

You should see an output similar to:

```sh
NAME                                READY   STATUS    RESTARTS   AGE
azure-vote-back-68f656645-pdvxw     1/1     Running   0          17m
azure-vote-front-7df999d7c9-9xvqq   1/1     Running   0          17m
```

Check logs with pod name, it shoud be azure-vote-front-xxx.
If password is incorrect, you should see in logs something like: redis.exceptions.ResponseError: WRONGPASS invalid username-password pair.

```sh
kubectl logs <pod_name> -n <your_namespace>
```

Get the service IP to test the app in your browser:

```sh
kubectl get svc -n <your_namespace>
```

 You should see an output similar to:

```sh
NAME               TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
azure-vote-back    ClusterIP      10.0.194.219   <none>        6379/TCP       30s
azure-vote-front   LoadBalancer   10.0.74.34     10.2.0.24   80:31365/TCP   30s
```

Test your app in your browser: [http://EXTERNAL-IP-FRONT](http://EXTERNAL-IP-FRONT)

{% endcollapsible %}

#### Securely storing secrets

Kubernetes secrets are just base64 encoded strings. Anyone with access to the cluster can decode them and see the actual value. Run the following command to decode the password secret:

```sh
kubectl get secrets <azure-voting-redis-secret> -o jsonpath='{.data.password}' -n <your-namespace> | base64 --decode
```

There are a few ways to store secrets in a more secure manner. One recommended way is to use Azure Key Vault.
So you are going to replace the kubernetes secret by a secret stored in Azure Key Vault and redeploy the application.

##### Delete Kubernetes secret

You will first delete the kubernetes secret created before.

**Task Hints**

* It's recommended to use kubectl and the `kubectl delete secret` command to delete a secret. Refer to the docs linked in the Resources section, or run `kubectl delete secret -h` for details

{% collapsible %}

```sh
kubectl delete secret <azure-voting-redis-secret> -n <your_namespace>
```

Replace azure-voting-redis-secret and your_namespace by your secret's name and your_namespace by the namespace where you created the secret.
You should see an output similar to:

```sh
secret "azure-voting-redis-secret" deleted
```

{% endcollapsible %}

##### Create an Azure Key Vault and add a secret

You will create an Azure Key Vault and add a secret to store redis password.

**Task Hints**

* It's recommended to use az cli  and the `az keyvault create` command to create a Key Vault. Refer to the docs linked in the Resources section, or run `az keyvault create -h` for details.
* It's recommended to use az cli  and the `az keyvault secret` command to add a secret in Key Vault. Refer to the docs linked in the Resources section, or run `az keyvault secret -h` for details.
* The secret should be named redis-password.

{% collapsible %}

Create a Key Vault:

```sh
az keyvault create --location <region> --name <akv_name> --resource-group <rg>
```

Replace region by the same region where AKS is deployed, akv_name and rg by the key vault name and resource group of your choice. The resource group must already exist.

Add a secret named redis-password in Key Vault:

```sh
az keyvault secret set \
  --vault-name <akv_name> \
  --name redis-password \
  --value <redis-password>
```

{% endcollapsible %}

##### Authentication to Azure Key Vault using workload identity

The authentication to the Azure Key Vault will be implemented using workload identity. This will allow the pod to use an Azure user-assigned managed identity to authenticate to the Azure Key Vault.

An Microsoft Entra Workload ID is an identity that an application running on a pod uses that authenticates itself against other Azure services that support it, such as Storage or SQL or Key Vault. It integrates with the native Kubernetes capabilities to federate with external identity providers. In this security model, the AKS cluster acts as token issuer. Microsoft Entra ID then uses OpenID Connect (OIDC) to discover public signing keys and verify the authenticity of the service account token before exchanging it for a Microsoft Entra token.

To do this, you need:

* a user-assigned managed identity, this managed identity must have read access to Azure Key Vault secrets to be able to read redis-password
* a kubernetes service account
* a federated identity credential between the managed identity, service account issuer, and subject

{% collapsible %}

Create a managed identity using the az identity create command

```sh
az identity create --name <user_assigned_identity_name> --resource-group <rg> --location <region>
```

Set an access policy for the managed identity to access the Key Vault secret using the following commands.

```sh
export USER_ASSIGNED_CLIENT_ID="$(az identity show --resource-group <rg> --name <user_assigned_identity_name> --query 'clientId' -otsv)"
echo $USER_ASSIGNED_CLIENT_ID
az keyvault set-policy --name <akv_name> --secret-permissions get --spn "${USER_ASSIGNED_CLIENT_ID}"
```

Create the service account.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: <user-assigned-client-id>
  name: <service-account-name>
  namespace: <your_namespace>
```

Apply the deployment:

```sh
kubectl apply -f ./serviceaccount.yaml -n <your_namespace>
```

You should see an output similar to:

```sh
serviceaccount/votingsa created
```

Get the AKS cluster OIDC Issuer URL using the az aks show command.

```sh
export AKS_OIDC_ISSUER="$(az aks show --resource-group <rg> --name <aks_cluster_name> --query "oidcIssuerProfile.issuerUrl" -o tsv)"
echo $AKS_OIDC_ISSUER
```

Create the federated identity credential between the managed identity, service account issuer, and subject using the az identity federated-credential create command.

```sh
az identity federated-credential create 
    --name <federated_identity_name> 
    --identity-name <user_assigned_identity_name> 
    --resource-group <rg> 
    --issuer ${AKS_OIDC_ISSUER} 
    --subject system:serviceaccount:<service_account_namespace>:<service_account_name>
```

{% endcollapsible %}

##### Secret Store CSI driver

Before creating the secret provider class, you need the tenant id, you can use the following command to find it:

```sh
az identity show \
  --resource-group <rg> \
  --name <user_assigned_identity_name> \
  --query tenantId -o tsv
```

Create a secret provider class and apply the saved yaml file. Refer to [CSI Secret Store Driver](https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver)

{% collapsible %}

```yaml
# This is a SecretProviderClass example using workload identity to access your key vault
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-kv-wi # needs to be unique per namespace
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"       
    clientID: "<USER_ASSIGNED_CLIENT_ID>" # Setting this to use workload identity
    keyvaultName: <akv_name>       # Set to the name of your key vault
    cloudName: ""                         # [OPTIONAL for Azure] if not provided, the Azure environment defaults to AzurePublicCloud
    objects:  |
      array:
        - |
          objectName: redis-password
          objectType: secret              # object types: secret, key, or cert
    tenantId: "<tenant_id>"        # The tenant ID of the key vault
```

{% endcollapsible %}

##### Update the deployment

Update the deployment to get redis secret in key vault using workload identity instead of kubernetes secret. Refer to [CSI Secret Store Driver](https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver).

{% collapsible %}

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-back
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-back
  template:
    metadata:
      labels:
        app: azure-vote-back
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: azure-vote-back
        image: mcr.microsoft.com/oss/bitnami/redis:6.0.8
        ports:
        - containerPort: 6379
          name: redis
        volumeMounts:
        - name: secrets-store
          mountPath: "/mnt/secrets-store"
          readOnly: true
        env:
        - name: REDIS_PASSWORD
          value: /mnt/secrets-store/redis-password
      serviceAccountName: <service-account-name>
      volumes:
        - name: secrets-store
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: azure-kv-wi              
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-back
spec:
  ports:
  - port: 6379
  selector:
    app: azure-vote-back
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-front
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-front
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  minReadySeconds: 5 
  template:
    metadata:
      labels:
        app: azure-vote-front
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: azure-vote-front
        image: mcr.microsoft.com/azuredocs/azure-vote-front:v1
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 250m
          limits:
            cpu: 500m
        volumeMounts:
        - name: secrets-store
          mountPath: "/mnt/secrets-store"
          readOnly: true
        env:
        - name: REDIS
          value: "azure-vote-back"
        - name: REDIS_PWD
          value: /mnt/secrets-store/redis-password
      serviceAccountName: <service-account-name>
      volumes:
        - name: secrets-store
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: azure-kv-wi         
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-front
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"  
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: azure-vote-front
```

{% endcollapsible %}

Test if your application works fine.

##### How to use workload identity in your code?

Microsoft Entra Workload ID works especially well with the Azure Identity client libraries and the Microsoft Authentication Library (MSAL) collection if you're using application registration. Your workload can use any of these libraries to seamlessly authenticate and access Azure cloud resources.

You can find more information in [Microsoft documentation](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview?tabs=dotnet).
* [Azure Identity Client libraries samples](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview?tabs=dotnet#azure-identity-client-libraries)
* [MSAL samples](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview?tabs=dotnet#microsoft-authentication-library-msal)
* [MSAL sample in .net with Azure Key Vault](https://github.com/Azure/azure-workload-identity/tree/main/examples/msal-net/akvdotnet)
* [Tutorial - Use a workload identity with an application on Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/learn/tutorial-kubernetes-workload-identity)

> **Resources**
>
> * <https://kubernetes.io/docs/concepts/configuration/secret/>
> * <https://learn.microsoft.com/en-us/cli/azure/keyvault?view=azure-cli-latest#az-keyvault-create>
> * <https://learn.microsoft.com/en-us/cli/azure/keyvault/secret?view=azure-cli-latest>
> * <https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster>
> * <https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver>
> * <https://learn.microsoft.com/en-us/azure/aks/internal-lb?tabs=set-service-annotations#create-an-internal-load-balancer>
