# Local VM FastAPI Deployment Setup

This document provides a quick setup guide for deploying FastAPI applications on local VMs using the Docker Swarm Ansible project.

## 🚀 Quick Setup

### 1. Ensure VMs are Created and Running
```bash
# Check if VMs exist
make list-vms

# Power on VMs if needed
make power-on-vms

# Check VM status
virsh list --all
```

### 2. Configure SSH Keys for GitHub Access
```bash
# Generate SSH key if needed
ssh-keygen -t ed25519 -C "your-email@example.com"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Add public key to GitHub
cat ~/.ssh/id_ed25519.pub
```

### 3. Deploy FastAPI Applications
```bash
# Deploy both ANPR and private FastAPI applications
make deploy-fastapi
```

## 📋 Current Configuration

### VM Inventory
The deployment uses the existing `inventory/created_vms.yml` with:
- **docker_swarm1**: 192.168.122.101 (manager)
- **docker_swarm2**: 192.168.122.102 (worker)

### Applications Deployed
1. **ANPR Application**: `git@github.com:micrometre/fastapi-anpr.git` (azure branch)
2. **Private FastAPI**: `git@github.com:micrometre/fastapi-private-repo.git` (main branch)

### Access URLs
After deployment, applications will be available at:
- **FastAPI App**: http://192.168.122.101:8000
- **FastAPI Docs**: http://192.168.122.101:8000/docs
- **FastAPI Health**: http://192.168.122.101:8000/health

## 🔧 Customization

### Change Private Repository
Edit `playbooks/deployments/deploy_fastapi_anpr.yml`:

```yaml
vars:
  fastapi_repo_url: "git@github.com:your-user/your-private-repo.git"
  fastapi_repo_branch: "develop"
  exposed_port: 8080
```

### Change Target VMs
The deployment targets all VMs in the `created_vms` group. To deploy to specific VMs:

1. Create a custom inventory file
2. Update the playbook hosts directive
3. Run with custom inventory: `ansible-playbook -i custom_inventory.yml playbook.yml`

## 📊 Deployment Process

1. **Repository Cloning**: Downloads both ANPR and private FastAPI repositories
2. **Docker Setup**: Creates Dockerfile, docker-compose.yml, requirements.txt
3. **Container Build**: Builds Docker image with FastAPI application
4. **Service Deployment**: Starts container with docker-compose
5. **Health Monitoring**: Checks application health and displays status

## 🔍 Troubleshooting

### Common Issues

#### SSH Key Access
```bash
# Test SSH connection to GitHub
ssh -T git@github.com

# Check SSH key
ls -la ~/.ssh/
```

#### VM Connectivity
```bash
# Ping VMs
make ping-vms

# Check VM status
make vm-status

# Power on VMs
make power-on-vms
```

#### Application Issues
```bash
# SSH to VM and check containers
ssh ubuntu@192.168.122.101
cd /home/ubuntu/repos/fastapi-app
docker-compose ps
docker-compose logs fastapi-app
```

## 🎯 Integration with Existing Commands

The FastAPI deployment integrates seamlessly with existing VM management:

```bash
# Complete deployment workflow
make power-on-vms          # Start VMs
make configure-vms          # Configure VMs (if needed)
make deploy-fastapi         # Deploy FastAPI apps
make list-services          # Check services
make shutdown-vms           # Shutdown when done
```

## 📚 Documentation

For detailed information, see:
- `FASTAPI_DEPLOYMENT.md` - Complete deployment guide
- `playbooks/deployments/deploy_fastapi_anpr.yml` - Deployment playbook
- `inventory/local_vms_fastapi.yml.example` - Inventory configuration example

## 🎉 Benefits

1. **Local Development**: Perfect for development and testing
2. **Docker Integration**: Full containerization with health monitoring
3. **Private Repo Support**: Secure SSH key authentication
4. **Dual Deployment**: Deploy both ANPR and custom FastAPI apps
5. **VM Management**: Integrated with existing power management
6. **Easy Configuration**: Simple variable-based customization
