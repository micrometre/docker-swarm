# VM Power Management

This document describes the VM power management commands available in the Docker Swarm Ansible project.

## 🚀 Quick Start

```bash
# Power on all VMs
make power-on-vms

# Power on specific VM
make power-on-vm VM=docker_swarm1

# Gracefully shutdown all VMs
make shutdown-vms

# Gracefully shutdown specific VM
make shutdown-vm VM=docker_swarm1

# Restart all VMs
make restart-vms

# Restart specific VM
make restart-vm VM=docker_swarm1

# Force shutdown all VMs (emergency)
make force-shutdown-vms

# Force shutdown specific VM (emergency)
make force-shutdown-vm VM=docker_swarm1
```

## 📋 Available Commands

### Power On Commands

#### `power-on-vms`
Power on all VMs listed in the inventory.

```bash
make power-on-vms
```

**Output:**
```
Powering on all VMs...
Powering on docker_swarm1...
Domain 'docker_swarm1' started
Powering on docker_swarm2...
Domain 'docker_swarm2' started
```

#### `power-on-vm`
Power on a specific VM.

```bash
make power-on-vm VM=<vm_name>
```

**Example:**
```bash
make power-on-vm VM=docker_swarm1
```

**Output:**
```
Powering on VM docker_swarm1...
Domain 'docker_swarm1' started
```

### Shutdown Commands

#### `shutdown-vms`
Gracefully shutdown all VMs.

```bash
make shutdown-vms
```

**Output:**
```
Shutting down all VMs...
Shutting down docker_swarm1...
Domain 'docker_swarm1' is being shutdown
Shutting down docker_swarm2...
Domain 'docker_swarm2' is being shutdown
```

#### `shutdown-vm`
Gracefully shutdown a specific VM.

```bash
make shutdown-vm VM=<vm_name>
```

**Example:**
```bash
make shutdown-vm VM=docker_swarm1
```

**Output:**
```
Shutting down VM docker_swarm1...
Domain 'docker_swarm1' is being shutdown
```

### Restart Commands

#### `restart-vms`
Restart all VMs with graceful shutdown and startup.

```bash
make restart-vms
```

**Output:**
```
Restarting all VMs...
Restarting docker_swarm1...
Domain 'docker_swarm1' is being rebooted
Restarting docker_swarm2...
Domain 'docker_swarm2' is being rebooted
```

#### `restart-vm`
Restart a specific VM with graceful shutdown and startup.

```bash
make restart-vm VM=<vm_name>
```

**Example:**
```bash
make restart-vm VM=docker_swarm1
```

**Output:**
```
Restarting VM docker_swarm1...
Domain 'docker_swarm1' is being rebooted
```

### Force Shutdown Commands

⚠️ **Warning:** These commands force immediate shutdown and may cause data loss.

#### `force-shutdown-vms`
Force shutdown all VMs immediately.

```bash
make force-shutdown-vms
```

**Output:**
```
Force shutting down all VMs...
Force shutting down docker_swarm1...
Domain 'docker_swarm1' destroyed
Force shutting down docker_swarm2...
Domain 'docker_swarm2' destroyed
```

#### `force-shutdown-vm`
Force shutdown a specific VM immediately.

```bash
make force-shutdown-vm VM=<vm_name>
```

**Example:**
```bash
make force-shutdown-vm VM=docker_swarm1
```

**Output:**
```
Force shutting down VM docker_swarm1...
Domain 'docker_swarm1' destroyed
```

## 🔧 Usage Examples

### Development Workflow

```bash
# Start your development environment
make power-on-vms

# Wait for VMs to boot
sleep 30

# Check VM connectivity
make ping-vms

# Configure VMs if needed
make configure-vms

# Setup Docker Swarm
make setup-swarm

# Deploy services
make deploy-nginx

# When done, gracefully shutdown
make shutdown-vms
```

### Production Maintenance

```bash
# Check current VM status
virsh list --all

# Restart specific VM for maintenance
make restart-vm VM=docker_swarm1

# Wait for VM to come back online
sleep 60

# Verify services are running
make swarm-status
make list-services

# If VM is unresponsive, force restart
make force-shutdown-vm VM=docker_swarm1
make power-on-vm VM=docker_swarm1
```

### Emergency Recovery

