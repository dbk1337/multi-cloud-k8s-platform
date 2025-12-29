# Test Environment Variables for Azure

resource_group_name = "my-aks-rg-test"
location            = "eastus"
cluster_name        = "my-aks-cluster-test"
vnet_cidr           = "10.1.0.0/16"
aks_subnet_cidr     = "10.1.1.0/24"
acr_name            = "demoacrtest12345"
acr_sku             = "Standard"
node_count          = 2
vm_size             = "Standard_DS2_v2"
