terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }

}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "multi-cloud-k8s"
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    }
  }
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_auth.cluster.token
}

# Data source for EKS cluster authentication
data "aws_eks_auth" "cluster" {
  name = aws_eks_cluster.main.name
}
