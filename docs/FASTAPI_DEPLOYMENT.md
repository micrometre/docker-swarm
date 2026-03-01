# FastAPI Deployment Guide

This guide covers the deployment of FastAPI applications using the Docker Swarm Ansible project, including both the ANPR application and private FastAPI repositories.

## 🚀 Quick Start

```bash
# Deploy both FastAPI applications
make deploy-fastapi
```

## 📋 Overview

The FastAPI deployment playbook handles:
- **ANPR Application**: Clones and deploys the FastAPI ANPR repository
- **Private FastAPI App**: Clones and deploys a private FastAPI repository with Docker containerization
- **Docker Setup**: Automatically creates Dockerfiles, docker-compose.yml, and builds containers
- **Health Monitoring**: Performs health checks and displays application status

## 🔧 Prerequisites

### 1. SSH Key Setup
Ensure SSH keys are properly configured for GitHub access:

```bash
# Generate SSH key if not exists
ssh-keygen -t ed25519 -C "your-email@example.com"

# Add SSH key to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Add public key to GitHub account
cat ~/.ssh/id_ed25519.pub
```

### 2. Inventory Configuration
The deployment uses the existing `inventory/created_vms.yml` file. For reference, see `inventory/local_vms_fastapi.yml.example`:

```yaml
---
all:
  children:
    created_vms:
      hosts:
        docker_swarm1:
          ansible_host: 192.168.122.101
          ansible_user: ubuntu
          ansible_ssh_private_key_file: "~/.ssh/id_rsa"
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
        docker_swarm2:
          ansible_host: 192.168.122.102
          ansible_user: ubuntu
          ansible_ssh_private_key_file: "~/.ssh/id_rsa"
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
```

### 3. Repository Access
- Ensure you have access to the ANPR repository: `git@github.com:micrometre/fastapi-anpr.git`
- Update the private repository URL in variables if needed

## 📁 Playbook Structure

### Variables
```yaml
vars:
  app_dir: /home/ubuntu/repos/fastapi-anpr
  fastapi_dir: /home/ubuntu/repos/fastapi-app
  github_user: micrometre
  fastapi_repo_url: "git@github.com:{{ github_user }}/fastapi-private-repo.git"
  fastapi_repo_branch: "main"
  app_port: 8000
  exposed_port: 8000
```

### Tasks Overview
1. **Directory Setup**: Creates required directories and cleans up existing deployments
2. **Repository Cloning**: Clones both ANPR and private FastAPI repositories
3. **Docker Configuration**: Creates Dockerfile and docker-compose.yml for private app
4. **Container Deployment**: Builds and runs Docker containers
5. **Health Monitoring**: Performs health checks and displays status
6. **Logging**: Shows application logs and deployment summary

## 🚀 Deployment Process

### Step 1: Repository Cloning
```yaml
- name: Clone ANPR application repository
  git:
    repo: "git@github.com:{{github_user}}/fastapi-anpr.git"
    dest: "{{ app_dir }}"
    version: azure
    accept_hostkey: yes

- name: Clone private FastAPI repository
  git:
    repo: "{{ fastapi_repo_url }}"
    dest: "{{ fastapi_dir }}"
    version: "{{ fastapi_repo_branch }}"
    accept_hostkey: yes
```

### Step 2: Docker Configuration
The playbook automatically creates:

#### Dockerfile
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### docker-compose.yml
```yaml
version: '3.8'

services:
  fastapi-app:
    build: .
    ports:
      - "8000:8000"
    environment:
      - ENVIRONMENT=production
      - DEBUG=false
    restart: unless-stopped
    container_name: fastapi-app
    networks:
      - fastapi-network

networks:
  fastapi-network:
    driver: bridge
```

#### requirements.txt
```txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
python-multipart==0.0.6
```

### Step 3: Container Deployment
```bash
cd /home/ubuntu/repos/fastapi-app
docker-compose down
docker-compose build
docker-compose up -d
```

### Step 4: Health Monitoring
- Waits for application startup (10 seconds)
- Checks container status
- Performs HTTP health check on `/health` endpoint
- Displays application logs

## 📊 Deployment Output

### Success Example
```
========================================
FastAPI Applications Deployed Successfully!
========================================

ANPR Application:
- Directory: /home/ubuntu/repos/fastapi-anpr
- Repository: git@github.com:micrometre/fastapi-anpr.git
- Branch: azure

FastAPI Private Application:
- Directory: /home/ubuntu/repos/fastapi-app
- Repository: git@github.com:micrometre/fastapi-private-repo.git
- Branch: main
- Port: 8000
- Health: UP

Access URLs:
- FastAPI App: http://<vm-ip>:8000
- FastAPI Docs: http://<vm-ip>:8000/docs
- FastAPI Health: http://<vm-ip>:8000/health

========================================
```