```bash
# Force shutdown all VMs (emergency situation)
make force-shutdown-vms

# Wait a moment
sleep 5

# Power on all VMs
make power-on-vms

# Reconfigure and restart services
make configure-vms
make setup-swarm
```

## 📊 VM Status Commands

### Check VM States

```bash
# List all VMs with their states
virsh list --all

# Show detailed VM information
virsh dominfo docker_swarm1

# Show VM resource usage
virsh domstats docker_swarm1

# Check VM network interfaces
virsh domiflist docker_swarm1
```

### Inventory Commands

```bash
# List all created VMs
make list-vms

# Show detailed inventory
make show-inventory

# Check VM connectivity
make ping-vms

# Ping specific VM
make ping-vm VM=docker_swarm1
```

## ⚠️ Important Notes

### Graceful vs Force Shutdown

- **Graceful Shutdown** (`shutdown-*`): Sends ACPI shutdown signal, allows OS to clean up
- **Force Shutdown** (`force-shutdown-*`): Immediately cuts power, may cause data loss

### Restart Behavior

- **Restart** commands attempt graceful reboot first
- If graceful reboot fails, they fallback to shutdown + start
- Includes timing delays to ensure proper shutdown/startup sequence

### VM Dependencies

- Docker Swarm manager should be started before workers
- Services may need time to initialize after VM startup
- Network connectivity may take a few moments to establish

### Error Handling

- Commands handle already running/stopped VMs gracefully
- Error messages indicate specific issues
- Failed operations don't stop other VM operations in bulk commands

## 🔍 Troubleshooting

### Common Issues

#### VM Won't Power On
```bash
# Check if VM exists
virsh list --all

# Check libvirt service
sudo systemctl status libvirtd

# Check VM configuration
virsh dominfo docker_swarm1
```

#### VM Won't Shutdown Gracefully
```bash
# Use force shutdown
make force-shutdown-vm VM=docker_swarm1

# Check if VM is frozen
virsh dominfo docker_swarm1

# Check VM console
virsh console docker_swarm1
```

#### Network Issues After Restart
```bash
# Wait for network to come up
sleep 30

# Check VM network interfaces
make ping-vm VM=docker_swarm1

# Restart network services
ansible-playbook -i inventory/created_vms.yml playbooks/setup/configure_vm.yml
```

### Recovery Procedures

#### Complete VM Recovery
```bash
# Force shutdown all VMs
make force-shutdown-vms

# Wait for complete shutdown
sleep 10

# Power on all VMs
make power-on-vms

# Wait for boot
sleep 60

# Reconfigure everything
make configure-vms
make setup-swarm

# Redeploy services
make deploy-nginx
```

#### Single VM Recovery
```bash
# Force shutdown problematic VM
make force-shutdown-vm VM=docker_swarm1

# Power it back on
make power-on-vm VM=docker_swarm1

# Wait for boot
sleep 30

# Reconfigure if needed
make configure-vm-specific VM=docker_swarm1

# Rejoin Swarm if needed
make join-swarm
```

## 📚 Integration with Other Commands

The power management commands integrate seamlessly with other project commands:

```bash
# Complete development cycle
make create-multiple-vms      # Create VMs
make power-on-vms             # Start VMs
make configure-vms            # Configure VMs
make setup-swarm              # Setup Swarm
make deploy-nginx             # Deploy services
make list-services            # Check services
make shutdown-vms             # Shutdown VMs
```

```bash
# Maintenance cycle
make shutdown-vms             # Stop VMs
# (perform maintenance)
make power-on-vms             # Start VMs
make swarm-status            # Verify cluster
make list-services            # Check services
```

## 🎯 Best Practices

1. **Use graceful shutdown** when possible to prevent data loss
2. **Wait for VMs to fully boot** before running dependent commands
3. **Check VM status** before and after power operations
4. **Use force shutdown only** when VMs are unresponsive
5. **Monitor services** after VM restarts to ensure they come back online
6. **Keep inventory updated** when adding/removing VMs
7. **Document maintenance windows** when restarting production VMs

## 🔗 Related Commands

- `make list-vms` - List all created VMs
- `make vm-status` - Show VM status and details
- `make ping-vms` - Check VM connectivity
- `make configure-vms` - Configure VM software
- `virsh list --all` - Show all VM states
- `virsh dominfo <vm>` - Show detailed VM information
