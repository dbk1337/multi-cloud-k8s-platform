# Azure AKS Cluster Module Usage Example
# This file demonstrates how to use the Azure AKS resources as a reusable module
#
# To use as a module, create a main.tf that references it:
#
# module "aks_cluster" {
#   source = "./azure"
#
#   # Required variables
#   resource_group_name = "production-rg"
#   location           = "westus2"
#   cluster_name       = "production-aks"
#   vnet_cidr          = "10.0.0.0/16"
#   aks_subnet_cidr    = "10.0.1.0/24"
#
#   # Optional variables with defaults
#   node_count        = 5
#   vm_size          = "Standard_D4s_v3"
#   acr_name         = "myappacr"
#   environment      = "prod"
# }
#
# Then access outputs:
#
# output "aks_fqdn" {
#   value = module.aks_cluster.aks_cluster_fqdn
# }

# Azure Module Output Usage Example:
#
# After deployment, use these commands to interact with the cluster:
#
# 1. Configure kubectl:
#    az aks get-credentials --resource-group my-aks-rg --name my-aks-cluster
#
# 2. Verify cluster access:
#    kubectl get nodes
#    kubectl get pods --all-namespaces
#
# 3. Login to ACR:
#    az acr login --name demoacr12345
#
# 4. Push images to ACR:
#    az acr build --registry demoacr12345 --image my-app:latest .
#
# 5. Deploy to AKS:
#    kubectl apply -f deployment.yaml
#
# 6. Scale AKS cluster:
#    az aks scale --resource-group my-aks-rg --name my-aks-cluster --node-count 5
