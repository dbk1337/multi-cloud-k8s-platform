# Terraform Multi-Cloud Kubernetes Infrastructure

Complete Terraform configuration for provisioning and managing Kubernetes clusters across AWS and Azure cloud providers.

## 📋 Overview

This Terraform setup provides:
- **AWS EKS**: Elastic Kubernetes Service with full VPC, networking, IAM, and ECR integration
- **Azure AKS**: Azure Kubernetes Service with Virtual Networks, subnets, and Azure Container Registry
- **Remote State Management**: S3 backend for AWS, Azure Storage for Azure
- **Provider Configuration**: Pre-configured providers with Kubernetes integration
- **Comprehensive Outputs**: All necessary cluster information and connection commands
- **Environment Management**: Dev, Test, and Production configurations

## 🏗️ Project Structure

```
terraform/
├── aws/                          # AWS EKS Configuration
│   ├── provider.tf              # AWS provider & Kubernetes provider setup
│   ├── backend.tf               # S3 remote state configuration
│   ├── main.tf                  # VPC, Networking, EKS Cluster, ECR
│   ├── variables.tf             # Input variables
│   ├── outputs.tf               # Output values
│   └── USAGE.md                 # AWS-specific usage guide
├── azure/                        # Azure AKS Configuration
│   ├── provider.tf              # Azure provider & Kubernetes provider setup
│   ├── backend.tf               # Azure Storage remote state configuration
│   ├── main.tf                  # Resource Group, VNet, AKS Cluster, ACR
│   ├── variables.tf             # Input variables
│   ├── outputs.tf               # Output values
│   └── USAGE.md                 # Azure-specific usage guide
├── environments/                # Environment-specific configurations
│   ├── dev/
│   │   ├── aws.tfvars
│   │   └── azure.tfvars
│   ├── test/
│   │   ├── aws.tfvars
│   │   └── azure.tfvars
│   ├── prod/
│   │   ├── aws.tfvars
│   │   └── azure.tfvars
│   ├── example-aws.tfvars       # AWS configuration template
│   └── example-azure.tfvars     # Azure configuration template
└── README.md                    # This file
```

## 🚀 Prerequisites

### Global Requirements
- **Terraform**: >= 1.0
- **kubectl**: Latest stable version
- **Git**: For version control

### AWS Requirements
- AWS Account with appropriate IAM permissions
- AWS CLI configured with credentials
- S3 bucket for remote state (create manually or use script)
- DynamoDB table for state locking (optional but recommended)

### Azure Requirements
- Azure Subscription with appropriate permissions
- Azure CLI configured with credentials
- Storage account for remote state (create manually or use script)
- Azure identity provider configured

## 🔧 AWS Setup

### 1. Create Remote State Backend

```bash
# Create S3 bucket for state
aws s3api create-bucket \
  --bucket terraform-state-bucket \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket terraform-state-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

### 2. Configure AWS Provider

```bash
cd terraform/aws
export AWS_REGION=us-east-1
export AWS_PROFILE=default  # or your specific profile
```

### 3. Initialize and Deploy

```bash
# Initialize Terraform (downloads providers)
terraform init

# Plan the deployment
terraform plan -var-file=../environments/dev/aws.tfvars

# Apply the configuration
terraform apply -var-file=../environments/dev/aws.tfvars
```

### 4. Configure kubectl

```bash
# Get cluster credentials
aws eks update-kubeconfig \
  --region us-east-1 \
  --name my-eks-cluster

# Verify connection
kubectl get nodes
```

## 🔧 Azure Setup

### 1. Create Remote State Backend

```bash
# Create resource group
az group create \
  --name rg-terraform-state \
  --location eastus

# Create storage account
az storage account create \
  --resource-group rg-terraform-state \
  --name tfstate \
  --sku Standard_LRS \
  --encryption-services blob

# Create blob container
az storage container create \
  --name tfstate \
  --account-name tfstate

# Get storage account key (needed for Azure CLI)
az storage account keys list \
  --resource-group rg-terraform-state \
  --account-name tfstate
```

### 2. Configure Azure Provider

```bash
cd terraform/azure

# Login to Azure
az login

# Set default subscription
az account set --subscription <SUBSCRIPTION_ID>
```

### 3. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan -var-file=../environments/dev/azure.tfvars

# Apply the configuration
terraform apply -var-file=../environments/dev/azure.tfvars
```

### 4. Configure kubectl

```bash
# Get cluster credentials
az aks get-credentials \
  --resource-group my-aks-rg \
  --name my-aks-cluster

# Verify connection
kubectl get nodes
```

## 📝 AWS Configuration Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | us-east-1 | AWS region for resources |
| `cluster_name` | string | my-eks-cluster | EKS cluster name |
| `environment` | string | dev | Environment (dev/test/prod) |
| `vpc_cidr` | string | 10.0.0.0/16 | VPC CIDR block |
| `public_subnet_cidr` | string | 10.0.1.0/24 | Public subnet CIDR |
| `private_subnet_cidr` | string | 10.0.2.0/24 | Private subnet CIDR |
| `node_count` | number | 3 | Number of worker nodes |
| `node_instance_type` | string | t3.medium | EC2 instance type |
| `ecr_repository_name` | string | demo-app | ECR repository name |
| `enable_logging` | bool | true | Enable EKS logging |
| `enabled_cluster_log_types` | list | [api, audit] | Log types to enable |

