terraform {
    required_version = ">= 1.0"
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 3.0"
        }
    }
}

provider "azurerm" {
    features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
    name     = var.resource_group_name
    location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
    name                = "${var.cluster_name}-vnet"
    address_space       = [var.vnet_cidr]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

# Subnet for AKS
resource "azurerm_subnet" "aks_subnet" {
    name                 = "${var.cluster_name}-subnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [var.aks_subnet_cidr]
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
    name                = var.acr_name
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku                 = var.acr_sku
    admin_enabled       = true
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
    name                = var.cluster_name
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    dns_prefix          = var.cluster_name

    default_node_pool {
        name           = "default"
        node_count     = var.node_count
        vm_size        = var.vm_size
        vnet_subnet_id = azurerm_subnet.aks_subnet.id
    }

    identity {
        type = "SystemAssigned"
    }

    network_profile {
        network_plugin    = "azure"
        load_balancer_sku = "standard"
    }

    depends_on = [azurerm_subnet.aks_subnet]
}

# Role Assignment for AKS to pull from ACR
resource "azurerm_role_assignment" "aks_acr" {
    scope              = azurerm_container_registry.acr.id
    role_definition_name = "AcrPull"
    principal_id       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# Outputs
output "kube_config" {
    value       = azurerm_kubernetes_cluster.aks.kube_config_raw
    sensitive   = true
    description = "Kubernetes cluster config"
}

output "acr_login_server" {
    value       = azurerm_container_registry.acr.login_server
    description = "ACR login server URL"
}