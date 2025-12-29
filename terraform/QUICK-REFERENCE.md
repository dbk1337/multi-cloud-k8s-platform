# Terraform Quick Reference

Fast reference guide for common Terraform operations in this multi-cloud setup.

## 🚀 Quick Start Commands

### AWS EKS Deployment

```bash
# Using helper script (recommended)
cd terraform
chmod +x deploy-aws.sh
./deploy-aws.sh plan dev
./deploy-aws.sh apply dev

# Or manual Terraform
cd terraform/aws
terraform init
terraform plan -var-file=../environments/dev/aws.tfvars
terraform apply -var-file=../environments/dev/aws.tfvars
```

### Azure AKS Deployment

```bash
# Using helper script (recommended)
cd terraform
chmod +x deploy-azure.sh
./deploy-azure.sh plan dev
./deploy-azure.sh apply dev

# Or manual Terraform
cd terraform/azure
terraform init
terraform plan -var-file=../environments/dev/azure.tfvars
terraform apply -var-file=../environments/dev/azure.tfvars
```

## 📋 Common Operations

### Plan Changes
```bash
# AWS
./deploy-aws.sh plan [environment]
# Azure
./deploy-azure.sh plan [environment]
```

### Apply Changes
```bash
# AWS
./deploy-aws.sh apply [environment]
# Azure
./deploy-azure.sh apply [environment]
```

### Scale Cluster (AWS)
```bash
cd terraform/aws
terraform apply -var-file=../environments/prod/aws.tfvars -var="node_count=5"
```

### Scale Cluster (Azure)
```bash
cd terraform/azure
terraform apply -var-file=../environments/prod/azure.tfvars -var="node_count=5"
```

### View Outputs
```bash
# AWS
terraform -chdir=terraform/aws output

# Azure
terraform -chdir=terraform/azure output
```

### Get Specific Output
```bash
# AWS - EKS endpoint
terraform -chdir=terraform/aws output -raw eks_cluster_endpoint

# Azure - AKS FQDN
terraform -chdir=terraform/azure output -raw aks_cluster_fqdn
```

### Configure kubectl
```bash
# AWS
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

# Azure
az aks get-credentials --resource-group my-aks-rg --name my-aks-cluster
```

### Verify Cluster Access
```bash
kubectl get nodes
kubectl get pods --all-namespaces
kubectl cluster-info
```

## 🔄 State Management

### View Current State
```bash
cd terraform/aws  # or azure
terraform state list
terraform state show 'resource.name'
```

### Backup State
```bash
# AWS
aws s3 cp s3://terraform-state-bucket/aws/terraform.tfstate ./backup.tfstate

# Azure
az storage blob download --account-name tfstate --container-name tfstate \
  --name terraform.tfstate --file ./backup.tfstate
```

### Pull Local State Copy
```bash
cd terraform/aws  # or azure
terraform state pull > local.tfstate
```

### Force Unlock (if state is locked)
```bash
terraform force-unlock <LOCK_ID>
```

## 📊 Information Retrieval

### Get Cluster Information (AWS)
```bash
# Cluster status
aws eks describe-cluster --name my-eks-cluster

# Node groups
aws eks list-nodegroups --cluster-name my-eks-cluster

# Node details
aws ec2 describe-instances --filters "Name=tag:aws:eks:cluster-name,Values=my-eks-cluster"
```

### Get Cluster Information (Azure)
```bash
# Cluster status
az aks show --name my-aks-cluster --resource-group my-aks-rg

# Node pools
az aks nodepool list --cluster-name my-aks-cluster --resource-group my-aks-rg

# Nodes
kubectl get nodes -o wide
```

### Container Registry

#### AWS ECR
```bash
# List repositories
aws ecr describe-repositories

# Get login token
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Push image
docker tag myapp:latest <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/demo-app:latest
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/demo-app:latest
```

#### Azure ACR
```bash
# Login to registry
az acr login --name demoacr12345

# List repositories
az acr repository list --name demoacr12345

# Push image
az acr build --registry demoacr12345 --image my-app:latest .
```

## ✅ Validation Commands

### Validate Syntax
```bash
cd terraform/aws  # or azure
terraform validate
```

### Format Check
```bash
terraform fmt -check -recursive
```

### Format and Fix
```bash
terraform fmt -recursive
```

### Security Check (AWS)
```bash
# Check security group rules
aws ec2 describe-security-groups --filters "Name=tag:Name,Values=my-eks-cluster-eks-sg"
```

### Validate Variables
```bash
# Check variables file syntax
terraform validate -var-file=../environments/dev/aws.tfvars
```

## 🗑️ Cleanup Operations

### Remove Deployment (Dev Environment)
```bash
./deploy-aws.sh destroy dev
./deploy-azure.sh destroy dev
```