## 📝 Azure Configuration Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `resource_group_name` | string | my-aks-rg | Resource group name |
| `location` | string | eastus | Azure region |
| `cluster_name` | string | my-aks-cluster | AKS cluster name |
| `environment` | string | dev | Environment (dev/test/prod) |
| `vnet_cidr` | string | 10.0.0.0/16 | Virtual network CIDR |
| `aks_subnet_cidr` | string | 10.0.1.0/24 | AKS subnet CIDR |
| `node_count` | number | 3 | Number of worker nodes |
| `vm_size` | string | Standard_DS2_v2 | VM instance type |
| `acr_name` | string | demoacr12345 | Container registry name |
| `kubernetes_version` | string | 1.28 | Kubernetes version |
| `enable_log_analytics` | bool | true | Enable Log Analytics |

## 📤 AWS Outputs

- `eks_cluster_name`: EKS cluster name
- `eks_cluster_endpoint`: Kubernetes API endpoint
- `eks_cluster_version`: Kubernetes version
- `ecr_repository_url`: ECR repository URL
- `vpc_id`: VPC resource ID
- `configure_kubectl`: kubectl configuration command

## 📤 Azure Outputs

- `aks_cluster_name`: AKS cluster name
- `aks_cluster_fqdn`: Cluster fully qualified domain name
- `acr_login_server`: ACR login server
- `kube_config`: Raw kubeconfig (sensitive)
- `configure_kubectl`: kubectl configuration command
- `resource_group_name`: Resource group name

## 📦 Using as a Module

### AWS Module Usage

```hcl
module "eks" {
  source = "./aws"

  cluster_name        = "prod-eks"
  aws_region          = "us-west-2"
  vpc_cidr            = "10.0.0.0/16"
  node_count          = 5
  node_instance_type  = "t3.large"
  ecr_repository_name = "my-app"
  environment         = "prod"
}

output "eks_endpoint" {
  value = module.eks.eks_cluster_endpoint
}
```

### Azure Module Usage

```hcl
module "aks" {
  source = "./azure"

  resource_group_name = "prod-rg"
  location           = "westus2"
  cluster_name       = "prod-aks"
  vnet_cidr          = "10.0.0.0/16"
  node_count         = 5
  vm_size            = "Standard_D4s_v3"
  acr_name           = "prodacr"
  environment        = "prod"
}

output "aks_fqdn" {
  value = module.aks.aks_cluster_fqdn
}
```

## 🔒 Security Best Practices

### AWS
- ✅ VPC with public and private subnets
- ✅ Security groups with restricted ingress rules
- ✅ IAM roles with least privilege principles
- ✅ ECR image scanning enabled
- ✅ Remote state encryption with S3
- ✅ State locking with DynamoDB
- ✅ Private API endpoint for control plane

### Azure
- ✅ Resource group isolation
- ✅ Network policies for pod-to-pod communication
- ✅ RBAC with managed identities
- ✅ ACR authentication through Kubelet identity
- ✅ Storage account encryption for state
- ✅ Azure Policy integration (optional)

## 🛠️ Common Operations

### Scale Cluster (AWS)
```bash
terraform apply \
  -var-file=../environments/prod/aws.tfvars \
  -var="node_count=5"
```

### Scale Cluster (Azure)
```bash
terraform apply \
  -var-file=../environments/prod/azure.tfvars \
  -var="node_count=5"
```

### View Cluster Outputs
```bash
# AWS
terraform output -json

# Azure
terraform output -json
```

### Destroy Infrastructure
```bash
# AWS (with confirmation)
terraform destroy \
  -var-file=../environments/dev/aws.tfvars

# Azure (with confirmation)
terraform destroy \
  -var-file=../environments/dev/azure.tfvars
```

## 📊 Cost Estimation

### AWS EKS
- EKS Control Plane: $0.10/hour (~$73/month)
- EC2 Instances: ~$40-100/month per t3.medium node
- NAT Gateway: ~$32/month
- Data Transfer: Variable

### Azure AKS
- AKS Control Plane: Free
- VM Instances: ~$30-80/month per Standard_DS2_v2 node
- Data Transfer: Variable

## 🆘 Troubleshooting

### AWS Issues
```bash
# Check cluster status
aws eks describe-cluster --name my-eks-cluster --region us-east-1

# View control plane logs
aws logs describe-log-groups --log-group-name-prefix /aws/eks/

# Get detailed error information
terraform apply -var-file=../environments/dev/aws.tfvars -verbose
```

### Azure Issues
```bash
# Check cluster status
az aks show --resource-group my-aks-rg --name my-aks-cluster

# View AKS diagnostics
az aks run-command invoke -g my-aks-rg -n my-aks-cluster \
  -c "cat /var/log/syslog"

# Get detailed error information
terraform apply -var-file=../environments/dev/azure.tfvars -verbose
```

## 📚 Additional Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 📄 License

This infrastructure code is provided as-is for educational and production use.

## 🤝 Contributing

To contribute improvements:
1. Test changes in a dev environment
2. Validate with `terraform validate`
3. Format with `terraform fmt`
4. Document changes in relevant files
5. Submit pull request with description

## ⚠️ Important Notes

- **State Files**: Keep Terraform state secure and never commit to version control
- **Credentials**: Use AWS profiles and Azure CLI authentication, never hardcode credentials
- **Resource Naming**: Ensure globally unique names for AWS ECR and Azure ACR
- **Networking**: Review CIDR blocks to prevent conflicts with other infrastructure
- **Cost**: Monitor cloud provider console for unexpected costs
- **Backups**: Consider cluster backup solutions for production environments
