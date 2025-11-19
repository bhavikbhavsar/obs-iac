# Deployment Guide

Complete guide for deploying ROSA and AKS clusters for observability.

## Prerequisites Checklist

Before starting, ensure you have:

### General
- [ ] Linux/macOS system (or WSL on Windows)
- [ ] Python 3.8 or higher
- [ ] pip (Python package manager)
- [ ] Git
- [ ] Internet connectivity

### For ROSA Deployment
- [ ] AWS account with admin permissions
- [ ] AWS CLI installed and configured
- [ ] Red Hat account
- [ ] ROSA enabled on your AWS account
- [ ] Sufficient AWS service quotas

### For AKS Deployment
- [ ] Azure subscription with contributor access
- [ ] Azure CLI installed
- [ ] kubectl installed (or will be installed automatically)

## Step-by-Step Deployment

### Phase 1: Environment Setup

#### 1.1 Clone and Setup

```bash
# Clone repository
git clone <repository-url>
cd obs-iac

# Make setup script executable
chmod +x setup.sh

# Run setup
./setup.sh
```

Or using Make:

```bash
make setup
```

#### 1.2 Verify Installation

```bash
# Check Ansible version
ansible --version

# Check installed collections
ansible-galaxy collection list

# Verify Python packages
pip list | grep -E "boto3|azure"
```

### Phase 2: ROSA Cluster Deployment

#### 2.1 Configure AWS Credentials

```bash
# Configure AWS CLI
aws configure

# Enter your credentials when prompted:
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region: us-east-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

#### 2.2 Enable ROSA on AWS Account

```bash
# Log in to ROSA
rosa login

# Verify ROSA prerequisites
rosa verify quota
rosa verify permissions

# Initialize ROSA (if first time)
rosa init

# Create account roles
rosa create account-roles --mode auto --yes
```

#### 2.3 Get ROSA Token

1. Visit: https://console.redhat.com/openshift/token
2. Copy your token
3. Export it:
   ```bash
   export ROSA_TOKEN="your-token-here"
   ```

#### 2.4 Configure ROSA Variables

Edit `group_vars/rosa.yml`:

```yaml
# Minimal configuration
rosa_cluster_name: "my-obs-cluster"
rosa_region: "us-east-1"
rosa_compute_machine_type: "m5.xlarge"
rosa_compute_nodes: 3

# For production
rosa_multi_az: true
rosa_enable_autoscaling: true
rosa_compute_nodes_min: 3
rosa_compute_nodes_max: 10
```

#### 2.5 Deploy ROSA Cluster

```bash
# Dry run (check what will happen)
make test-rosa

# Deploy cluster
make deploy-rosa

# Or directly with ansible-playbook
ansible-playbook -i inventory/aws playbooks/deploy_rosa.yml
```

**Note**: ROSA deployment typically takes 40-60 minutes.

#### 2.6 Verify ROSA Deployment

```bash
# Check cluster status
make rosa-status

# Or using ROSA CLI
rosa describe cluster --cluster=my-obs-cluster

# Get admin credentials
make rosa-credentials

# Access the console
rosa describe cluster --cluster=my-obs-cluster | grep Console
```

### Phase 3: AKS Cluster Deployment

#### 3.1 Configure Azure Credentials

```bash
# Login to Azure
az login

# This will open a browser for authentication
# Follow the prompts to complete login

# List subscriptions
az account list --output table

# Set active subscription
az account set --subscription "Your Subscription Name"

# Verify
az account show
```

#### 3.2 Configure AKS Variables

Edit `group_vars/aks.yml`:

```yaml
# Minimal configuration
aks_cluster_name: "my-obs-aks"
aks_resource_group: "obs-aks-rg"
aks_location: "eastus"
aks_vm_size: "Standard_D4s_v3"
aks_node_count: 3

# For production
aks_enable_auto_scaling: true
aks_min_node_count: 3
aks_max_node_count: 10
aks_enable_monitoring: true
```

#### 3.3 Deploy AKS Cluster

```bash
# Dry run
make test-aks

# Deploy cluster
make deploy-aks

# Or directly with ansible-playbook
ansible-playbook -i inventory/azure playbooks/deploy_aks.yml
```

**Note**: AKS deployment typically takes 10-15 minutes.

#### 3.4 Verify AKS Deployment

```bash
# Check cluster status
make aks-status

# Get credentials
make aks-credentials

