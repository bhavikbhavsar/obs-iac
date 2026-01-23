# Observability Infrastructure as Code

This repository contains Ansible playbooks and roles for deploying observability clusters with Prometheus, Grafana, Loki, and OpenTelemetry on various cloud platforms.

## 🎯 Overview

This infrastructure-as-code setup enables automated deployment of:
- **ROSA (Red Hat OpenShift Service on AWS)** clusters on AWS
- **AKS (Azure Kubernetes Service)** clusters on Azure

## 📋 Prerequisites

### General Requirements
- Ansible >= 8.0.0
- Python 3.8+
- Git

### For ROSA on AWS
- AWS CLI configured with credentials
- AWS account with appropriate permissions
- ROSA CLI (will be installed automatically if not present)
- Red Hat account and ROSA token

### For AKS on Azure
- Azure CLI installed and configured
- Azure subscription with appropriate permissions
- kubectl (will be installed automatically if not present)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd obs-iac
```

### 2. Install Dependencies

```bash
# Install Python dependencies
pip install -r requirements.txt

# Install Ansible collections
ansible-galaxy collection install -r requirements.yml
```

### 3. Configure Variables

Edit the configuration files based on your requirements:

#### For AKS:
Edit `group_vars/aks.yml`:
```yaml
aks_cluster_name: "your-cluster-name"
aks_resource_group: "your-resource-group"
aks_location: "eastus"
# ... other variables
```

### 4. Authenticate with Cloud Providers

#### Azure (for AKS):
```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "your-subscription-id"
```

## 📖 Usage


### Deploy AKS Cluster

```bash
# Deploy AKS cluster
ansible-playbook -i inventory/azure playbooks/deploy_aks.yml

# Deploy with custom variables
ansible-playbook -i inventory/azure playbooks/deploy_aks.yml \
  -e "aks_cluster_name=my-aks-cluster" \
  -e "aks_location=westus2"
```

### Delete Clusters

```bash
# Delete AKS cluster
ansible-playbook -i inventory/azure playbooks/deploy_aks.yml \
  -e "aks_state=absent"
```


## ⚙️ Configuration

### AKS Configuration Options

Key variables in `group_vars/aks.yml`:

| Variable | Description | Default |
|----------|-------------|---------|
| `aks_cluster_name` | Name of the AKS cluster | `obs-aks-cluster` |
| `aks_resource_group` | Azure resource group | `obs-aks-rg` |
| `aks_location` | Azure region | `eastus` |
| `aks_kubernetes_version` | Kubernetes version | `1.28` |
| `aks_vm_size` | Azure VM size | `Standard_D4s_v3` |
| `aks_node_count` | Number of nodes | `3` |
| `aks_enable_auto_scaling` | Enable autoscaling | `true` |

## 🔍 Verification

### Verify AKS Cluster

```bash
# Get cluster credentials
az aks get-credentials --name obs-aks-cluster --resource-group obs-aks-rg

# Check nodes
kubectl get nodes

# Check cluster info
kubectl cluster-info

# View all namespaces
kubectl get ns
```

## 🐛 Troubleshooting




### AKS Issues

**Problem**: Azure CLI not authenticated
```bash
# Login to Azure
az login

# Verify account
az account show
```

**Problem**: Insufficient permissions
```bash
# Check your role assignments
az role assignment list --assignee $(az account show --query user.name -o tsv)
```

## 📚 Next Steps

After deploying your clusters, you can:

1. **Install Observability Stack**:
   - Deploy Prometheus
   - Deploy Grafana
   - Deploy Loki
   - Deploy OpenTelemetry Collector

2. **Configure Networking**:
   - Set up ingress controllers
   - Configure DNS
   - Set up TLS certificates

3. **Set up Monitoring**:
   - Configure cluster monitoring
   - Set up alerts
   - Create dashboards

---

**Note**: Always test in a development environment before deploying to production.

