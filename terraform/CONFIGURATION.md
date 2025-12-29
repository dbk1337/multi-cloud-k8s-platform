# Terraform Configuration Guide

Complete documentation of the multi-cloud Kubernetes infrastructure provisioning.

## 📂 File Organization

### AWS Configuration (`aws/`)

#### `provider.tf`
- **Purpose**: Defines AWS and Kubernetes providers
- **Key Features**:
  - AWS provider with dynamic region configuration
  - Kubernetes provider with EKS cluster authentication
  - Default tags applied to all resources
  - Automatic kubeconfig credential handling via `aws_eks_auth` data source

#### `backend.tf`
- **Purpose**: Remote state management
- **Configuration**:
  - S3 bucket for state storage with encryption
  - DynamoDB table for state locking
  - Prevents concurrent modifications
  - Enables team collaboration

#### `main.tf`
- **Resources Provisioned**:
  - AWS VPC with configurable CIDR
  - Internet Gateway for public connectivity
  - Public and private subnets in different availability zones
  - Route tables and associations
  - Security groups with ingress/egress rules
  - IAM roles for EKS cluster and worker nodes
  - AWS EKS cluster with control plane
  - EKS node group with auto-scaling
  - ECR repository for container images
  - Availability zones data source

#### `variables.tf`
- **Input Variables**:
  - `aws_region`: Region for deployment
  - `cluster_name`: Name of EKS cluster
  - `vpc_cidr`, `public_subnet_cidr`, `private_subnet_cidr`: Network configuration
  - `node_count`, `node_instance_type`: Node pool sizing
  - `ecr_repository_name`: Container registry
  - `environment`: Environment tag (dev/test/prod)
  - `enable_logging`, `enabled_cluster_log_types`: Logging configuration

#### `outputs.tf`
- **Exported Values**:
  - Cluster endpoint and version information
  - VPC and subnet IDs
  - Security group information
  - ECR repository details
  - IAM role ARNs
  - kubectl configuration command

### Azure Configuration (`azure/`)

#### `provider.tf`
- **Purpose**: Defines Azure and Kubernetes providers
- **Key Features**:
  - Azure provider with feature flags
  - Kubernetes provider with AKS authentication
  - Automatic certificate and key handling from kubeconfig
  - Soft-delete purge configuration for Key Vaults

#### `backend.tf`
- **Purpose**: Remote state management
- **Configuration**:
  - Azure Storage container for state files
  - Automatic state locking via storage
  - Team-friendly remote state

#### `main.tf`
- **Resources Provisioned**:
  - Azure Resource Group for resource isolation
  - Virtual Network with configurable address space
  - Subnet for AKS nodes
  - Azure Container Registry (ACR)
  - AKS cluster with default node pool
  - Network configuration with Azure CNI
  - RBAC with system-assigned identity
  - Role assignment for ACR pull access

#### `variables.tf`
- **Input Variables**:
  - `resource_group_name`, `location`: Azure region configuration
  - `cluster_name`: AKS cluster name
  - `vnet_cidr`, `aks_subnet_cidr`: Network configuration
  - `node_count`, `vm_size`: Node pool sizing
  - `acr_name`, `acr_sku`: Container registry configuration
  - `environment`: Environment tag
  - `kubernetes_version`: K8s version specification
  - `enable_log_analytics`, `addon_*`: Feature flags

#### `outputs.tf`
- **Exported Values**:
  - Cluster FQDN and kubeconfig
  - Authentication certificates and keys
  - Resource group information
  - Virtual network details
  - ACR login server
  - Kubelet identity information
  - kubectl configuration command

### Environment Configurations (`environments/`)

#### Structure
```
environments/
├── dev/
│   ├── aws.tfvars          # Dev environment for AWS
│   └── azure.tfvars        # Dev environment for Azure
├── test/
│   ├── aws.tfvars          # Test environment for AWS
│   └── azure.tfvars        # Test environment for Azure
├── prod/
│   ├── aws.tfvars          # Production for AWS
│   └── azure.tfvars        # Production for Azure
├── example-aws.tfvars      # Template for AWS configuration
└── example-azure.tfvars    # Template for Azure configuration
```

#### Purpose
- Separate configuration per environment
- Different resource sizes and scaling for dev/test/prod
- Easy switching between environments
- Version-controlled environment-specific settings

## 🔑 Key Configuration Elements

### AWS Backend Configuration

```hcl
backend "s3" {
  bucket         = "terraform-state-bucket"      # State storage
  key            = "aws/terraform.tfstate"       # State file path
  region         = "us-east-1"                   # S3 region
  encrypt        = true                          # Enable encryption
  dynamodb_table = "terraform-state-lock"        # State locking
}
```

**Setup Requirements**:
1. Create S3 bucket with versioning and encryption
2. Create DynamoDB table for locking
3. Ensure IAM permissions for state access

### Azure Backend Configuration

```hcl
backend "azurerm" {
  resource_group_name  = "rg-terraform-state"
  storage_account_name = "tfstate"
  container_name       = "tfstate"
  key                  = "azure/terraform.tfstate"
}
```

**Setup Requirements**:
1. Create resource group for state
2. Create storage account with blob storage
3. Create container in storage account
4. Ensure Azure CLI authentication

### AWS Provider Configuration

```hcl
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "multi-cloud-k8s"
      ManagedBy   = "Terraform"
    }
  }
}
```

**Features**:
- Dynamic region configuration
- Automatic tag application
- Consistent resource labeling

