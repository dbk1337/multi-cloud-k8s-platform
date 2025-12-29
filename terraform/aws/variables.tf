variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "us-east-1"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
  default     = "my-eks-cluster"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for the private subnet"
  default     = "10.0.2.0/24"
}

variable "node_count" {
  type        = number
  description = "Number of nodes in the EKS cluster"
  default     = 3

  validation {
    condition     = var.node_count > 0
    error_message = "node_count must be greater than 0."
  }
}

variable "node_instance_type" {
  type        = string
  description = "EC2 instance type for EKS nodes"
  default     = "t3.medium"
}

variable "ecr_repository_name" {
  type        = string
  description = "ECR repository name (lowercase, no uppercase letters or special chars except hyphens)"
  default     = "demo-app"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.ecr_repository_name)) && !startswith(var.ecr_repository_name, "-") && !endswith(var.ecr_repository_name, "-")
    error_message = "ecr_repository_name must contain only lowercase letters, numbers, and hyphens, and cannot start or end with a hyphen."
  }
}
