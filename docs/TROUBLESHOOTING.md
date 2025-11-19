# Troubleshooting Guide

This guide covers common issues and their solutions when deploying observability clusters.

## Table of Contents

- [ROSA Common Issues](#rosa-common-issues)
- [AKS Common Issues](#aks-common-issues)
- [Ansible Issues](#ansible-issues)
- [Network Issues](#network-issues)
- [Authentication Issues](#authentication-issues)

## ROSA Common Issues

### Issue: ROSA CLI Not Found

**Symptom**: `rosa: command not found`

**Solution**:
```bash
# Download and install ROSA CLI
wget https://mirror.openshift.com/pub/openshift-v4/clients/rosa/latest/rosa-linux.tar.gz
tar -xzf rosa-linux.tar.gz
sudo mv rosa /usr/local/bin/
rosa version
```

### Issue: AWS Quota Exceeded

**Symptom**: `QuotaExceeded` or `LimitExceeded` errors

**Solution**:
```bash
# Check current quotas
aws service-quotas list-service-quotas --service-code ec2 --region us-east-1

# Request quota increase
aws service-quotas request-service-quota-increase \
  --service-code ec2 \
  --quota-code L-1216C47A \
  --desired-value 100
```

### Issue: ROSA Token Expired

**Symptom**: `401 Unauthorized` when running ROSA commands

**Solution**:
1. Get a new token from: https://console.redhat.com/openshift/token
2. Export the new token:
   ```bash
   export ROSA_TOKEN="your-new-token"
   ```
3. Re-run the playbook

### Issue: VPC/Subnet Not Available

**Symptom**: Cannot find suitable VPC or subnets

**Solution**:
```bash
# List available VPCs
aws ec2 describe-vpcs --region us-east-1

# Create subnets if needed
rosa create cluster --help | grep subnet

# Use specific subnet IDs
ansible-playbook -i inventory/aws playbooks/deploy_rosa.yml \
  -e "rosa_subnet_ids=['subnet-xxx','subnet-yyy']"
```

### Issue: STS Roles Not Created

**Symptom**: Missing IAM roles for STS mode

**Solution**:
```bash
# Create necessary roles
rosa create account-roles --mode auto --yes

# Create operator roles for the cluster
rosa create operator-roles --cluster=your-cluster-name --mode auto --yes
```

## AKS Common Issues

### Issue: Azure CLI Not Authenticated

**Symptom**: `Please run 'az login' to setup account`

**Solution**:
```bash
# Login to Azure
az login

# For service principal
az login --service-principal \
  --username $AZURE_CLIENT_ID \
  --password $AZURE_CLIENT_SECRET \
  --tenant $AZURE_TENANT_ID

# Verify login
az account show
```

### Issue: Insufficient Permissions

**Symptom**: `AuthorizationFailed` or `Forbidden` errors

**Solution**:
```bash
# Check current role assignments
az role assignment list --assignee $(az account show --query user.name -o tsv)

# Required roles for AKS deployment:
# - Contributor on subscription or resource group
# - User Access Administrator (for RBAC setup)

# Assign contributor role
az role assignment create \
  --role "Contributor" \
  --assignee user@example.com \
  --scope /subscriptions/{subscription-id}
```

### Issue: Quota Exceeded

**Symptom**: `QuotaExceeded` error during deployment

**Solution**:
```bash
# Check quotas
az vm list-usage --location eastus --output table

# Request quota increase through Azure Portal:
# Portal → Subscriptions → Usage + quotas → Request increase
```

### Issue: Network Plugin Conflicts

**Symptom**: Cannot create cluster with specified network plugin

**Solution**:
```bash
# For existing VNet, use Azure CNI
ansible-playbook -i inventory/azure playbooks/deploy_aks.yml \
  -e "aks_network_plugin=azure"

# For simpler setup, use kubenet
ansible-playbook -i inventory/azure playbooks/deploy_aks.yml \
  -e "aks_network_plugin=kubenet"
```

### Issue: kubectl Not Working

**Symptom**: `kubectl` commands fail after cluster creation

**Solution**:
```bash
# Get credentials again
az aks get-credentials \
  --name obs-aks-cluster \
  --resource-group obs-aks-rg \
  --overwrite-existing

# Verify connectivity
kubectl cluster-info
kubectl get nodes
```

## Ansible Issues

### Issue: Module Not Found

**Symptom**: `Module not found` or `Collection not found`

**Solution**:
```bash
# Install collections
ansible-galaxy collection install -r requirements.yml --force

# Install Python dependencies
pip3 install -r requirements.txt

# For specific collection
ansible-galaxy collection install azure.azcollection
```

### Issue: Python Dependency Conflicts

**Symptom**: `ImportError` or version conflicts

**Solution**:
```bash
# Use virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Update pip
pip install --upgrade pip

# Force reinstall
pip install --force-reinstall -r requirements.txt
```

### Issue: Playbook Hangs

**Symptom**: Playbook seems stuck or not progressing

**Solution**:
```bash
# Run with increased verbosity
ansible-playbook -i inventory/aws playbooks/deploy_rosa.yml -vvv

# Check for async tasks timing out
# Edit the playbook and adjust async/poll values

# Check system resources
top
df -h
```

## Network Issues

### Issue: Cannot Access Cluster

**Symptom**: Cluster created but cannot access API/console

**Solution**:

For ROSA:
```bash
# Check cluster status
rosa describe cluster --cluster=obs-rosa-cluster

# Verify DNS is propagated
nslookup $(rosa describe cluster --cluster=obs-rosa-cluster | grep "API URL" | awk '{print $3}')

# Check security groups
aws ec2 describe-security-groups --region us-east-1
```

For AKS:
```bash
# Check cluster state
az aks show --name obs-aks-cluster --resource-group obs-aks-rg

# Verify network rules
az network nsg list --resource-group obs-aks-rg

# Get credentials
az aks get-credentials --name obs-aks-cluster --resource-group obs-aks-rg
```

### Issue: Proxy Configuration

**Symptom**: Cannot reach external services from cluster

**Solution**:
```bash
# For ROSA, set proxy in variables
ansible-playbook -i inventory/aws playbooks/deploy_rosa.yml \
  -e "rosa_http_proxy=http://proxy.example.com:8080" \
  -e "rosa_https_proxy=http://proxy.example.com:8080" \
  -e "rosa_no_proxy=.cluster.local,localhost"

# For AKS, configure during cluster creation
# Edit group_vars/aks.yml and add proxy settings
```

## Authentication Issues

### Issue: AWS Credentials Not Working

**Symptom**: `Unable to locate credentials`

**Solution**:
```bash
# Configure credentials
aws configure --profile default

# Verify credentials
aws sts get-caller-identity

# Use specific profile
export AWS_PROFILE=your-profile
ansible-playbook -i inventory/aws playbooks/deploy_rosa.yml
```

### Issue: Azure Login Expired

**Symptom**: `Azure token expired`

**Solution**:
```bash
# Re-login
az login

# For service principal
az login --service-principal \
  --username $AZURE_CLIENT_ID \
  --password $AZURE_CLIENT_SECRET \
  --tenant $AZURE_TENANT_ID
```

### Issue: SSH Key Issues

**Symptom**: SSH key errors during AKS creation

**Solution**:
```bash
# Generate SSH key if needed
ssh-keygen -t rsa -b 4096 -f ~/.ssh/aks-key

# Use specific key
ansible-playbook -i inventory/azure playbooks/deploy_aks.yml \
  -e "aks_ssh_key_path=~/.ssh/aks-key.pub"
```

## Getting Help

If you encounter issues not covered here:

1. **Check Logs**: Look for detailed error messages in Ansible output with `-vvv`
2. **Cloud Provider Docs**: Consult official AWS/Azure documentation
3. **GitHub Issues**: Search existing issues or create a new one
4. **Community**: Join our community chat for real-time help

## Useful Commands

### ROSA Diagnostics
```bash
rosa whoami
rosa list clusters
rosa logs cluster --cluster=obs-rosa-cluster
rosa describe cluster --cluster=obs-rosa-cluster
```

### AKS Diagnostics
```bash
az account show
az aks list --output table
az aks show --name obs-aks-cluster --resource-group obs-aks-rg
az aks get-upgrades --name obs-aks-cluster --resource-group obs-aks-rg
```

### Kubernetes Diagnostics
```bash
kubectl get nodes
kubectl get pods --all-namespaces
kubectl describe node <node-name>
kubectl logs <pod-name> -n <namespace>
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

