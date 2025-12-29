# Development Environment Variables for Azure

resource_group_name = "my-aks-rg-dev"
location            = "eastus"
cluster_name        = "my-aks-cluster-dev"
vnet_cidr           = "10.0.0.0/16"
aks_subnet_cidr     = "10.0.1.0/24"
acr_name            = "demoacrdev12345"
acr_sku             = "Basic"
node_count          = 1
vm_size             = "Standard_B2s"
