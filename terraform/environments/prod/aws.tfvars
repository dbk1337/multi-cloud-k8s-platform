# Production Environment Variables for AWS

aws_region             = "us-east-1"
cluster_name           = "my-eks-cluster-prod"
vpc_cidr               = "10.2.0.0/16"
public_subnet_cidr     = "10.2.1.0/24"
private_subnet_cidr    = "10.2.2.0/24"
node_count             = 3
node_instance_type     = "t3.medium"
ecr_repository_name    = "demo-app-prod"
