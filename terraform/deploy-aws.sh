#!/bin/bash
# AWS EKS Deployment Helper Script
# Usage: ./deploy-aws.sh [init|plan|apply|destroy] [environment]

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
COMMAND=${1:-plan}
ENVIRONMENT=${2:-dev}
AWS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/aws"
TERRAFORM_VARS="../environments/${ENVIRONMENT}/aws.tfvars"

# Validation functions
validate_environment() {
    if [[ ! "$ENVIRONMENT" =~ ^(dev|test|prod)$ ]]; then
        echo -e "${RED}Invalid environment: $ENVIRONMENT${NC}"
        echo "Must be one of: dev, test, prod"
        exit 1
    fi
}

validate_aws_credentials() {
    if ! aws sts get-caller-identity > /dev/null 2>&1; then
        echo -e "${RED}AWS credentials not configured${NC}"
        echo "Run: aws configure"
        exit 1
    fi
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    REGION=$(aws configure get region || echo "us-east-1")
    echo -e "${GREEN}[OK] AWS Account: $ACCOUNT_ID${NC}"
    echo -e "${GREEN}[OK] AWS Region: $REGION${NC}"
}

check_terraform_state_backend() {
    echo -e "${BLUE}Checking Terraform state backend...${NC}"

    BUCKET="terraform-state-bucket"
    REGION=${REGION:-us-east-1}

    if aws s3api head-bucket --bucket "$BUCKET" --region "$REGION" 2>/dev/null; then
        echo -e "${GREEN}[OK] S3 bucket exists: $BUCKET${NC}"
    else
        echo -e "${YELLOW}[WARN] S3 bucket not found: $BUCKET${NC}"
        echo "Create it with:"
        echo "  aws s3api create-bucket --bucket $BUCKET --region $REGION"
        echo "Or update backend.tf with your bucket name"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

check_terraform_variables() {
    if [[ ! -f "$TERRAFORM_VARS" ]]; then
        echo -e "${RED}Variables file not found: $TERRAFORM_VARS${NC}"
        echo "Create it using: cp environments/example-aws.tfvars $TERRAFORM_VARS"
        exit 1
    fi
    echo -e "${GREEN}[OK] Using variables: $TERRAFORM_VARS${NC}"
}

# Command functions
terraform_init() {
    echo -e "${BLUE}Initializing Terraform...${NC}"
    cd "$AWS_DIR"
    terraform init
    cd - > /dev/null
    echo -e "${GREEN}[OK] Terraform initialized${NC}"
}

terraform_validate() {
    echo -e "${BLUE}Validating Terraform configuration...${NC}"
    cd "$AWS_DIR"
    terraform validate
    cd - > /dev/null
    echo -e "${GREEN}[OK] Configuration is valid${NC}"
}

terraform_fmt() {
    echo -e "${BLUE}Formatting Terraform files...${NC}"
    cd "$AWS_DIR"
    terraform fmt -recursive
    cd - > /dev/null
    echo -e "${GREEN}[OK] Files formatted${NC}"
}

terraform_plan() {
    echo -e "${BLUE}Planning Terraform deployment...${NC}"
    cd "$AWS_DIR"
    terraform plan -var-file="$TERRAFORM_VARS" -out=tfplan
    cd - > /dev/null
    echo -e "${GREEN}[OK] Plan saved to tfplan${NC}"
}

terraform_apply() {
    echo -e "${YELLOW}[WARN] Applying Terraform changes...${NC}"
    echo "This will create or modify AWS resources"
    read -p "Type 'yes' to confirm: " -r
    echo

    if [[ $REPLY == "yes" ]]; then
        cd "$AWS_DIR"
        if [[ -f tfplan ]]; then
            terraform apply tfplan
            rm -f tfplan
        else
            terraform apply -var-file="$TERRAFORM_VARS"
        fi
        cd - > /dev/null
        echo -e "${GREEN}[OK] Resources deployed${NC}"

        # Configure kubectl
        echo -e "${BLUE}Configuring kubectl...${NC}"
        CLUSTER_NAME=$(cd "$AWS_DIR" && terraform output -raw eks_cluster_name 2>/dev/null || echo "")
        if [[ -n "$CLUSTER_NAME" ]]; then
            aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME"
            echo -e "${GREEN}[OK] kubectl configured${NC}"
        fi
    else
        echo -e "${RED}Deployment cancelled${NC}"
        exit 1
    fi
}

terraform_destroy() {
    echo -e "${RED}[WARN] DESTROYING AWS RESOURCES${NC}"
    echo "This will DELETE all created resources!"
    read -p "Type 'yes' to confirm destruction: " -r
    echo

    if [[ $REPLY == "yes" ]]; then
        cd "$AWS_DIR"
        terraform destroy -var-file="$TERRAFORM_VARS"
        cd - > /dev/null
        echo -e "${GREEN}[OK] Resources destroyed${NC}"
    else
        echo -e "${BLUE}Destruction cancelled${NC}"
    fi
}

terraform_output() {
    echo -e "${BLUE}Terraform Outputs:${NC}"
    cd "$AWS_DIR"
    terraform output
    cd - > /dev/null
}

show_usage() {
    echo "AWS EKS Terraform Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND] [ENVIRONMENT]"
    echo ""
    echo "Commands:"
    echo "  init       - Initialize Terraform"
    echo "  validate   - Validate configuration"
    echo "  fmt        - Format Terraform files"
    echo "  plan       - Plan deployment (default)"
    echo "  apply      - Apply deployment"
    echo "  destroy    - Destroy resources"
    echo "  output     - Show outputs"
    echo ""
    echo "Environments: dev, test, prod (default: dev)"
    echo ""
    echo "Examples:"
    echo "  $0 plan dev"
    echo "  $0 apply prod"
    echo "  $0 destroy test"
}

# Main execution
case "$COMMAND" in
    init)
        validate_environment
        validate_aws_credentials
        terraform_init
        ;;
    validate)
        validate_environment
        terraform_validate
        ;;
    fmt)
        terraform_fmt
        ;;
    plan)
        validate_environment
        validate_aws_credentials
        check_terraform_state_backend
        check_terraform_variables
        terraform_init
        terraform_validate
        terraform_plan
        ;;
    apply)
        validate_environment
        validate_aws_credentials
        check_terraform_state_backend
        check_terraform_variables
        terraform_init
        terraform_apply
        ;;
    destroy)
        validate_environment
        validate_aws_credentials
        check_terraform_variables
        terraform_init
        terraform_destroy
        ;;
    output)
        validate_environment
        terraform_output
        ;;
    *)
        show_usage
        exit 1
        ;;
esac

echo -e "${GREEN}Done!${NC}"