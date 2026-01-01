# EKS Cluster Outputs
output "eks_cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "EKS cluster name"
}

output "eks_cluster_arn" {
  value       = aws_eks_cluster.main.arn
  description = "ARN of the EKS cluster"
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "Endpoint for EKS control plane"
}

output "eks_cluster_version" {
  value       = aws_eks_cluster.main.version
  description = "The Kubernetes server version"
}

output "eks_cluster_status" {
  value       = aws_eks_cluster.main.status
  description = "Status of the EKS cluster (CREATING, ACTIVE, DELETING, FAILED, UPDATING)"
}

output "eks_cluster_certificate_authority" {
  value       = aws_eks_cluster.main.certificate_authority[0].data
  description = "Base64 encoded certificate data required to communicate with the cluster"
  sensitive   = true
}

# Node Group Outputs
output "eks_node_group_id" {
  value       = aws_eks_node_group.main.id
  description = "EKS node group ID"
}

output "eks_node_group_arn" {
  value       = aws_eks_node_group.main.arn
  description = "ARN of the EKS node group"
}

output "eks_node_group_status" {
  value       = aws_eks_node_group.main.status
  description = "Status of the EKS node group"
}

# VPC Outputs
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "VPC CIDR block"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "Public subnet ID"
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "Private subnet ID"
}

# Security Group Outputs
output "eks_security_group_id" {
  value       = aws_security_group.eks.id
  description = "Security group ID for EKS cluster"
}

# ECR Outputs
output "ecr_repository_url" {
  value       = aws_ecr_repository.main.repository_url
  description = "ECR repository URL"
}

output "ecr_repository_arn" {
  value       = aws_ecr_repository.main.arn
  description = "ARN of the ECR repository"
}

output "ecr_registry_id" {
  value       = aws_ecr_repository.main.registry_id
  description = "The registry ID where the repository was created"
}

# IAM Outputs
output "eks_cluster_role_arn" {
  value       = aws_iam_role.eks_cluster_role.arn
  description = "ARN of the EKS cluster IAM role"
}

output "eks_node_role_arn" {
  value       = aws_iam_role.eks_node_role.arn
  description = "ARN of the EKS node IAM role"
}

# Kubeconfig Data
output "configure_kubectl" {
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
  description = "Command to configure kubectl"
}

# IRSA / OIDC Outputs
output "eks_oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.eks.arn
  description = "IAM OIDC provider ARN for the EKS cluster"
}

# ALB Controller Outputs
output "alb_controller_role_arn" {
  value       = try(aws_iam_role.alb_controller[0].arn, null)
  description = "IAM role ARN for AWS Load Balancer Controller"
}

output "alb_controller_service_account" {
  value       = try(kubernetes_service_account.alb_controller[0].metadata[0].name, null)
  description = "Service account name used by AWS Load Balancer Controller"
}

output "alb_controller_namespace" {
  value       = var.alb_controller_namespace
  description = "Namespace where AWS Load Balancer Controller is deployed"
}
