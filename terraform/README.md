# Terraform Multi-Cloud Kubernetes Infrastructure

Terraform configuration for provisioning Kubernetes clusters in AWS (EKS) and Azure (AKS).

## Directory structure
```text
terraform/
  aws/                 EKS + VPC + ECR
  azure/               AKS + VNet + ACR
  environments/        tfvars for dev/test/prod
  deploy-aws.sh         Helper script for AWS
  deploy-azure.sh       Helper script for Azure
```

## Prerequisites
- Terraform >= 1.0
- AWS CLI (for EKS) or Azure CLI (for AKS)
- kubectl

## Quickstart (recommended)
```bash
cd terraform

# AWS
./deploy-aws.sh plan dev
./deploy-aws.sh apply dev

# Azure
./deploy-azure.sh plan dev
./deploy-azure.sh apply dev
```

## Manual workflow
AWS:
```bash
cd terraform/aws
terraform init
terraform plan -var-file=../environments/dev/aws.tfvars
terraform apply -var-file=../environments/dev/aws.tfvars
```

Azure:
```bash
cd terraform/azure
terraform init
terraform plan -var-file=../environments/dev/azure.tfvars
terraform apply -var-file=../environments/dev/azure.tfvars
```

## Environment configuration
Copy the templates and adjust for your account:
```bash
cp terraform/environments/example-aws.tfvars terraform/environments/dev/aws.tfvars
cp terraform/environments/example-azure.tfvars terraform/environments/dev/azure.tfvars
```

## Remote state and locking
- AWS uses S3 for state and DynamoDB for state locking.
- Azure uses a Storage Account + Blob container with lease-based locking.
- The deploy scripts can prompt to create missing state resources.

## Notes
- Configure your remote state backend in `terraform/aws/backend.tf` or `terraform/azure/backend.tf`.
- Cluster outputs include kubeconfig helpers and registry endpoints.
- Review costs before applying in production environments.
- Enable ingress controllers with `enable_alb_ingress_controller` (AWS) or `enable_app_gateway_ingress` (Azure).
