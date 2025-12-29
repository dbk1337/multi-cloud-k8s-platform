# AKS Cluster Outputs
output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "AKS cluster name"
}

output "aks_cluster_id" {
  value       = azurerm_kubernetes_cluster.aks.id
  description = "AKS cluster resource ID"
}

output "aks_cluster_fqdn" {
  value       = azurerm_kubernetes_cluster.aks.fqdn
  description = "The FQDN of the Azure Kubernetes Service managed cluster"
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
  description = "Kubernetes cluster config raw"
}

output "kube_config_context" {
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.name
  description = "Current context in kubeconfig"
}

output "client_certificate" {
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive   = true
  description = "Client certificate for cluster authentication"
}

output "client_key" {
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
  sensitive   = true
  description = "Client key for cluster authentication"
}

output "cluster_ca_certificate" {
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
  sensitive   = true
  description = "Cluster CA certificate"
}

output "kubernetes_cluster_host" {
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.host
  description = "The Kubernetes cluster server host"
}

# Node Pool Outputs
output "aks_node_pool_id" {
  value       = azurerm_kubernetes_cluster.aks.id
  description = "AKS node pool ID"
}

output "aks_node_pool_node_count" {
  value       = azurerm_kubernetes_cluster.aks.default_node_pool[0].node_count
  description = "Number of nodes in the default node pool"
}

# Resource Group Outputs
output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Name of the resource group"
}

output "resource_group_id" {
  value       = azurerm_resource_group.rg.id
  description = "ID of the resource group"
}

output "location" {
  value       = azurerm_resource_group.rg.location
  description = "Location of the resource group"
}

# Virtual Network Outputs
output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "Virtual network ID"
}

output "vnet_cidr" {
  value       = azurerm_virtual_network.vnet.address_space
  description = "Virtual network address space"
}

output "aks_subnet_id" {
  value       = azurerm_subnet.aks_subnet.id
  description = "AKS subnet ID"
}

# ACR Outputs
output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "The URL that can be used to log into the container registry"
}

output "acr_id" {
  value       = azurerm_container_registry.acr.id
  description = "The ID of the Container Registry"
}

output "acr_name" {
  value       = azurerm_container_registry.acr.name
  description = "The name of the Container Registry"
}

# Kubelet Identity Outputs
output "kubelet_identity_object_id" {
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  description = "Object ID of the Kubelet managed identity"
}

output "kubelet_identity_client_id" {
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
  description = "Client ID of the Kubelet managed identity"
}

# Connection Commands
output "configure_kubectl" {
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${azurerm_kubernetes_cluster.aks.name}"
  description = "Command to configure kubectl"
}

output "acr_login" {
  value       = "az acr login --name ${azurerm_container_registry.acr.name}"
  description = "Command to login to ACR"
}
