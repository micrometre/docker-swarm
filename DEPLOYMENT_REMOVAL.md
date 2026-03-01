# Deployment Removal Guide

This guide covers all the commands and procedures for removing deployments, services, and cleaning up resources in the Docker Swarm Ansible project.

## 🚀 Quick Removal Commands

```bash
# Remove FastAPI deployments
make remove-fastapi

# Remove specific service
make remove-service NAME=nginx_test

# Remove all services
make remove-all-services

# Remove specific stack
make remove-specific-stack STACK=sample-app

# Clean up Docker resources
make cleanup-docker

# Remove deployment directories
make cleanup-deployments
```

## 📋 Available Removal Commands

### FastAPI Deployment Removal

#### `remove-fastapi`
Removes FastAPI ANPR and private FastAPI deployments including containers, images, and directories.

```bash
make remove-fastapi
```

**What it removes:**
- FastAPI Docker containers (stopped and running)
- FastAPI Docker images
- Build cache
- Application directories (`/home/ubuntu/repos/fastapi-anpr`, `/home/ubuntu/repos/fastapi-app`)

**Output:**
```
========================================
FastAPI Applications Cleanup Completed!
========================================

Cleaned up:
- FastAPI ANPR directory: /home/ubuntu/repos/fastapi-anpr
- FastAPI Private App directory: /home/ubuntu/repos/fastapi-app
- Docker containers and images
- Build cache

========================================
```

### Service Removal

#### `remove-service`
Removes a specific Docker Swarm service.

```bash
make remove-service NAME=<service_name>
```

**Example:**
```bash
make remove-service NAME=nginx_test
```

**What it does:**
- Checks if service exists
- Removes the service from Swarm
- Displays removal confirmation

#### `remove-all-services`
Removes all Docker Swarm services.

```bash
make remove-all-services
```

**What it does:**
- Lists all current services
- Removes each service individually
- Shows removal progress
- Displays final status

**Output:**
```
Removing service: nginx_test
Removing service: sample-app_web
Removing service: sample-app_api
...
All services removed successfully!
```

### Stack Removal

#### `remove-specific-stack`
Removes a specific Docker Swarm stack.

```bash
make remove-specific-stack STACK=<stack_name>
```

**Example:**
```bash
make remove-specific-stack STACK=sample-app
```

**What it does:**
- Removes the entire stack and all its services
- Validates stack exists before removal
- Shows removal status

### Docker Resource Cleanup

#### `cleanup-docker`
Cleans up unused Docker resources to free up disk space.

```bash
make cleanup-docker
```

**What it cleans:**
- Stopped containers
- Unused images
- Unused networks
- Unused volumes
- Build cache

**Output:**
```
Cleaning up unused Docker resources...
Removing stopped containers...
Total reclaimed space: 1.2GB
Removing unused images...
Total reclaimed space: 2.5GB
Removing unused networks...
Removing unused volumes...
Total reclaimed space: 500MB
Cleaning up build cache...
Total reclaimed space: 800MB
Docker cleanup completed!
```

#### `cleanup-deployments`
Removes deployment directories and temporary files.

```bash
make cleanup-deployments
```

**What it cleans:**
- FastAPI deployment directories
- Voting app deployment directories
- Sample app deployment directories
- Temporary deployment files

**Output:**
```
Cleaning up deployment directories...
Removing FastAPI ANPR directory...
Removing FastAPI app directory...
Removing voting-app deployment directory...
Removing sample-app deployment directory...
Deployment directories cleanup completed!
```

## 🔧 Advanced Removal Procedures

### Complete Application Removal

For complete removal of an application deployment:

```bash
# 1. Remove the stack/services
make remove-specific-stack STACK=sample-app

# 2. Clean up Docker resources
make cleanup-docker

# 3. Remove deployment directories
make cleanup-deployments

# 4. Verify cleanup
make list-services
```

### FastAPI Complete Removal

```bash
# 1. Remove FastAPI deployment
make remove-fastapi

# 2. Clean up any remaining Docker resources
make cleanup-docker

# 3. Verify no containers running
docker ps
```

### Environment Reset

To completely reset the environment:

