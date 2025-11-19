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

#### For ROSA:
Edit `group_vars/rosa.yml`:
```yaml
rosa_cluster_name: "your-cluster-name"
rosa_region: "us-east-1"
rosa_compute_nodes: 3
# ... other variables
```

#### For AKS:
Edit `group_vars/aks.yml`:
```yaml
aks_cluster_name: "your-cluster-name"
aks_resource_group: "your-resource-group"
aks_location: "eastus"
# ... other variables
```

### 4. Authenticate with Cloud Providers

#### AWS (for ROSA):
```bash
# Configure AWS credentials
aws configure --profile default

# Get your ROSA token from https://console.redhat.com/openshift/token
export ROSA_TOKEN="your-rosa-token"
```

#### Azure (for AKS):
```bash
# Login to Azure
az login

# Set your subscription
az account set --subscription "your-subscription-id"
```

## 📖 Usage

### Deploy ROSA Cluster

```bash
# Deploy ROSA cluster
ansible-playbook -i inventory/aws playbooks/deploy_rosa.yml

# Deploy with custom variables
ansible-playbook -i inventory/aws playbooks/deploy_rosa.yml \
  -e "rosa_cluster_name=my-cluster" \
  -e "rosa_region=us-west-2"
```

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
# Delete ROSA cluster
ansible-playbook -i inventory/aws playbooks/deploy_rosa.yml \
  -e "rosa_state=absent"

# Delete AKS cluster
ansible-playbook -i inventory/azure playbooks/deploy_aks.yml \
  -e "aks_state=absent"
```

## 📁 Project Structure

```
obs-iac/
├── ansible.cfg                 # Ansible configuration
├── requirements.txt            # Python dependencies
├── requirements.yml            # Ansible Galaxy dependencies
├── README.md                   # This file
├── .gitignore                 # Git ignore patterns
│
├── inventory/                  # Inventory files
│   ├── aws                    # AWS/ROSA inventory
│   └── azure                  # Azure/AKS inventory
│
├── group_vars/                # Group variables
│   ├── rosa.yml              # ROSA cluster configuration
│   └── aks.yml               # AKS cluster configuration
│
├── playbooks/                 # Ansible playbooks
│   ├── deploy_rosa.yml       # ROSA deployment playbook
│   └── deploy_aks.yml        # AKS deployment playbook
│
└── roles/                     # Ansible roles
    ├── rosa_cluster/         # ROSA cluster role
    │   ├── defaults/
    │   │   └── main.yml
    │   └── tasks/
    │       └── main.yml
    │
    └── aks_cluster/          # AKS cluster role
        ├── defaults/
        │   └── main.yml
        └── tasks/
            └── main.yml
```

## ⚙️ Configuration

### ROSA Configuration Options

Key variables in `group_vars/rosa.yml`:

| Variable | Description | Default |
|----------|-------------|---------|
| `rosa_cluster_name` | Name of the ROSA cluster | `obs-rosa-cluster` |
| `rosa_region` | AWS region | `us-east-1` |
| `rosa_cluster_version` | OpenShift version | `4.14` |
| `rosa_compute_machine_type` | EC2 instance type | `m5.xlarge` |
| `rosa_compute_nodes` | Number of compute nodes | `3` |
| `rosa_enable_autoscaling` | Enable autoscaling | `true` |
| `rosa_multi_az` | Multi-AZ deployment | `true` |

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

### Verify ROSA Cluster

```bash
# Check cluster status
rosa describe cluster --cluster=obs-rosa-cluster

# Get cluster API and console URLs
rosa describe cluster --cluster=obs-rosa-cluster | grep -E "(API|Console)"

# Create admin user
rosa create admin --cluster=obs-rosa-cluster
```

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

## 🔐 Security Considerations

1. **Never commit credentials** to version control
2. Use environment variables for sensitive data:
   - `ROSA_TOKEN` for ROSA authentication
   - AWS credentials via `~/.aws/credentials`
   - Azure credentials via `az login`
3. Enable RBAC on all clusters
4. Use managed identities where possible
5. Regularly rotate credentials
6. Review and limit cluster permissions

## 🐛 Troubleshooting

### ROSA Issues

**Problem**: ROSA CLI not found
```bash
# Manually install ROSA CLI
wget https://mirror.openshift.com/pub/openshift-v4/clients/rosa/latest/rosa-linux.tar.gz
tar -xzf rosa-linux.tar.gz
sudo mv rosa /usr/local/bin/
```

**Problem**: AWS quota exceeded
```bash
# Check AWS service quotas
aws service-quotas list-service-quotas --service-code ec2
```

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

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

[Specify your license here]

## 📞 Support

For issues and questions:
- Open an issue in this repository
- Contact the infrastructure team

## 🔄 Updates

Check the commit history for recent changes and updates to the infrastructure code.

---

**Note**: Always test in a development environment before deploying to production.

