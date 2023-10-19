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
Replace <azure-voting-redis-secret>, <your_password> by the secret name and redis password of your choice and <your_namespace> by the namespace where you need to deploy the secret.
You should see an output similar to:

```sh
secret/azure-voting-redis-secret created
```

{% endcollapsible %}

##### Deploy the web app and redis backend

path to images in harbor + nginx config?
In this section, you will deploy the front web app and the redis backend. Redis password was stored in an AKS secret.

You will use an image from bitnami for Redis backend (mcr.microsoft.com/oss/bitnami), tag 6.0.8. You will have to add an env variable named REDIS_PASSWORD that will find the password in AKS secret created before.
You will use an image from azuredocs for the web app (mcr.microsoft.com/azuredocs/azure-vote-front), tag v1. You will have to add 2 env variables. The first, named REDIS_PWD that will find the password in AKS secret created before and the second named REDIS which is the name of your redis backend container.

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

**** a remplacer avec nginx ******* Get the service IP to test the app in your browser:

```sh
kubectl get svc -n <your_namespace>
```

**** a remplacer avec nginx ******* You should see an output similar to:

```sh
NAME               TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
azure-vote-back    ClusterIP      10.0.194.219   <none>        6379/TCP       30s
azure-vote-front   LoadBalancer   10.0.74.34     4.208.29.24   80:31365/TCP   30s
```

Test your app in your browser: http://<EXTERNAL-IP>

{% endcollapsible %}

#### Securely storing secrets

Kubernetes secrets are just base64 encoded strings. Anyone with access to the cluster can decode them and see the actual value. Run the following command to decode the password secret:

```sh
kubectl get secrets <azure-voting-redis-secret> -o jsonpath='{.data.password}' | base64 --decode
```

There are a few ways to store secrets in a more secure manner. One way is to use Azure Key Vault. So you are going to delete first the kubernetes secret, create a secret in an Azure Key vault already provisionned for you and then use this secret.


> **Resources**
>
> * <https://kubernetes.io/docs/concepts/configuration/secret/>

