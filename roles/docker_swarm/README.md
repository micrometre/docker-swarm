# Docker Swarm Ansible Role

This Ansible role manages Docker Swarm clusters, including initialization, node joining, network creation, and service deployment.

## Requirements

- Docker must be installed on target hosts
- Ansible 2.9+ 
- Root or sudo privileges

## Quick Start with Makefile

```bash
# Complete Swarm setup (init manager + join worker)
make setup-swarm

# Or step by step:
make init-swarm    # Initialize docker_swarm1 as manager
make join-swarm    # Join docker_swarm2 as worker
make swarm-status  # Verify cluster status
```

```bash
# Deploy services
make deploy-repo REPO=https://github.com/docker/example-voting-app.git
make deploy-repo REPO=file:///path/to/local/stack STACK=dev-app
make deploy-repo \
  REPO=https://github.com/company/prod-app.git \
  STACK=production \
  BRANCH=main \
  CLEANUP=true
```


## Current VM Configuration

This role is configured to work with the following VM setup:
- **docker_swarm1**: Manager node (192.168.122.101)
- **docker_swarm2**: Worker node (192.168.122.102)

## Role Variables

### Swarm Configuration
- `swarm_advertise_addr`: IP address to advertise (default: `{{ ansible_default_ipv4.address }}`)
- `swarm_listen_addr`: Listen address (default: `0.0.0.0`)
- `swarm_data_path_port`: Data path port (default: 4789)
- `swarm_default_addr_pool`: Default address pool (default: `10.0.0.0/8`)
- `swarm_default_addr_pool_subnet`: Default subnet mask (default: `24`)

### Node Configuration
- `swarm_node_role`: Node role - "manager" or "worker" (default: "worker")
- `swarm_node_labels`: Dictionary of node labels (default: [])
- `swarm_node_availability`: Node availability - "active", "pause", or "drain" (default: "active")

### Manager Configuration
- `swarm_manager_nodes`: List of manager nodes (default: [])
- `swarm_manager_count`: Number of managers (default: 1)
- `swarm_raft_heartbeat`: Raft heartbeat interval (default: 5)
- `swarm_raft_election_timeout`: Raft election timeout (default: 10)

### Tokens
- `swarm_worker_token`: Worker join token (auto-generated and shared via file)
- `swarm_manager_token`: Manager join token (auto-generated and shared via file)

### Network Configuration
- `swarm_networks`: List of networks to create (default: [])
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

### Service Configuration
- `swarm_services`: List of services to deploy (default: [])
```yaml
swarm_services:
  - name: "nginx_service"
    image: "nginx:alpine"
    replicas: 2
    publish: "80:80"
    network: "web_network"
    env: "NGINX_HOST=docker_swarm1"
    update: false
  - name: "redis_service"
    image: "redis:alpine"
    replicas: 1
    network: "db_network"
    update: false
```

## Implementation Notes

### Token Management
The role uses a file-based token sharing mechanism to handle cross-host token distribution:
- Tokens are saved to `/tmp/swarm_tokens.yml` on localhost during initialization
- Worker nodes load tokens from this file when joining the Swarm
- This approach avoids Ansible host variable access issues

### Template Syntax Fix
Due to Ansible Jinja2 template conflicts with Docker Go templates, the role uses:
- Shell commands with grep/awk for Swarm status checks
- Standard Docker CLI commands without `--format` templates
- This prevents "Syntax error in template: unexpected '.'" errors

### Role-Based Command Execution
Manager-only commands (like `docker node ls`, `docker service ls`) only execute on manager nodes to prevent permission errors on workers.

## Example Playbook

```yaml
---
- name: Initialize Docker Swarm Manager
  hosts: docker_swarm1
  become: true
  vars:
    swarm_node_role: "manager"
    swarm_networks:
      - name: "web_network"
        subnet: "10.10.0.0/24"
        gateway: "10.10.0.1"
    swarm_services:
      - name: "nginx_service"
        image: "nginx:alpine"
        replicas: 2
        publish: "80:80"
        network: "web_network"
  roles:
    - docker_swarm

- name: Join Workers to Docker Swarm
  hosts: docker_swarm2
  become: true
  vars:
    swarm_node_role: "worker"
    swarm_advertise_addr: "192.168.122.101"
  roles:
    - docker_swarm
```

## Tags

- `swarm_init`: Initialize Swarm
- `swarm_join`: Join existing Swarm
- `swarm_configure`: Configure node
- `swarm_networks`: Create networks
- `swarm_services`: Deploy services
- `swarm_status`: Show status
- `swarm_leave`: Leave Swarm

## Usage Examples

### Initialize a new Swarm cluster
```bash
ansible-playbook -i inventory/created_vms.yml setup_docker_swarm.yml --tags swarm_init
```

### Add workers to existing Swarm
```bash
ansible-playbook -i inventory/created_vms.yml setup_docker_swarm.yml --tags swarm_join
```

### Deploy services
```bash
ansible-playbook -i inventory/created_vms.yml setup_docker_swarm.yml --tags swarm_services
```

### Check Swarm status
```bash
ansible-playbook -i inventory/created_vms.yml setup_docker_swarm.yml --tags swarm_status
```

### Leave Swarm
```bash
ansible-playbook -i inventory/created_vms.yml setup_docker_swarm.yml --tags swarm_leave
```

## Makefile Commands

```bash
# Docker Swarm management
make init-swarm        # Initialize Swarm on manager
make join-swarm        # Join workers to Swarm
make setup-swarm       # Complete Swarm setup (init + join)
make swarm-status      # Show Swarm status and info
make leave-swarm       # Leave Swarm cluster
make deploy-services   # Deploy services
make create-networks   # Create Swarm networks
```

## Troubleshooting

### Common Issues

1. **Template Syntax Errors**: Fixed by using shell commands instead of Docker Go templates
2. **Token Access Issues**: Resolved with file-based token sharing
3. **Manager Command Errors**: Fixed by role-based command execution
4. **Cross-host Variable Access**: Solved using static IP addresses and file-based sharing

### Verification Commands

```bash
# Check cluster status
make swarm-status

# Manual verification
ssh ubuntu@192.168.122.101 "docker node ls"
ssh ubuntu@192.168.122.102 "docker info | grep Swarm"
```

## Current Cluster Status

The role maintains a working Docker Swarm cluster with:
- 1 manager node (docker_swarm1)
- 1 worker node (docker_swarm2)
- Overlay networks ready for service deployment
- Token management for scaling to additional nodes
