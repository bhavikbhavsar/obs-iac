# Quick Start Guide

Get your observability cluster up and running in minutes!

## 🚀 Fast Track (5 Minutes)

### For ROSA on AWS

```bash
# 1. Setup dependencies
./setup.sh

# 2. Configure AWS
aws configure
export ROSA_TOKEN="get-from-https://console.redhat.com/openshift/token"

# 3. Edit cluster settings (optional)
vi group_vars/rosa.yml

# 4. Deploy!
make deploy-rosa
```

### For AKS on Azure

```bash
# 1. Setup dependencies
./setup.sh

# 2. Configure Azure
az login
az account set --subscription "your-subscription"

# 3. Edit cluster settings (optional)
vi group_vars/aks.yml

# 4. Deploy!
make deploy-aks
```

## ⚙️ Configuration Quickstart

### Minimal ROSA Configuration

```yaml
# group_vars/rosa.yml
rosa_cluster_name: "my-cluster"
rosa_region: "us-east-1"
rosa_compute_nodes: 3
```

### Minimal AKS Configuration

```yaml
# group_vars/aks.yml
aks_cluster_name: "my-cluster"
aks_resource_group: "my-rg"
aks_location: "eastus"
```

## 🎯 Common Commands

```bash
# Deploy clusters
make deploy-rosa      # Deploy ROSA
make deploy-aks       # Deploy AKS

# Check status
make rosa-status      # ROSA status
make aks-status       # AKS status

# Get credentials
make rosa-credentials # ROSA admin
make aks-credentials  # AKS kubeconfig

# Cleanup
make destroy-rosa     # Delete ROSA
make destroy-aks      # Delete AKS
```

## 📊 What Gets Deployed?

### ROSA Cluster
- ✅ OpenShift 4.14+ cluster
- ✅ 3-node cluster (default)
- ✅ Autoscaling enabled
- ✅ Multi-AZ (optional)
- ✅ Admin user created
- ⏱️ Deployment time: ~40-60 minutes

### AKS Cluster
- ✅ Kubernetes 1.28+ cluster
- ✅ 3-node cluster (default)
- ✅ Autoscaling enabled
- ✅ Azure CNI networking
- ✅ Monitoring enabled
- ⏱️ Deployment time: ~10-15 minutes

## 🔍 Verification

### After ROSA Deployment

```bash
# Check cluster
rosa describe cluster --cluster=my-cluster

# Get console URL
rosa describe cluster --cluster=my-cluster | grep Console

# Login
rosa create admin --cluster=my-cluster
```

### After AKS Deployment

```bash
# Check nodes
kubectl get nodes

# Check system
kubectl get pods -n kube-system

# Cluster info
kubectl cluster-info
```

## ❓ Quick Troubleshooting

**ROSA token issues?**
```bash
# Get new token from: https://console.redhat.com/openshift/token
export ROSA_TOKEN="your-new-token"
```

**Azure not logged in?**
```bash
az login
az account set --subscription "your-subscription"
```

**Ansible issues?**
```bash
pip3 install -r requirements.txt
ansible-galaxy collection install -r requirements.yml --force
```

## 📚 Next Steps

1. ✅ **Cluster Deployed** - You're here!
2. 📦 **Install Observability Stack**
   - Prometheus for metrics
   - Grafana for visualization
   - Loki for logs
   - OpenTelemetry for traces

3. 🔒 **Security Setup**
   - Configure RBAC
   - Setup network policies
   - Enable audit logging

4. 📊 **Monitoring**
   - Setup alerts
   - Create dashboards
   - Configure log retention

## 📖 Full Documentation

- [README.md](./README.md) - Complete reference
- [DEPLOYMENT_GUIDE.md](./docs/DEPLOYMENT_GUIDE.md) - Detailed deployment steps
- [TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md) - Common issues & solutions

## 💡 Pro Tips

1. **Start small**: Use default settings for your first deployment
2. **Test first**: Deploy to dev before production
3. **Monitor costs**: Both ROSA and AKS charge by the hour
4. **Use tags**: Tag resources for better organization
5. **Backup configs**: Version control your variable files

## 🎉 Success!

Once deployed, you'll have:
- A production-ready Kubernetes/OpenShift cluster
- Autoscaling capabilities
- Monitoring infrastructure
- Ready for observability tools installation

Happy deploying! 🚀

