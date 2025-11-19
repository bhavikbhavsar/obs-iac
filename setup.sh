#!/bin/bash
# Setup script for Observability IaC project

set -e

echo "=========================================="
echo "Observability IaC Setup"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check Python
echo -e "\n${YELLOW}Checking Python...${NC}"
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✓ Found: $PYTHON_VERSION${NC}"
else
    echo -e "${RED}✗ Python 3 is not installed${NC}"
    exit 1
fi

# Check pip
echo -e "\n${YELLOW}Checking pip...${NC}"
if command -v pip3 &> /dev/null; then
    PIP_VERSION=$(pip3 --version)
    echo -e "${GREEN}✓ Found: $PIP_VERSION${NC}"
else
    echo -e "${RED}✗ pip is not installed${NC}"
    exit 1
fi

# Install Python dependencies
echo -e "\n${YELLOW}Installing Python dependencies...${NC}"
pip3 install -r requirements.txt
echo -e "${GREEN}✓ Python dependencies installed${NC}"

# Install Ansible collections
echo -e "\n${YELLOW}Installing Ansible collections...${NC}"
ansible-galaxy collection install -r requirements.yml --force
echo -e "${GREEN}✓ Ansible collections installed${NC}"

# Check for cloud CLI tools
echo -e "\n${YELLOW}Checking cloud provider CLIs...${NC}"

# Check AWS CLI
if command -v aws &> /dev/null; then
    AWS_VERSION=$(aws --version 2>&1)
    echo -e "${GREEN}✓ AWS CLI: $AWS_VERSION${NC}"
else
    echo -e "${YELLOW}! AWS CLI not found. Install from: https://aws.amazon.com/cli/${NC}"
fi

# Check Azure CLI
if command -v az &> /dev/null; then
    AZ_VERSION=$(az version --output tsv 2>&1 | head -1)
    echo -e "${GREEN}✓ Azure CLI found${NC}"
else
    echo -e "${YELLOW}! Azure CLI not found. Install from: https://docs.microsoft.com/cli/azure/install-azure-cli${NC}"
fi

# Check ROSA CLI
if command -v rosa &> /dev/null; then
    ROSA_VERSION=$(rosa version)
    echo -e "${GREEN}✓ ROSA CLI: $ROSA_VERSION${NC}"
else
    echo -e "${YELLOW}! ROSA CLI not found. It will be installed automatically during ROSA deployment.${NC}"
fi

# Check kubectl
if command -v kubectl &> /dev/null; then
    KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null || kubectl version --client 2>&1 | head -1)
    echo -e "${GREEN}✓ kubectl: $KUBECTL_VERSION${NC}"
else
    echo -e "${YELLOW}! kubectl not found. It will be installed automatically during AKS deployment.${NC}"
fi

echo -e "\n${GREEN}=========================================="
echo "Setup completed successfully!"
echo "==========================================${NC}"

echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. For ROSA deployment:"
echo "   - Configure AWS credentials: aws configure"
echo "   - Get ROSA token from: https://console.redhat.com/openshift/token"
echo "   - Export token: export ROSA_TOKEN='your-token'"
echo "   - Edit group_vars/rosa.yml with your settings"
echo "   - Run: ansible-playbook -i inventory/aws playbooks/deploy_rosa.yml"
echo ""
echo "2. For AKS deployment:"
echo "   - Login to Azure: az login"
echo "   - Set subscription: az account set --subscription 'your-subscription-id'"
echo "   - Edit group_vars/aks.yml with your settings"
echo "   - Run: ansible-playbook -i inventory/azure playbooks/deploy_aks.yml"
echo ""
echo "For more information, see README.md"

