#!/bin/bash
YOUR_COMPANY_NAME='adp' # put your company name in lowercase
LOCATION='westeurope'
RANDOM_ID=$RANDOM
RG_NAME="rg-"$YOUR_COMPANY_NAME
AKS_NAME="aks-"$YOUR_COMPANY_NAME
ACR_NAME="acr"$YOUR_COMPANY_NAME""$RANDOM_ID
KV_NAME="kv"$YOUR_COMPANY_NAME""$RANDOM_ID
IDENTITY_NAME=$YOUR_COMPANY_NAME"-identity"
MIN_NODE_COUNT="2"
MAX_NODE_COUNT="3"
SPN_NAME="spn-labaks"
GREEN="\e[32m"
RED="\e[31m"
ENDCOLOR="\e[0m" 

echo "This script will deploy the prerequisites for the AKS lab"
echo ""

# Create RG
echo "Creating the RG"
az group create -n $RG_NAME -l $LOCATION -o none
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"

# Create ACR
echo "Creating the ACR"
az acr create --resource-group $RG_NAME --name $ACR_NAME --sku Basic --location $LOCATION --admin-enabled true -o none
echo "login:"$ACR_NAME > acrcredentials.txt
PWD=$(az acr credential show --name $ACR_NAME  --resource-group $RG_NAME --query passwords[0].value -o tsv)
URL=$(az acr show --name $ACR_NAME --resource-group $RG_NAME --query loginServer -o tsv)
echo "pwd:"$PWD >> acrcredentials.txt
echo "URL:"$URL >> acrcredentials.txt
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"

# Create AKS
echo "Creating the AKS cluster"
az aks create --name $AKS_NAME --resource-group $RG_NAME --location $LOCATION --enable-cluster-autoscaler --enable-keda --enable-oidc-issuer --enable-workload-identity --enable-addons azure-keyvault-secrets-provider --generate-ssh-keys --min-count 3 --max-count 7 -o none
AKS_OIDC_ISSUER="$(az aks show --resource-group $RG_NAME --name $AKS_NAME --query "oidcIssuerProfile.issuerUrl" -o tsv)"
echo $AKS_OIDC_ISSUER > aksoidc.txt
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"

echo "Attaching the ACR"
az aks update --name $AKS_NAME --resource-group $RG_NAME --attach-acr $ACR_NAME -o none
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"

# Create Keyvault
echo "Create Keyvault"
az keyvault create --location $LOCATION --name $KV_NAME --resource-group $RG_NAME --enable-rbac-authorization false -o none
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"

echo "Add redis-password secret"
az keyvault secret set --vault-name $KV_NAME --name redis-password --value Microsoft01!
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"


az aks get-credentials -n $AKS_NAME -g $RG_NAME --file kubeconfig.txt #we just want a clean extract
az aks get-credentials -n $AKS_NAME -g $RG_NAME --overwrite-existing

# Create namespaces
echo "creating namespaces"
kubectl create ns student1
kubectl create ns student2
kubectl create ns student3
kubectl create ns student4
kubectl create ns student5
kubectl create ns student6
kubectl create ns student7
kubectl create ns student8
kubectl create ns student9
kubectl create ns student10
kubectl create ns student11
kubectl create ns student12
kubectl create ns student13
kubectl create ns student14
kubectl create ns student15
kubectl get ns
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"

# Create an SPN and role assignments
az ad sp create-for-rbac --name $SPN_NAME > spncredentials.txt
SPN_ID=$(az ad sp list --display-name $SPN_NAME  --query "[0].id" -o tsv)

echo "add assignment to ACR"
ACRID=$(az acr show -n $ACR_NAME -g $RG_NAME --query id -o tsv)
az role assignment create --assignee $SPN_ID --role Contributor --scope $ACRID -o none

echo "add assignment to AKS"
AKSID=$(az aks show -n $AKS_NAME -g $RG_NAME --query id -o tsv)
az role assignment create --assignee $SPN_ID --role Contributor --scope $AKSID -o none

echo "add assignment to KV"
KVID=$(az keyvault show -n $KV_NAME -g $RG_NAME --query id -o tsv)
az role assignment create --assignee $SPN_ID --role Contributor --scope $KVID -o none

