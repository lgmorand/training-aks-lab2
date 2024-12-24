#!/bin/bash
YOUR_COMPANY_NAME='adp' # put your company name in lowercase
LOCATION='westeurope'
RANDOM_ID=$RANDOM
RG_NAME="rg_"$YOUR_COMPANY_NAME
AKS_NAME="aks_"$YOUR_COMPANY_NAME
ACR_NAME="acr"$YOUR_COMPANY_NAME""$RANDOM_ID
MIN_NODE_COUNT="2"
MAX_NODE_COUNT="3"
GREEN="\e[32m"
ENDCOLOR="\e[0m" 


echo "This script will deploy the prerequisites for the AKS lab"
echo ""

# Create RG
echo "Creating the RG"
az group create -n $RG_NAME -l $LOCATION -o none
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"

# Create ACR
echo "creating the ACR"
az acr create --resource-group $RG_NAME --name $ACR_NAME --sku Basic --location $LOCATION -o none
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"

# Create AKS
echo "creating the AKS cluster"
az aks create --name $AKS_NAME --resource-group $RG_NAME --location $LOCATION --enable-cluster-autoscaler --generate-ssh-keys --min-count 3 --max-count 7 -o none
printf $"${GREEN}\u2714 Success ${ENDCOLOR}\n\n"

echo "attaching the ACR"
az aks update --name $AKS_NAME --resource-group $RG_NAME --attach-acr $ACR_NAME -o none
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