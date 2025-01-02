YOUR_COMPANY_NAME='adp'

RG_NAME="rg-"$YOUR_COMPANY_NAME
SPN_NAME="spn-labaks"

echo "delete RG and resources"
az group delete -n $RG_NAME --yes

echo "delete App registration"
SPN_ID=$(az ad sp list --display-name $SPN_NAME  --query "[0].id" -o tsv)
az ad sp delete --id $SPN_ID