# Verify Kubernetes access
kubectl get nodes
kubectl cluster-info
```

## Post-Deployment Tasks

### For ROSA

1. **Create Admin User**:
   ```bash
   rosa create admin --cluster=my-obs-cluster
   ```

2. **Access Console**:
   ```bash
   rosa describe cluster --cluster=my-obs-cluster
   # Open the Console URL in your browser
   ```

3. **Configure kubectl** (optional):
   ```bash
   oc login <api-url> --username cluster-admin --password <password>
   ```

### For AKS

1. **Verify Nodes**:
   ```bash
   kubectl get nodes
   kubectl top nodes
   ```

2. **Check System Pods**:
   ```bash
   kubectl get pods -n kube-system
   ```

3. **Access Dashboard** (if enabled):
   ```bash
   az aks browse --name my-obs-aks --resource-group obs-aks-rg
   ```

## Customization Options

### Network Configuration

#### ROSA with Existing VPC:

```yaml
# In group_vars/rosa.yml
rosa_subnet_ids:
  - "subnet-xxx"
  - "subnet-yyy"
  - "subnet-zzz"
```

#### AKS with Existing VNet:

```yaml
# In group_vars/aks.yml
aks_vnet_name: "my-vnet"
aks_subnet_name: "my-subnet"
aks_network_plugin: "azure"
```

### Scaling Configuration

#### ROSA Autoscaling:

```yaml
rosa_enable_autoscaling: true
rosa_compute_nodes_min: 3
rosa_compute_nodes_max: 10
```

#### AKS Autoscaling:

```yaml
aks_enable_auto_scaling: true
aks_min_node_count: 3
aks_max_node_count: 10
```

### Machine Types

#### ROSA:
- General: `m5.xlarge`, `m5.2xlarge`
- Compute: `c5.xlarge`, `c5.2xlarge`
- Memory: `r5.xlarge`, `r5.2xlarge`

#### AKS:
- General: `Standard_D4s_v3`, `Standard_D8s_v3`
- Compute: `Standard_F4s_v2`, `Standard_F8s_v2`
- Memory: `Standard_E4s_v3`, `Standard_E8s_v3`

## Cost Optimization

### ROSA Cost Tips

1. **Use Single-AZ** for dev/test:
   ```yaml
   rosa_multi_az: false
   ```

2. **Right-size instances**:
   ```yaml
   rosa_compute_machine_type: "m5.large"  # Instead of xlarge
   ```

3. **Enable autoscaling** to scale down during low usage

### AKS Cost Tips

1. **Use spot instances** for non-critical workloads
2. **Start/stop clusters** when not in use:
   ```bash
   az aks stop --name my-obs-aks --resource-group obs-aks-rg
   az aks start --name my-obs-aks --resource-group obs-aks-rg
   ```

3. **Right-size VMs**:
   ```yaml
   aks_vm_size: "Standard_B4ms"  # For dev/test
   ```

## Monitoring Deployment

### Watch ROSA Progress

```bash
# In one terminal, watch status
watch -n 30 'rosa describe cluster --cluster=my-obs-cluster'

# In another, follow logs
rosa logs install --cluster=my-obs-cluster --watch
```

### Watch AKS Progress

```bash
# Watch deployment
watch -n 10 'az aks show --name my-obs-aks --resource-group obs-aks-rg --query provisioningState'

# Check node status
watch -n 10 'kubectl get nodes'
```

## Cleanup and Deletion

### Delete ROSA Cluster

```bash
# Using Make
make destroy-rosa

# Or directly
ansible-playbook -i inventory/aws playbooks/deploy_rosa.yml -e "rosa_state=absent"

# Verify deletion
rosa list clusters
```

### Delete AKS Cluster

```bash
# Using Make
make destroy-aks

# Or directly
ansible-playbook -i inventory/azure playbooks/deploy_aks.yml -e "aks_state=absent"

# Manual cleanup
az group delete --name obs-aks-rg --yes --no-wait
```

## Next Steps

After deploying clusters, proceed with:

1. **Install Observability Tools**:
   - Prometheus
   - Grafana
   - Loki
   - OpenTelemetry

2. **Configure Networking**:
   - Ingress controllers
   - DNS records
   - TLS certificates

3. **Setup Monitoring**:
   - Cluster monitoring
   - Application monitoring
   - Log aggregation

4. **Security Hardening**:
   - Network policies
   - Pod security policies
   - RBAC configuration

## Troubleshooting

See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues and solutions.

## Support

- GitHub Issues: Report bugs and feature requests
- Documentation: Check README.md for reference
- Community: Join discussions for help

## Best Practices

1. **Always test in development** before production
2. **Use version control** for configuration changes
3. **Document customizations** in your fork
4. **Regular backups** of cluster state
5. **Monitor costs** regularly
6. **Keep dependencies updated**
7. **Use tags** for resource organization
8. **Implement proper RBAC**
9. **Enable audit logging**
10. **Plan for disaster recovery**

