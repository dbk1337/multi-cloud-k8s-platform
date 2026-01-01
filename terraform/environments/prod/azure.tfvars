# Production Environment Variables for Azure

resource_group_name = "my-aks-rg-prod"
location            = "eastus"
cluster_name        = "my-aks-cluster-prod"
vnet_cidr           = "10.2.0.0/16"
aks_subnet_cidr     = "10.2.1.0/24"
acr_name            = "demoacrprod12345"
acr_sku             = "Premium"
node_count          = 3
vm_size             = "Standard_DS3_v2"
