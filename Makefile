.PHONY: help setup install-deps install-collections check-rosa check-aks deploy-rosa deploy-aks destroy-rosa destroy-aks clean

# Colors
YELLOW := \033[1;33m
GREEN := \033[0;32m
NC := \033[0m

help: ## Show this help message
	@echo "$(YELLOW)Observability IaC - Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

setup: install-deps install-collections ## Complete setup (install all dependencies)
	@echo "$(GREEN)Setup completed!$(NC)"

install-deps: ## Install Python dependencies
	@echo "$(YELLOW)Installing Python dependencies...$(NC)"
	pip3 install -r requirements.txt

install-collections: ## Install Ansible Galaxy collections
	@echo "$(YELLOW)Installing Ansible collections...$(NC)"
	ansible-galaxy collection install -r requirements.yml --force

check-rosa: ## Check ROSA prerequisites
	@echo "$(YELLOW)Checking ROSA prerequisites...$(NC)"
	@which aws || (echo "$(RED)AWS CLI not found$(NC)" && exit 1)
	@aws sts get-caller-identity || (echo "$(RED)AWS credentials not configured$(NC)" && exit 1)
	@echo "$(GREEN)ROSA prerequisites OK$(NC)"

check-aks: ## Check AKS prerequisites
	@echo "$(YELLOW)Checking AKS prerequisites...$(NC)"
	@which az || (echo "$(RED)Azure CLI not found$(NC)" && exit 1)
	@az account show || (echo "$(RED)Not logged in to Azure$(NC)" && exit 1)
	@echo "$(GREEN)AKS prerequisites OK$(NC)"

deploy-rosa: check-rosa ## Deploy ROSA cluster
	@echo "$(YELLOW)Deploying ROSA cluster...$(NC)"
	ansible-playbook -i inventory/aws playbooks/deploy_rosa.yml

deploy-aks: check-aks ## Deploy AKS cluster
	@echo "$(YELLOW)Deploying AKS cluster...$(NC)"
	ansible-playbook -i inventory/azure playbooks/deploy_aks.yml

destroy-rosa: check-rosa ## Destroy ROSA cluster
	@echo "$(YELLOW)Destroying ROSA cluster...$(NC)"
	ansible-playbook -i inventory/aws playbooks/deploy_rosa.yml -e "rosa_state=absent"

destroy-aks: check-aks ## Destroy AKS cluster
	@echo "$(YELLOW)Destroying AKS cluster...$(NC)"
	ansible-playbook -i inventory/azure playbooks/deploy_aks.yml -e "aks_state=absent"

rosa-status: ## Check ROSA cluster status
	@rosa describe cluster --cluster=$(shell grep rosa_cluster_name group_vars/rosa.yml | awk '{print $$2}' | tr -d '"')

aks-status: ## Check AKS cluster status
	@az aks show \
		--name $(shell grep aks_cluster_name group_vars/aks.yml | awk '{print $$2}' | tr -d '"') \
		--resource-group $(shell grep aks_resource_group group_vars/aks.yml | awk '{print $$2}' | tr -d '"') \
		--output table

rosa-credentials: ## Get ROSA admin credentials
	@rosa create admin --cluster=$(shell grep rosa_cluster_name group_vars/rosa.yml | awk '{print $$2}' | tr -d '"')

aks-credentials: ## Get AKS cluster credentials
	@az aks get-credentials \
		--name $(shell grep aks_cluster_name group_vars/aks.yml | awk '{print $$2}' | tr -d '"') \
		--resource-group $(shell grep aks_resource_group group_vars/aks.yml | awk '{print $$2}' | tr -d '"') \
		--overwrite-existing

clean: ## Clean temporary files
	@echo "$(YELLOW)Cleaning temporary files...$(NC)"
	@find . -type f -name "*.retry" -delete
	@find . -type f -name "*_cluster_info.json" -delete
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)Cleaned!$(NC}"

lint: ## Run YAML linting
	@echo "$(YELLOW)Running YAML lint...$(NC)"
	@ansible-lint playbooks/*.yml roles/*/tasks/*.yml || true

test-rosa: ## Test ROSA playbook (dry run)
	@ansible-playbook -i inventory/aws playbooks/deploy_rosa.yml --check

test-aks: ## Test AKS playbook (dry run)
	@ansible-playbook -i inventory/azure playbooks/deploy_aks.yml --check

