# Docker Swarm Ansible Project

This project provides a complete Ansible-based solution for creating and managing Docker Swarm clusters with multiple virtual machines. It automates VM provisioning, Docker installation, Swarm initialization, and service deployment.

## Overview

The project creates a production-ready Docker Swarm environment with:
- Automated VM provisioning using KVM/libvirt
- Docker installation and configuration
- Docker Swarm cluster setup (manager + workers)
- Network and service deployment
- Comprehensive inventory management

## Architecture

```
├── ansible.cfg                 # Ansible configuration
├── Makefile                    # Command shortcuts for all operations
├── requirements.txt            # Python dependencies
├── setup_docker_swarm.yml      # Main Swarm setup playbook
├── configure_vm.yml            # VM configuration playbook
├── main.yml                    # Legacy VM creation playbook
├── inventory/
│   ├── created_vms.yml         # Master inventory of all VMs
│   ├── inventory.yml            # Base inventory template
│   └── vm-*.yml               # Individual VM inventories
├── roles/
│   ├── vm-manager/             # VM provisioning and management
│   ├── common/                 # Common system configuration
│   ├── users/                  # User management
│   ├── docker/                 # Docker installation
│   └── docker_swarm/           # Docker Swarm management
└── .yamllint.yml              # YAML linting configuration
```

## Quick Start

### Prerequisites

- Ubuntu host with KVM/libvirt installed
- Ansible control node
- SSH keys for VM access
- Python 3.9+ with pip

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd docker-swarm/ansible

# Install dependencies
pip install -r requirements.txt

# Setup virtual environment (optional)
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### Create and Manage VMs

```bash
# Create multiple VMs (docker_swarm1 + docker_swarm2)
make create-multiple-vms

# Configure all VMs with Docker and required packages
make configure-vms

# Test connectivity
make ping-vms
make list-vms
```

### Docker Swarm Setup

```bash
# Complete Swarm setup (initialize manager + join workers)
make setup-swarm

# Or step by step:
make init-swarm       # Initialize docker_swarm1 as manager
make join-swarm       # Join docker_swarm2 as worker
make swarm-status     # Verify cluster status

# Deploy services and networks
make create-networks
make deploy-services
```

## VM Configuration

### Default VM Setup

The project creates two VMs by default:

| VM Name | Role | IP Address | Purpose |
|---------|------|------------|---------|
| docker_swarm1 | Manager | 192.168.122.101 | Swarm manager, runs management commands |
| docker_swarm2 | Worker | 192.168.122.102 | Swarm worker, runs application containers |

### VM Specifications

- **RAM**: 2GB per VM
- **vCPUs**: 1 per VM  
- **Disk**: 10GB per VM
- **OS**: Ubuntu 20.04 (cloud image)
- **Network**: libvirt bridge (virbr0)
- **User**: ubuntu with SSH key access

### Custom VM Configuration

Edit `roles/vm-manager/defaults/main.yml` to customize VM settings:

```yaml
vms:
  custom_vm1:
    vm_name: custom_vm1
    vm_hostname: custom1
    vm_ram: 4096
    vm_vcpus: 2
    vm_disk_size: 20G
    vm_static_ip: "192.168.122.110"
```

## Docker Swarm Features

### Network Management

```yaml
swarm_networks:
  - name: "web_network"
    driver: "overlay"
    subnet: "10.10.0.0/24"
    gateway: "10.10.0.1"
  - name: "db_network"
    driver: "overlay"
    subnet: "10.20.0.0/24"
    gateway: "10.20.0.1"
```

### Service Deployment

```yaml
swarm_services:
  - name: "nginx_service"
    image: "nginx:alpine"
    replicas: 2
    publish: "80:80"
    network: "web_network"
    env: "NGINX_HOST=docker_swarm1"
```

## Available Commands

### VM Management

```bash
make create-multiple-vms      # Create all VMs
make create-vm                # Create single VM (legacy)
make configure-vms            # Configure all VMs
make ping-vms                 # Test connectivity
make list-vms                 # List all VMs
make vm-status                # Show VM status
make vm-cleanup               # Clean up VMs
```

### Docker Swarm Management

```bash
make init-swarm               # Initialize Swarm manager
make join-swarm               # Join workers to Swarm
make setup-swarm              # Complete Swarm setup
make swarm-status             # Show cluster status
make deploy-services          # Deploy services
make create-networks          # Create networks
make leave-swarm              # Leave Swarm
```

### Utilities

```bash
make check-syntax             # Validate playbooks
make help                     # Show all commands
```

## Project Structure Details

### Roles

**vm-manager**: Handles VM provisioning and lifecycle
- Creates VMs using virt-install
- Manages cloud-init configuration
- Updates inventory files
- Handles disk images and workspace

**docker_swarm**: Manages Docker Swarm cluster
- Initializes Swarm on manager
- Joins workers to cluster
- Creates overlay networks
- Deploys services
- Handles token management

**common**: Base system configuration
- System updates
- Common packages
- Basic security settings

**docker**: Docker installation and configuration
- Docker CE installation
- Docker daemon configuration
- User permissions

### Inventory Management

The project uses a dynamic inventory system:
- `created_vms.yml`: Master inventory of all provisioned VMs
- Automatically updated when VMs are created/destroyed
- Proper YAML structure validated by yamllint
- Supports both individual and bulk operations

## Troubleshooting

### Common Issues

1. **VM Creation Fails**
   ```bash
   # Check virtualization support
   kvm-ok
   
   # Verify libvirt services
   sudo systemctl status libvirtd
   ```

2. **SSH Connection Issues**
   ```bash
   # Check SSH keys
   ssh-keygen -l -f ~/.ssh/id_rsa.pub
   
   # Test connectivity manually
   ssh -i ~/.ssh/id_rsa ubuntu@<VM_IP>
   ```

3. **Docker Swarm Issues**
   ```bash
   # Check Swarm status
   make swarm-status
   
   # Manual verification
   ssh ubuntu@192.168.122.101 "docker node ls"
   ```

4. **Template Syntax Errors**
   - Fixed by using shell commands instead of Docker Go templates
   - Use yamllint to validate YAML files

### Debug Commands

```bash
# Check VM status
make vm-status

# Verify inventory
make show-inventory

# Validate playbooks
make check-syntax

# Test individual VMs
make ping-vm VM=docker_swarm1
```

## Development

### Adding New VMs

1. Update `roles/vm-manager/defaults/main.yml`
2. Add VM configuration to the `vms` dictionary
3. Run `make create-multiple-vms`

### Adding New Services

1. Update `setup_docker_swarm.yml`
2. Add service configuration to `swarm_services`
3. Run `make deploy-services`

### Code Quality

```bash
# Lint YAML files
yamllint .

# Lint Ansible playbooks
ansible-lint

# Validate syntax
make check-syntax
```

## Contributing

1. Follow the existing code structure
2. Update documentation for new features
3. Test changes with `make check-syntax`
4. Update README.md for significant changes

## License

This project is provided as-is for educational and development purposes.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Verify VM status with `make vm-status`
3. Check Swarm status with `make swarm-status`
4. Review logs for specific error messages