# prepare workload identity
echo "Prepare workload identity"
az identity create --name $IDENTITY_NAME --resource-group $RG_NAME --location $LOCATION -o none
IDENTITY_ID=$(az ad sp list --display-name $IDENTITY_NAME  --query "[0].id" -o tsv)
USER_ASSIGNED_CLIENT_ID="$(az identity show --resource-group $RG_NAME --name $IDENTITY_NAME --query 'clientId' -o tsv)"
az keyvault set-policy --name $KV_NAME --secret-permissions get --object-id "$IDENTITY_ID" -o none
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"


echo "Prepare federation"
az identity federated-credential create --name fed-identity1 --identity-name $IDENTITY_NAME --resource-group $RG_NAME --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:student1:my-serviceaccount -o none
az identity federated-credential create --name fed-identity2 --identity-name $IDENTITY_NAME --resource-group $RG_NAME --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:student2:my-serviceaccount -o none
az identity federated-credential create --name fed-identity3 --identity-name $IDENTITY_NAME --resource-group $RG_NAME --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:student3:my-serviceaccount -o none
az identity federated-credential create --name fed-identity4 --identity-name $IDENTITY_NAME --resource-group $RG_NAME --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:student4:my-serviceaccount -o none
az identity federated-credential create --name fed-identity5 --identity-name $IDENTITY_NAME --resource-group $RG_NAME --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:student5:my-serviceaccount -o none
az identity federated-credential create --name fed-identity6 --identity-name $IDENTITY_NAME --resource-group $RG_NAME --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:student6:my-serviceaccount -o none
az identity federated-credential create --name fed-identity7 --identity-name $IDENTITY_NAME --resource-group $RG_NAME --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:student7:my-serviceaccount -o none
az identity federated-credential create --name fed-identity8 --identity-name $IDENTITY_NAME --resource-group $RG_NAME --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:student8:my-serviceaccount -o none
az identity federated-credential create --name fed-identity9 --identity-name $IDENTITY_NAME --resource-group $RG_NAME --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:student9:my-serviceaccount -o none
az identity federated-credential create --name fed-identity10 --identity-name $IDENTITY_NAME --resource-group $RG_NAME --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:student10:my-serviceaccount -o none
az identity federated-credential create --name fed-identity11 --identity-name $IDENTITY_NAME --resource-group $RG_NAME --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:student11:my-serviceaccount -o none
az identity federated-credential create --name fed-identity12 --identity-name $IDENTITY_NAME --resource-group $RG_NAME --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:student12:my-serviceaccount -o none
az identity federated-credential create --name fed-identity13 --identity-name $IDENTITY_NAME --resource-group $RG_NAME --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:student13:my-serviceaccount -o none
az identity federated-credential create --name fed-identity14 --identity-name $IDENTITY_NAME --resource-group $RG_NAME --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:student14:my-serviceaccount -o none
az identity federated-credential create --name fed-identity15 --identity-name $IDENTITY_NAME --resource-group $RG_NAME --issuer $AKS_OIDC_ISSUER --subject system:serviceaccount:student15:my-serviceaccount -o none
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"

printf $"${GREEN}\u2714 Credentials for SPN are in spncredentials.txt ${ENDCOLOR}\n\n"
printf $"${GREEN}\u2714 Credentials for Docker Registry are in acrcredentials.txt ${ENDCOLOR}\n\n"
printf $"${GREEN}\u2714 AKS OIDC URL is in aksoidc.txt ${ENDCOLOR}\n\n"

TENANT_ID=$(az identity show --resource-group $RG_NAME --name $IDENTITY_NAME --query tenantId -o tsv)

echo "prepare unique documents for students"
echo "Registry (required for service connection)" > students.txt
echo "-------------------------------------------" >> students.txt
echo "login:"$ACR_NAME >> students.txt
echo "pwd:"$PWD >> students.txt
echo "URL:"$URL >> students.txt

echo "" >> students.txt
echo "Workload identity" >> students.txt
echo "----------------" >> students.txt
echo "User assigned identity:"$USER_ASSIGNED_CLIENT_ID >> students.txt
echo "OIDC Url:"$AKS_OIDC_ISSUER >> students.txt
echo "Tenant ID:"$TENANT_ID >> students.txt

printf $"${GREEN}\u2714 Info required by students are in students.txt ${ENDCOLOR}\n\n"