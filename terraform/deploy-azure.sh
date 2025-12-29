#!/bin/bash
# Azure AKS Deployment Helper Script
# Usage: ./deploy-azure.sh [init|plan|apply|destroy] [environment]

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
AZURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/azure"
TERRAFORM_VARS="../environments/${ENVIRONMENT}/azure.tfvars"

# Validation functions
validate_environment() {
    if [[ ! "$ENVIRONMENT" =~ ^(dev|test|prod)$ ]]; then
        echo -e "${RED}Invalid environment: $ENVIRONMENT${NC}"
        echo "Must be one of: dev, test, prod"
        exit 1
    fi
}

validate_azure_credentials() {
    if ! az account show > /dev/null 2>&1; then
        echo -e "${RED}Azure credentials not configured${NC}"
        echo "Run: az login"
        exit 1
    fi
    ACCOUNT_NAME=$(az account show --query name --output tsv)
    SUBSCRIPTION_ID=$(az account show --query id --output tsv)
    echo -e "${GREEN}Azure Account: $ACCOUNT_NAME${NC}"
    echo -e "${GREEN}Subscription: $SUBSCRIPTION_ID${NC}"
}

check_terraform_state_backend() {
    echo -e "${BLUE}Checking Terraform state backend...${NC}"
    
    RG="rg-terraform-state"
    STORAGE="tfstate"
    CONTAINER="tfstate"
    
    if az group show --name "$RG" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Resource group exists: $RG${NC}"
    else
        echo -e "${YELLOW}⚠ Resource group not found: $RG${NC}"
        read -p "Create it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            LOCATION=${LOCATION:-eastus}
            az group create --name "$RG" --location "$LOCATION"
            echo -e "${GREEN}✓ Resource group created${NC}"
        fi
    fi
    
    if az storage account show --name "$STORAGE" --resource-group "$RG" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Storage account exists: $STORAGE${NC}"
    else
        echo -e "${YELLOW}⚠ Storage account not found: $STORAGE${NC}"
        echo "Create it with:"
        echo "  az storage account create --resource-group $RG --name $STORAGE --sku Standard_LRS"
        echo "Or update backend.tf with your storage account"
    fi
}

check_terraform_variables() {
    if [[ ! -f "$TERRAFORM_VARS" ]]; then
        echo -e "${RED}Variables file not found: $TERRAFORM_VARS${NC}"
        echo "Create it using: cp environments/example-azure.tfvars $TERRAFORM_VARS"
        exit 1
    fi
    echo -e "${GREEN}✓ Using variables: $TERRAFORM_VARS${NC}"
}

# Command functions
terraform_init() {
    echo -e "${BLUE}Initializing Terraform...${NC}"
    cd "$AZURE_DIR"
    terraform init
    cd - > /dev/null
    echo -e "${GREEN}✓ Terraform initialized${NC}"
}

terraform_validate() {
    echo -e "${BLUE}Validating Terraform configuration...${NC}"
    cd "$AZURE_DIR"
    terraform validate
    cd - > /dev/null
    echo -e "${GREEN}✓ Configuration is valid${NC}"
}

terraform_fmt() {
    echo -e "${BLUE}Formatting Terraform files...${NC}"
    cd "$AZURE_DIR"
    terraform fmt -recursive
    cd - > /dev/null
    echo -e "${GREEN}✓ Files formatted${NC}"
}

terraform_plan() {
    echo -e "${BLUE}Planning Terraform deployment...${NC}"
    cd "$AZURE_DIR"
    terraform plan -var-file="$TERRAFORM_VARS" -out=tfplan
    cd - > /dev/null
    echo -e "${GREEN}✓ Plan saved to tfplan${NC}"
}

terraform_apply() {
    echo -e "${YELLOW}⚠ Applying Terraform changes...${NC}"
    echo "This will create or modify Azure resources"
    read -p "Type 'yes' to confirm: " -r
    echo
    
    if [[ $REPLY == "yes" ]]; then
        cd "$AZURE_DIR"
        if [[ -f tfplan ]]; then
            terraform apply tfplan
            rm -f tfplan
        else
            terraform apply -var-file="$TERRAFORM_VARS"
        fi
        cd - > /dev/null
        echo -e "${GREEN}✓ Resources deployed${NC}"
        
        # Configure kubectl
        echo -e "${BLUE}Configuring kubectl...${NC}"
        RG=$(grep "resource_group_name" "$TERRAFORM_VARS" | awk -F'"' '{print $2}')
        CLUSTER=$(grep "cluster_name" "$TERRAFORM_VARS" | head -1 | awk -F'"' '{print $2}')
        if [[ -n "$RG" && -n "$CLUSTER" ]]; then
            az aks get-credentials --resource-group "$RG" --name "$CLUSTER"
            echo -e "${GREEN}✓ kubectl configured${NC}"
        fi
    else
        echo -e "${RED}Deployment cancelled${NC}"
        exit 1
    fi
}

terraform_destroy() {
    echo -e "${RED}⚠ DESTROYING AZURE RESOURCES${NC}"
    echo "This will DELETE all created resources!"
    read -p "Type 'yes' to confirm destruction: " -r
    echo
    
    if [[ $REPLY == "yes" ]]; then
        cd "$AZURE_DIR"
        terraform destroy -var-file="$TERRAFORM_VARS"
        cd - > /dev/null
        echo -e "${GREEN}✓ Resources destroyed${NC}"
    else
        echo -e "${BLUE}Destruction cancelled${NC}"
    fi
}

terraform_output() {
    echo -e "${BLUE}Terraform Outputs:${NC}"
    cd "$AZURE_DIR"
    terraform output
    cd - > /dev/null
}

show_usage() {
    echo "Azure AKS Terraform Deployment Script"
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
        validate_azure_credentials
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
        validate_azure_credentials
        check_terraform_state_backend
        check_terraform_variables
        terraform_init
        terraform_validate
        terraform_plan
        ;;
    apply)
        validate_environment
        validate_azure_credentials
        check_terraform_state_backend
        check_terraform_variables
        terraform_init
        terraform_apply
        ;;
    destroy)
        validate_environment
        validate_azure_credentials
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
