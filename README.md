# Multi-Cloud Kubernetes Platform (AWS EKS + Azure AKS)

Production-style reference platform that provisions Kubernetes in AWS and Azure with Terraform and deploys a simple backend + frontend via Helm. This repo is designed as a portfolio-grade example for DevOps and platform engineering work.

## What this repo delivers
- Multi-cloud IaC with Terraform for EKS and AKS
- IRSA and cloud-native ingress controllers (ALB and Application Gateway)
- Containerized backend (Spring Boot) and frontend (React + Nginx)
- Helm chart for repeatable Kubernetes deployment
- GitHub Actions for build, OIDC auth, quality checks, and Terraform plan
- IaC linting and security scans with tflint, checkov, and tfsec

## Repository layout
```text
.
  .github/
    workflows/
  app/                 Application source code
    backend/           Spring Boot API
    frontend/          React UI
  helm/                Helm chart for Kubernetes deployment
    myapp/
  terraform/           AWS and Azure infrastructure
    aws/
    azure/
    environments/
```

## Quickstart (local)
Backend:
```bash
cd app/backend
mvn clean package
mvn spring-boot:run
```

Frontend (uses CRA proxy to the backend):
```bash
cd app/frontend
npm install
npm start
```

## Build container images
```bash
docker build -t myapp-backend:local app/backend
docker build -t myapp-frontend:local app/frontend
```

## Helm deploy
```bash
helm upgrade --install demo-app helm/myapp \
  -f helm/myapp/values.yaml \
  --namespace default \
  --create-namespace
```

Cloud-specific values:
```bash
# AWS
helm upgrade --install demo-app helm/myapp -f helm/myapp/values-eks.yaml

# Azure
helm upgrade --install demo-app helm/myapp -f helm/myapp/values-azure.yaml
```

The frontend calls `/api/hello` on the same host. If you need a different API host, build the frontend image with `REACT_APP_BACKEND_URL`:
```bash
docker build -t myapp-frontend:local \
  --build-arg REACT_APP_BACKEND_URL=https://api.example.com \
  app/frontend
```

## Terraform usage
See `terraform/README.md` for full setup steps and environment examples. Helper scripts are available:
```bash
cd terraform
./deploy-aws.sh plan dev
./deploy-azure.sh plan dev
```

## How to run (copy/paste)
AWS (EKS):
```bash
cd terraform/aws
terraform init
terraform plan -var-file=../environments/dev/aws.tfvars
terraform apply -var-file=../environments/dev/aws.tfvars
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster-dev
helm upgrade --install demo-app ../../helm/myapp \
  -f ../../helm/myapp/values-eks.yaml \
  --namespace default \
  --create-namespace
```

Azure (AKS):
```bash
cd terraform/azure
terraform init
terraform plan -var-file=../environments/dev/azure.tfvars
terraform apply -var-file=../environments/dev/azure.tfvars
az aks get-credentials --resource-group my-aks-rg-dev --name my-aks-cluster-dev
helm upgrade --install demo-app ../../helm/myapp \
  -f ../../helm/myapp/values-azure.yaml \
  --namespace default \
  --create-namespace
```

## CI/CD
GitHub Actions workflows are in `.github/workflows`:
- Image build and push for backend/frontend
- Quality checks (Trivy, tfsec, CodeQL, SonarCloud)
- Terraform plan for AWS and Azure

## CI OIDC auth (optional)
To enable remote state access in CI using OIDC, set these GitHub secrets:
- `AWS_ROLE_ARN`
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

## License
MIT. See `LICENSE`.