### Manual Destruction
```bash
cd terraform/aws
terraform destroy -var-file=../environments/dev/aws.tfvars

cd ../azure
terraform destroy -var-file=../environments/dev/azure.tfvars
```

### Remove Local Terraform Files
```bash
cd terraform/aws  # or azure
rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f terraform.tfstate*
```

### Prune Unused AWS Resources
```bash
# Note: Be careful with this - only untagged resources
aws ec2 describe-instances --filters "Name=instance-state-name,Values=stopped" \
  --query "Reservations[].Instances[].InstanceId" --output text | \
  xargs -I {} aws ec2 terminate-instances --instance-ids {}
```

## 🔐 Credentials and Access

### Configure AWS Credentials
```bash
# Interactive setup
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID=<your-key>
export AWS_SECRET_ACCESS_KEY=<your-secret>
export AWS_REGION=us-east-1

# Or use profile
export AWS_PROFILE=production
```

### Configure Azure Credentials
```bash
# Interactive login
az login

# Login with specific subscription
az login --subscription <SUBSCRIPTION_ID>

# Set default subscription
az account set --subscription <SUBSCRIPTION_ID>

# View current account
az account show
```

## 📱 Environment Variables

### AWS
```bash
export AWS_REGION=us-east-1
export AWS_PROFILE=default
```

### Azure
```bash
export AZURE_SUBSCRIPTION_ID=<subscription-id>
export AZURE_TENANT_ID=<tenant-id>
```

### Terraform
```bash
export TF_LOG=DEBUG              # Enable debug logging
export TF_LOG_PATH=terraform.log # Log to file
export TF_INPUT=false            # No interactive prompts
export TF_VAR_node_count=5       # Override variable value
```

## 🔗 Variable Overrides

### Override Single Variable
```bash
terraform apply -var="node_count=5"
```

### Override Multiple Variables
```bash
terraform apply \
  -var="node_count=5" \
  -var="environment=prod" \
  -var="node_instance_type=t3.large"
```

### Use Different Variables File
```bash
terraform apply -var-file=../environments/prod/aws.tfvars
```

## 📈 Upgrade Kubernetes Version

### AWS EKS
```bash
# Plan upgrade
terraform plan -var-file=../environments/prod/aws.tfvars -var="eks_kubernetes_version=1.29"

# Apply upgrade (clusters upgrade first, then nodes)
terraform apply -var-file=../environments/prod/aws.tfvars -var="eks_kubernetes_version=1.29"
```

### Azure AKS
```bash
# Plan upgrade
terraform plan -var-file=../environments/prod/azure.tfvars -var="kubernetes_version=1.29"

# Apply upgrade
terraform apply -var-file=../environments/prod/azure.tfvars -var="kubernetes_version=1.29"
```

## 🐛 Troubleshooting

### Check Terraform Logs
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Run your command
terraform apply ...

# View logs
cat terraform.log
```

### Validate IAM Permissions
```bash
# AWS
aws sts get-caller-identity
aws ec2 describe-instances

# Azure
az account show
az group list
```

### Check State Consistency
```bash
terraform refresh
```

### Diagnose Provider Issues
```bash
terraform providers
terraform version
```

### Get Help
```bash
terraform help
terraform help apply
terraform help plan
```

## 📞 Getting More Help

- **Main Guide**: `terraform/README.md`
- **Configuration Details**: `terraform/CONFIGURATION.md`
- **AWS Specifics**: `terraform/aws/USAGE.md`
- **Azure Specifics**: `terraform/azure/USAGE.md`
- **What Was Added**: `terraform/ADDITIONS.md`

## 💡 Pro Tips

1. **Always plan first**: `terraform plan` before `terraform apply`
2. **Use environments**: Keep dev/test/prod in separate tfvars files
3. **Version lock**: Pin provider versions in provider.tf
4. **Tag everything**: Use consistent tagging for resource tracking
5. **Backup state**: Regularly backup remote state files
6. **Review outputs**: Check terraform outputs for important values
7. **Use modules**: For complex setups, create reusable modules
8. **Automate**: Use the deploy-*.sh scripts for consistency
9. **Monitor costs**: Set up billing alerts in AWS/Azure
10. **Document changes**: Keep a log of environment changes

## ⏱️ Typical Deployment Times

- **AWS EKS**: 15-20 minutes for first deployment
- **Azure AKS**: 10-15 minutes for first deployment
- **Updates**: 5-10 minutes depending on changes
- **Scaling**: 5-15 minutes depending on node count

## 📊 Resource Counts

- **AWS EKS Setup**: 20+ resources
- **Azure AKS Setup**: 8+ resources
- **Both Cloud Setup**: 30+ total resources

---

**Last Updated**: 2024
**Version**: 1.0
