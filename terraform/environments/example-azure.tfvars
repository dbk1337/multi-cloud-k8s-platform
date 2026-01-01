# Azure Environment Configuration Example
# Copy and modify for your specific needs

resource_group_name = "my-aks-rg"
location            = "eastus"
cluster_name        = "my-aks-cluster"
environment         = "dev"
vnet_cidr           = "10.0.0.0/16"
aks_subnet_cidr     = "10.0.1.0/24"
node_count          = 3
vm_size             = "Standard_DS2_v2"
acr_name            = "demoacr12345"
acr_sku             = "Basic"
kubernetes_version  = "1.28"
enable_log_analytics = true
addon_http_application_routing_enabled = false
addon_azure_policy_enabled = false
enable_app_gateway_ingress = false
app_gateway_subnet_cidr = "10.0.2.0/24"