### Azure Provider Configuration

```hcl
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
```

**Features**:
- Feature flag management
- Key Vault configuration
- Resource behavior customization

## 🔄 Workflow Examples

### Deploy AWS EKS in Dev Environment

```bash
cd terraform/aws
terraform init
terraform plan -var-file=../environments/dev/aws.tfvars
terraform apply -var-file=../environments/dev/aws.tfvars
```

### Deploy Azure AKS in Production

```bash
cd terraform/azure
terraform init
terraform plan -var-file=../environments/prod/azure.tfvars
terraform apply -var-file=../environments/prod/azure.tfvars
```

### Scale AWS Cluster

```bash
cd terraform/aws
terraform apply \
  -var-file=../environments/prod/aws.tfvars \
  -var="node_count=5"
```

### Update Azure ACR SKU

```bash
cd terraform/azure
terraform apply \
  -var-file=../environments/prod/azure.tfvars \
  -var="acr_sku=Premium"
```

## 🔐 Security Considerations

### AWS Security Features
- **VPC Isolation**: Public and private subnets separate concerns
- **IAM Roles**: Least privilege access for cluster and nodes
- **Security Groups**: Restricted ingress/egress rules
- **ECR Scanning**: Automatic image vulnerability scanning
- **State Encryption**: S3 server-side encryption
- **State Locking**: DynamoDB prevents concurrent modifications

### Azure Security Features
- **Resource Groups**: Logical isolation
- **Virtual Networks**: Network segmentation
- **Managed Identity**: RBAC without secrets
- **ACR Integration**: Kubelet identity pulls images securely
- **Storage Encryption**: Built-in at rest encryption
- **Network Policies**: Pod-to-pod communication control

## 📊 Variables and Defaults

### AWS Defaults
| Variable | Default | Use Case |
|----------|---------|----------|
| `aws_region` | us-east-1 | Primary region |
| `vpc_cidr` | 10.0.0.0/16 | Address space |
| `node_instance_type` | t3.medium | Cost-effective dev |
| `node_count` | 3 | Minimum HA |

### Azure Defaults
| Variable | Default | Use Case |
|----------|---------|----------|
| `location` | eastus | US East region |
| `vnet_cidr` | 10.0.0.0/16 | Address space |
| `vm_size` | Standard_DS2_v2 | General purpose |
| `kubernetes_version` | 1.28 | Latest stable |

## 🚀 Module Usage

Both AWS and Azure configurations can be used as Terraform modules:

```hcl
module "eks_cluster" {
  source = "./aws"
  
  cluster_name = var.cluster_name
  aws_region   = var.aws_region
  # ... additional variables
}

module "aks_cluster" {
  source = "./azure"
  
  resource_group_name = var.resource_group_name
  location           = var.location
  # ... additional variables
}
```

## 📤 Output Usage

### AWS Outputs
```bash
# Get cluster endpoint
terraform output eks_cluster_endpoint

# Configure kubectl
$(terraform output -raw configure_kubectl)

# Get ECR repository
terraform output ecr_repository_url
```

### Azure Outputs
```bash
# Get cluster FQDN
terraform output aks_cluster_fqdn

# Configure kubectl
$(terraform output -raw configure_kubectl)

# Get ACR login server
terraform output acr_login_server
```

## 🔄 State Management

### Backup Remote State

```bash
# AWS
aws s3 cp s3://terraform-state-bucket/aws/terraform.tfstate ./backup/

# Azure
az storage blob download \
  --account-name tfstate \
  --container-name tfstate \
  --name terraform.tfstate \
  --file ./backup/terraform.tfstate
```

### Migration Between Backends

```bash
# Pull state
terraform state pull > backup.tfstate

# Reinitialize with new backend
terraform init -migrate-state

# Verify state
terraform state list
```

## 🧪 Testing and Validation

### Validate Terraform Syntax
```bash
terraform validate
```

### Format Code
```bash
terraform fmt -recursive
```

### Plan Before Applying
```bash
terraform plan -var-file=../environments/dev/aws.tfvars
```

### Check Resources
```bash
# List all managed resources
terraform state list

# Show resource details
terraform state show 'aws_eks_cluster.main'
```

## 📋 Checklist for Deployment

- [ ] Remote state backend configured and tested
- [ ] Provider credentials configured locally
- [ ] Variables files customized for environment
- [ ] Network CIDR blocks validated (no conflicts)
- [ ] Container registry names are globally unique
- [ ] IAM/RBAC roles reviewed and acceptable
- [ ] Logging enabled for compliance/monitoring
- [ ] Terraform plan reviewed before apply
- [ ] Post-deployment: kubectl access verified
- [ ] Post-deployment: Nodes in ready state
- [ ] Documentation updated with specific values

## 🆘 Troubleshooting Guide

### Common Issues

**State Lock Timeout**
```bash
# Force unlock (use carefully)
terraform force-unlock <LOCK_ID>
```

**Provider Authentication Failed**
```bash
# AWS
aws sts get-caller-identity

# Azure
az account show
```

**Node Group Creation Failed**
```bash
# Check IAM role policies
aws iam list-attached-role-policies --role-name <role-name>
```

**ACR Pull Failed**
```bash
# Check role assignment
az role assignment list --scope <acr-id>
```

## 📚 Reference

- Complete AWS setup in `aws/USAGE.md`
- Complete Azure setup in `azure/USAGE.md`
- Main README with comprehensive guide in `README.md`
- Example configurations in `environments/example-*.tfvars`
