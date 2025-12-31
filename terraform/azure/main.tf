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
    admin_enabled       = false
}

# Optional Log Analytics workspace for cluster monitoring
resource "azurerm_log_analytics_workspace" "aks" {
    count               = var.enable_log_analytics ? 1 : 0
    name                = "${var.cluster_name}-logs"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku                 = "PerGB2018"
    retention_in_days   = 30
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
    name                = var.cluster_name
    kubernetes_version  = var.kubernetes_version
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    dns_prefix          = var.cluster_name

    api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges

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
        network_policy    = "azure"
        load_balancer_sku = "standard"
    }

    addon_profile {
        http_application_routing {
            enabled = var.addon_http_application_routing_enabled
        }

        azure_policy {
            enabled = var.addon_azure_policy_enabled
        }

        oms_agent {
            enabled                    = var.enable_log_analytics
            log_analytics_workspace_id = var.enable_log_analytics ? azurerm_log_analytics_workspace.aks[0].id : null
        }
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
