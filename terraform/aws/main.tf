# Terraform AWS Provider Configuration

# VPC
resource "aws_vpc" "main" {
    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Name = "${var.cluster_name}-vpc"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.cluster_name}-igw"
    }
}

# Public Subnet
resource "aws_subnet" "public" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = var.public_subnet_cidr
    availability_zone       = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.cluster_name}-public-subnet"
    }
}

# Private Subnet for EKS
resource "aws_subnet" "private" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = var.private_subnet_cidr
    availability_zone = data.aws_availability_zones.available.names[1]

    tags = {
        Name = "${var.cluster_name}-private-subnet"
    }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block      = "0.0.0.0/0"
        gateway_id      = aws_internet_gateway.main.id
    }

    tags = {
        Name = "${var.cluster_name}-public-rt"
    }
}

# Route Table Association
resource "aws_route_table_association" "public" {
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

# Security Group for EKS
resource "aws_security_group" "eks" {
    name   = "${var.cluster_name}-eks-sg"
    vpc_id = aws_vpc.main.id

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.cluster_name}-eks-sg"
    }
}

# Security Group Rule for EKS
resource "aws_security_group_rule" "eks_ingress" {
    type              = "ingress"
    from_port         = 0
    to_port           = 65535
    protocol          = "tcp"
    cidr_blocks       = [var.vpc_cidr]
    security_group_id = aws_security_group.eks.id
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
    name = "${var.cluster_name}-eks-cluster-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = aws_iam_role.eks_cluster_role.name
}

# IAM Role for EKS Node Group
resource "aws_iam_role" "eks_node_role" {
    name = "${var.cluster_name}-eks-node-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role       = aws_iam_role.eks_node_role.name
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
    name     = var.cluster_name
    role_arn = aws_iam_role.eks_cluster_role.arn

    vpc_config {
        subnet_ids              = [aws_subnet.public.id, aws_subnet.private.id]
        security_group_ids      = [aws_security_group.eks.id]
        endpoint_private_access = true
        endpoint_public_access  = true
    }

    enabled_cluster_log_types = var.enable_logging ? var.enabled_cluster_log_types : []

    depends_on = [
        aws_iam_role_policy_attachment.eks_cluster_policy
    ]

    tags = {
        Name = var.cluster_name
    }
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
    cluster_name    = aws_eks_cluster.main.name
    node_group_name = "${var.cluster_name}-node-group"
    node_role_arn   = aws_iam_role.eks_node_role.arn
    subnet_ids      = [aws_subnet.private.id]
    instance_types  = [var.node_instance_type]

    scaling_config {
        desired_size = var.node_count
        max_size     = var.node_count + 2
        min_size     = 1
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks_worker_node_policy,
        aws_iam_role_policy_attachment.eks_cni_policy,
        aws_iam_role_policy_attachment.eks_container_registry_policy,
    ]

    tags = {
        Name = "${var.cluster_name}-node-group"
    }
}

# ECR Repository
resource "aws_ecr_repository" "main" {
    name                 = var.ecr_repository_name
    image_tag_mutability = "MUTABLE"
    force_delete         = false

    image_scanning_configuration {
        scan_on_push = true
    }

    tags = {
        Name = var.ecr_repository_name
    }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
    state = "available"
}

# NAT resources to allow private subnets egress without exposing nodes
resource "aws_eip" "nat" {
    domain = "vpc"

    tags = {
        Name = "${var.cluster_name}-nat-eip"
    }
}

resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.public.id

    depends_on = [aws_internet_gateway.main]

    tags = {
        Name = "${var.cluster_name}-nat"
    }
}

# Private route table to send internet-bound traffic through NAT
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main.id
    }

    tags = {
        Name = "${var.cluster_name}-private-rt"
    }
}

resource "aws_route_table_association" "private" {
    subnet_id      = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}

# OIDC provider for IRSA
data "tls_certificate" "eks_oidc" {
    url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
    url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}

# AWS Load Balancer Controller (ALB Ingress)
resource "aws_iam_policy" "alb_controller" {
    count       = var.enable_alb_ingress_controller ? 1 : 0
    name        = "${var.cluster_name}-alb-controller"
    description = "IAM policy for AWS Load Balancer Controller"
    policy      = file("${path.module}/alb-iam-policy.json")
}

resource "aws_iam_role" "alb_controller" {
    count = var.enable_alb_ingress_controller ? 1 : 0
    name  = "${var.cluster_name}-alb-controller"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Federated = aws_iam_openid_connect_provider.eks.arn
                }
                Action = "sts:AssumeRoleWithWebIdentity"
                Condition = {
                    StringEquals = {
                        "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
                        "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:${var.alb_controller_namespace}:${var.alb_controller_service_account_name}"
                    }
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
    count      = var.enable_alb_ingress_controller ? 1 : 0
    role       = aws_iam_role.alb_controller[0].name
    policy_arn = aws_iam_policy.alb_controller[0].arn
}

resource "kubernetes_service_account" "alb_controller" {
    count = var.enable_alb_ingress_controller ? 1 : 0

    metadata {
        name      = var.alb_controller_service_account_name
        namespace = var.alb_controller_namespace
        labels = {
            "app.kubernetes.io/name"       = "aws-load-balancer-controller"
            "app.kubernetes.io/managed-by" = "Terraform"
        }
        annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller[0].arn
        }
    }

    depends_on = [aws_eks_node_group.main]
}

locals {
    alb_controller_values = {
        clusterName = aws_eks_cluster.main.name
        region      = var.aws_region
        vpcId       = aws_vpc.main.id
        serviceAccount = {
            create = false
            name   = var.alb_controller_service_account_name
        }
    }
}

resource "helm_release" "alb_controller" {
    count            = var.enable_alb_ingress_controller ? 1 : 0
    name             = "aws-load-balancer-controller"
    repository       = "https://aws.github.io/eks-charts"
    chart            = "aws-load-balancer-controller"
    version          = var.alb_controller_chart_version
    namespace        = var.alb_controller_namespace
    create_namespace = false

    values = [yamlencode(local.alb_controller_values)]

    depends_on = [kubernetes_service_account.alb_controller]
}
