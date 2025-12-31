# Multi-Cloud Kubernetes Infrastructure with Terraform and GitHub Actions (AWS & Azure)

## Overview
This project demonstrates a **production-ready, multi-cloud Kubernetes platform** deployed to **AWS and Azure** using **Terraform** for Infrastructure as Code (IaC) and **GitHub Actions** for CI/CD automation.

The same containerized application is deployed to **Amazon EKS** and **Azure AKS**, showcasing:
- Cloud-agnostic Kubernetes architecture
- Reusable and scalable Terraform modules
- Secure CI/CD pipelines
- Modern DevOps and Platform Engineering best practices

This project is designed to reflect **real enterprise-grade cloud environments** and is suitable as a professional portfolio for DevOps / Cloud Engineering roles and freelance platforms such as Upwork.

---

## Architecture Summary

### Application
- Containerized web application (Docker)
- Kubernetes-native deployment
- Health checks and readiness probes
- Stateless design for horizontal scaling

### Kubernetes Platforms
**AWS**
- Amazon EKS
- Managed Node Groups
- AWS Application Load Balancer Controller
- IAM Roles for Service Accounts (IRSA)

**Azure**
- Azure Kubernetes Service (AKS)
- System and user node pools
- Azure Application Gateway Ingress Controller
- Azure Managed Identities

### CI/CD
- GitHub Actions
- OIDC authentication (no static credentials)
- Automated validation, security scanning, and deployment to Kubernetes

---

## High-Level Architecture Diagram

GitHub Actions
|
v
Docker Build & Push
|
v
Terraform Apply
|    |
EKS AKS
|   |
Ingress Ingress
|           |
K8s App K8s App
|           |
Postgres Postgres

---

## Repository Structure

```text
.
├── app/                         # Application source code
│   ├── backend/
│   └── frontend/
terraform/
├── modules/
│   ├── network/
│   ├── eks/
│   ├── aks/
│   └── iam/
├── aws/
│   ├── main.tf        # calls network + eks
│   ├── backend.tf
│   ├── providers.tf
│   └── outputs.tf
├── azure/
│   ├── main.tf        # calls network + aks
│   ├── backend.tf
│   ├── providers.tf
│   └── outputs.tf
└── environments/
    ├── dev.tfvars
    └── prod.tfvars
├── .github/
│   └── workflows/
│       ├── terraform-ci.yml
│       ├── terraform-cd.yml
│       ├── app-build.yml
│       └── k8s-deploy.yml
└── README.md

### Infrastructure as Code (Terraform)
## Kubernetes Infrastructure

# AWS (EKS)
    - VPC with public and private subnets
    - EKS cluster
    - Managed node groups
    - IAM Roles for Service Accounts (IRSA)
    - ALB Ingress Controller

# Azure (AKS)
    - Virtual Network with subnets
    - AKS cluster
    - Multiple node pools
    - Azure Managed Identities
    - Application Gateway Ingress

## Terraform Best Practices Used
    - Modular architecture
    - Provider aliasing for AWS and Azure
    - Remote state with locking
    - Environment separation (dev, prod)
    - Secure defaults (private networking, encryption)
    - Explicit dependency management

### CI/CD Pipelines (GitHub Actions)

Terraform CI (Pull Requests)

terraform fmt

terraform validate

terraform plan

tflint

checkov (security and compliance scanning)