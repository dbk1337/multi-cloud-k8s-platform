# AWS EKS Cluster Module Usage Example
# This file demonstrates how to use the AWS EKS resources as a reusable module
#
# To use as a module, create a main.tf that references it:
#
# module "eks_cluster" {
#   source = "./aws"
#
#   # Required variables
#   cluster_name         = "production-eks"
#   vpc_cidr             = "10.0.0.0/16"
#   public_subnet_cidr   = "10.0.1.0/24"
#   private_subnet_cidr  = "10.0.2.0/24"
#
#   # Optional variables with defaults
#   aws_region           = "us-west-2"
#   node_count           = 5
#   node_instance_type   = "t3.large"
#   environment          = "prod"
#   ecr_repository_name  = "my-app"
# }
#
# Then access outputs:
#
# output "eks_endpoint" {
#   value = module.eks_cluster.eks_cluster_endpoint
# }

# AWS Module Output Usage Example:
# 
# After deployment, use these commands to interact with the cluster:
#
# 1. Configure kubectl:
#    aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster
#
# 2. Verify cluster access:
#    kubectl get nodes
#    kubectl get pods --all-namespaces
#
# 3. Push images to ECR:
#    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account>.dkr.ecr.us-east-1.amazonaws.com
#    docker tag my-app:latest <account>.dkr.ecr.us-east-1.amazonaws.com/demo-app:latest
#    docker push <account>.dkr.ecr.us-east-1.amazonaws.com/demo-app:latest
#
# 4. Deploy to EKS:
#    kubectl apply -f deployment.yaml
