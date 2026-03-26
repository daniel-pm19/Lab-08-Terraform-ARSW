resource_group_name  = "rg-tfstate-lab8"
container_name       = "tfstate"
key                  = "lab8/terraform.tfstate"

SUFFIX=$RANDOM
LOCATION=eastus
RG=resource_group_name
STO=sttfstate${SUFFIX}
CONTAINER=container_name

az group create -n $RG -1 $LOCATION
az storage account create -g $RG -n $STO -l $LOCATION --sku Standard_LRS --encryption-services blob
az storage container create --name $CONTAINER --account-name $STO