```bash
# 1. Remove all services
make remove-all-services

# 2. Clean up Docker resources
make cleanup-docker

# 3. Remove deployment directories
make cleanup-deployments

# 4. Leave and reset Swarm (optional)
make leave-swarm

# 5. Power down VMs (optional)
make shutdown-vms
```

## 📊 Removal Verification

### Check Services After Removal
```bash
# List remaining services
make list-services

# Check Docker containers
docker ps

# Check Docker images
docker images

# Check Docker volumes
docker volume ls
```

### Verify Disk Space
```bash
# Check disk usage before and after cleanup
df -h

# Check Docker disk usage
docker system df

# Detailed Docker usage
docker system df -v
```

## ⚠️ Safety Considerations

### Before Removal
1. **Backup Important Data**: Ensure important data is backed up
2. **Check Dependencies**: Verify no other services depend on the target
3. **Save Configurations**: Export any important configurations
4. **Document State**: Note current deployment state before removal

### During Removal
1. **Monitor Progress**: Watch removal output for errors
2. **Verify Completion**: Ensure all components are removed
3. **Check Resources**: Verify resources are actually freed

### After Removal
1. **Verify Cleanup**: Confirm no orphaned resources remain
2. **Check Functionality**: Ensure remaining services still work
3. **Monitor Performance**: Verify system performance improves

## 🔍 Troubleshooting Removal Issues

### Common Issues

#### Service Removal Fails
```
Error: service is in use
```
**Solution:**
```bash
# Scale service to 0 first
make scale-service NAME=service_name REPLICAS=0

# Then remove
make remove-service NAME=service_name
```

#### Docker Resource Cleanup Fails
```
Error: resource is in use
```
**Solution:**
```bash
# Stop all containers first
docker stop $(docker ps -q)

# Force cleanup
docker system prune -f --volumes

# Retry cleanup
make cleanup-docker
```

#### Directory Removal Fails
```
Error: permission denied
```
**Solution:**
```bash
# SSH to VM and manually remove
ssh ubuntu@<vm-ip>
sudo rm -rf /home/ubuntu/repos/fastapi-*
```

#### Stack Removal Fails
```
Error: stack not found
```
**Solution:**
```bash
# List available stacks
docker stack ls

# Use correct stack name
make remove-specific-stack STACK=correct_name
```

### Recovery Procedures

#### Accidental Service Removal
```bash
# Redeploy the service
make deploy-nginx

# Or redeploy full stack
make deploy-stack
```

#### Accidental Stack Removal
```bash
# Redeploy the stack
make deploy-repo REPO=<repository_url> STACK=<stack_name>
```

#### Partial Cleanup
```bash
# Force complete cleanup
docker system prune -a -f --volumes

# Remove directories manually
ssh ubuntu@<vm-ip>
sudo rm -rf /home/ubuntu/repos/*
```

## 🎯 Best Practices

### Regular Maintenance
```bash
# Weekly cleanup routine
make cleanup-docker
make cleanup-deployments
```

### Before New Deployments
```bash
# Clean up before deploying new applications
make remove-all-services
make cleanup-docker
make cleanup-deployments
```

### Development Environment
```bash
# Quick reset for development
make remove-all-services
make cleanup-docker
```

### Production Environment
```bash
# Careful production cleanup
make remove-service NAME=old_service
make cleanup-docker
```

## 📚 Integration with Other Commands

### Complete Deployment Lifecycle
```bash
# Deploy
make deploy-fastapi

# Check status
make list-services

# Remove when done
make remove-fastapi

# Clean up
make cleanup-docker
```

### Testing Workflow
```bash
# Deploy for testing
make deploy-nginx

# Test
curl http://<vm-ip>:8080

# Remove test deployment
make remove-service NAME=nginx_test

# Clean up
make cleanup-docker
```

### Environment Reset
```bash
# Complete reset
make remove-all-services
make cleanup-docker
make cleanup-deployments
make leave-swarm
```

## 🔗 Related Commands

- `make list-services` - List current services
- `make deploy-*` - Deploy various applications
- `make vm-*` - VM management commands
- `make power-*` - VM power management

## 📝 Notes

- All removal commands are idempotent and safe to run multiple times
- Removal operations are irreversible - ensure you want to remove the target
- Some removal operations may take time for large deployments
- Always verify removal success before proceeding with other operations
- Docker cleanup frees significant disk space but removes unused resources permanently
