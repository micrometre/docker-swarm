# Playbooks Directory Structure

This directory contains all Ansible playbooks organized by purpose:

## 📁 Directory Structure

```
playbooks/
├── deployments/          # Service deployment playbooks
│   ├── deploy_nginx.yml  # Deploy Nginx test service
│   ├── deploy_redis.yml  # Deploy Redis master-slave
│   └── deploy_stack.yml  # Deploy full application stack
├── management/           # Service management playbooks
│   └── manage_services.yml  # Service lifecycle management
└── setup/               # Cluster setup and configuration
    ├── configure_vm.yml # VM configuration
    └── setup_docker_swarm.yml  # Docker Swarm setup
```

## 🚀 Usage

All playbooks are accessible via the main Makefile in the project root:

### Service Deployment
```bash
make deploy-nginx          # Deploy Nginx service
make deploy-redis          # Deploy Redis services
make deploy-stack          # Deploy full stack
```

### Service Management
```bash
make list-services         # List all services
make inspect-service NAME=x  # Inspect service details
make scale-service NAME=x REPLICAS=n  # Scale service
make remove-service NAME=x  # Remove service
make service-logs NAME=x   # View service logs
```

### Cluster Setup
```bash
make setup-swarm           # Complete Swarm setup
make swarm-status          # Show cluster status
make configure-vms         # Configure VMs
```

## 📋 Playbook Details

### Deployments (`deployments/`)
- **deploy_nginx.yml**: Simple Nginx web server deployment
- **deploy_redis.yml**: Redis master-slave configuration
- **deploy_stack.yml**: Multi-service application stack

### Management (`management/`)
- **manage_services.yml**: Complete service lifecycle management
  - List, inspect, scale, remove services
  - View service logs
  - Error handling and validation

### Setup (`setup/`)
- **configure_vm.yml**: VM configuration and setup
- **setup_docker_swarm.yml**: Docker Swarm cluster management
  - Initialize Swarm
  - Join worker nodes
  - Create networks
  - Deploy services

## 🏷️ Tags

Most playbooks support tags for selective execution:

```bash
# Swarm setup tags
--tags swarm_init      # Initialize Swarm
--tags swarm_join      # Join workers
--tags swarm_status    # Show status
--tags swarm_leave     # Leave Swarm
--tags swarm_networks  # Create networks
--tags swarm_services  # Deploy services

# Service management tags
--tags service_manage  # Service operations
```

## 🔧 Configuration

All playbooks use the inventory file `inventory/created_vms.yml` and inherit variables from:
- `roles/docker_swarm/defaults/main.yml`
- `roles/vm-manager/defaults/main.yml`

## 📚 Examples

```bash
# Deploy and manage Nginx
make deploy-nginx
make list-services
make scale-service NAME=nginx_test REPLICAS=3
make service-logs NAME=nginx_test

# Full cluster setup
make create-multiple-vms
make configure-vms
make setup-swarm
make deploy-stack
```
