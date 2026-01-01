# AWS Environment Configuration Example
# Copy and modify for your specific needs

aws_region           = "us-east-1"
cluster_name         = "my-eks-cluster"
environment          = "dev"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidr   = "10.0.1.0/24"
private_subnet_cidr  = "10.0.2.0/24"
node_count           = 3
node_instance_type   = "t3.medium"
ecr_repository_name  = "demo-app"
enable_logging       = true
enabled_cluster_log_types = ["api", "audit"]
enable_alb_ingress_controller = true
