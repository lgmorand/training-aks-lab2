#!/bin/bash
YOUR_COMPANY_NAME='adp' # put your company name in lowercase
LOCATION='westeurope'
RANDOM_ID=$RANDOM
RG_NAME="rg_"$YOUR_COMPANY_NAME
AKS_NAME="aks-"$YOUR_COMPANY_NAME
ACR_NAME="acr"$YOUR_COMPANY_NAME""$RANDOM_ID
KV_NAME="kv"$YOUR_COMPANY_NAME""$RANDOM_ID
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
echo "creating the ACR"
az acr create --resource-group $RG_NAME --name $ACR_NAME --sku Basic --location $LOCATION --admin-enabled true -o none
echo "login:"$ACR_NAME > acrcredentials.txt
PWD=$(az acr credential show --name $ACR_NAME  --resource-group $RG_NAME --query passwords[0].value -o tsv)
URL=$(az acr show --name $ACR_NAME --resource-group $RG_NAME --query loginServer -o tsv)
echo "pwd:"$PWD >> acrcredentials.txt
echo "URL:"$URL >> acrcredentials.txt
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"

# Create AKS
echo "creating the AKS cluster"
az aks create --name $AKS_NAME --resource-group $RG_NAME --location $LOCATION --enable-cluster-autoscaler --generate-ssh-keys --min-count 3 --max-count 7 -o none
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"

echo "attaching the ACR"
az aks update --name $AKS_NAME --resource-group $RG_NAME --attach-acr $ACR_NAME -o none
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"

# Create Keyvault
echo "create Keyvault"
az keyvault create --location $LOCATION --name $KV_NAME --resource-group $RG_NAME  -o none
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"


az aks get-credentials -n $AKS_NAME -g $RG_NAME --file kubeconfig.txt #we just want a clean extract
az aks get-credentials -n $AKS_NAME -g $RG_NAME

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
az role assignment create --assignee $SPN_ID --role Contributor --scope $ACRID

echo "add assignment to AKS"
AKSID=$(az aks show -n $AKS_NAME -g $RG_NAME --query id -o tsv)
az role assignment create --assignee $SPN_ID --role Contributor --scope $AKSID

echo "add assignment to KV"
KVID=$(az keyvault show -n $KV_NAME -g $RG_NAME --query id -o tsv)
az role assignment create --assignee $SPN_ID --role Contributor --scope $KVID


printf $"${RED}\u2714 Credentials for SPN are in spncredentials.txt ${ENDCOLOR}\n\n"
printf $"${RED}\u2714 Credentials for Docker Registry are in acrcredentials.txt ${ENDCOLOR}\n\n"