## 🔧 Customization

### Changing Repository Details
Update the variables in the playbook:

```yaml
vars:
  fastapi_repo_url: "git@github.com:your-user/your-private-repo.git"
  fastapi_repo_branch: "develop"
  exposed_port: 8080
```

### Custom Dockerfile
If your repository already has a Dockerfile, the playbook will use it. Otherwise, it creates a default one.

### Custom Requirements
If your repository has `requirements.txt`, it will be used. Otherwise, a default one is created.

### Environment Variables
Add custom environment variables in the docker-compose task:

```yaml
environment:
  - ENVIRONMENT=production
  - DEBUG=false
  - DATABASE_URL=postgresql://user:pass@localhost/db
  - API_KEY=your-api-key
```

## 🔍 Troubleshooting

### Common Issues

#### SSH Key Authentication
```
Permission denied (publickey)
```
**Solution**: Ensure SSH keys are properly configured and added to GitHub.

#### Repository Not Found
```
fatal: repository 'git@github.com:user/repo.git' not found
```
**Solution**: Check repository URL and ensure you have access.

#### Docker Build Failures
```
failed to solve: process "/bin/sh -c pip install" didn't complete
```
**Solution**: Check requirements.txt and ensure all dependencies are available.

#### Port Conflicts
```
port is already allocated
```
**Solution**: Change `exposed_port` variable to use a different port.

#### Health Check Failures
```
Status: DOWN
```
**Solution**: 
1. Check if application has `/health` endpoint
2. Verify application logs
3. Ensure port is accessible

### Debug Commands

```bash
# Check container status
docker-compose ps

# View application logs
docker-compose logs fastapi-app

# Check container logs in detail
docker-compose logs fastapi-app --tail=50

# Access container shell
docker-compose exec fastapi-app bash

# Test application locally
curl http://localhost:8000/health

# Check network connectivity
docker network ls
docker network inspect fastapi_fastapi-network
```

### Recovery Procedures

#### Complete Redeploy
```bash
# Clean up and redeploy
make deploy-fastapi
```

#### Manual Container Management
```bash
# SSH to the VM
ssh ubuntu@<vm-ip>

# Navigate to app directory
cd /home/ubuntu/repos/fastapi-app

# Stop containers
docker-compose down

# Rebuild and start
docker-compose build --no-cache
docker-compose up -d

# Check status
docker-compose ps
```

## Integration with Other Commands

### VM Management
```bash
# Power on local VMs
make power-on-vms

# Deploy FastAPI applications
make deploy-fastapi

# Check VM connectivity
make ping-vms

# Check VM status
make vm-status
```

### Service Management
```bash
# List running services
make list-services

# Check Docker containers
docker ps
```

### Monitoring
```bash
# Check application health
curl http://<vm-ip>:8000/health

# View API documentation
curl http://<vm-ip>:8000/docs
```

## 🎯 Best Practices

1. **SSH Key Management**: Use SSH keys for repository access, not HTTPS with tokens
2. **Environment Variables**: Store sensitive data in environment variables, not in code
3. **Health Endpoints**: Always implement `/health` endpoints for monitoring
4. **Logging**: Use structured logging for better debugging
5. **Resource Limits**: Set memory and CPU limits in docker-compose.yml
6. **Network Security**: Use proper network segmentation and firewall rules
7. **Backup Strategy**: Regularly backup application data and configurations

## 🔗 Related Commands

- `make power-on-vms` - Power on VMs before deployment
- `make ping-vms` - Check VM connectivity
- `make list-services` - List running services
- `make vm-status` - Check VM status

## 📝 Notes

- The playbook uses `become: true` for system-level operations
- Docker operations run as the `ubuntu` user for security
- All directories are created with proper permissions
- The deployment is idempotent and can be run multiple times
- Health checks are optional and won't fail the deployment if not available

## 🚀 Production Considerations

For production deployments:

1. **SSL/TLS**: Configure HTTPS with proper certificates
2. **Load Balancing**: Use multiple instances behind a load balancer
3. **Monitoring**: Set up proper monitoring and alerting
4. **Logging**: Configure centralized logging
5. **Backups**: Implement regular backup strategies
6. **Security**: Configure proper firewall rules and access controls
7. **Scaling**: Use Docker Swarm or Kubernetes for auto-scaling
