az configure --defaults location=australiaeast

resourceSuffix=000

registryName="tsgaksacr${resourceSuffix}"
aksName="tsg-aks-${resourceSuffix}"
rgName='tsg-aks-rg'

aksVersion=$(az aks get-versions \
  --query 'orchestrators[-1].orchestratorVersion' \
  --output tsv)

az group create --name $rgName

az acr create \
  --name $registryName \
  --resource-group $rgName \
  --sku Basic


az aks create \
  --name $aksName \
  --resource-group $rgName \
  --enable-addons monitoring \
  --kubernetes-version $aksVersion \
  --generate-ssh-keys


clientId=$(az aks show \
  --name $aksName \
  --resource-group $rgName \
  --query "servicePrincipalProfile.clientId" \
  --output tsv)


acrId=$(az acr show \
  --name $registryName \
  --resource-group $rgName \
  --query "id" \
  --output tsv)


az acr list \
 --resource-group $rgName \
 --query "[].{loginServer: loginServer}" \
 --output table


az role assignment create \
  --assignee $clientId \
  --role acrpull \
  --scope $acrId

  