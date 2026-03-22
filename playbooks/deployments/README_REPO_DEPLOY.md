# Deploy from Git Repository

This feature allows you to deploy Docker stacks directly from Git repositories containing Docker Compose files.

## 🚀 Quick Start

```bash
# Deploy from a public repository
make deploy-repo REPO=https://github.com/docker/example-voting-app.git

# Deploy with custom parameters
make deploy-repo REPO=https://github.com/user/repo.git STACK=my-app COMPOSE=docker-compose.yml BRANCH=develop

# Deploy and cleanup after
make deploy-repo REPO=https://github.com/user/repo.git CLEANUP=true
```

## 📋 Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `REPO` | `https://github.com/docker/example-voting-app.git` | Git repository URL |
| `BRANCH` | `main` | Git branch or tag to checkout |
| `STACK` | `voting-app` | Name for the Docker stack |
| `COMPOSE` | `docker-stack.yml` | Compose file name in repository |
| `CLEANUP` | `false` | Clean up deployment directory after deploy |

## 🔧 Usage Examples

### Basic Deployment
```bash
make deploy-repo REPO=https://github.com/docker/example-voting-app.git
```

### Custom Stack Name
```bash
make deploy-repo REPO=https://github.com/docker/example-voting-app.git STACK=my-voting-app
```

### Different Branch
```bash
make deploy-repo REPO=https://github.com/docker/example-voting-app.git BRANCH=develop
```

### Custom Compose File
```bash
make deploy-repo REPO=https://github.com/user/repo.git COMPOSE=docker-compose.yml
```

### Private Repository (with SSH key)
```bash
make deploy-repo REPO=git@github.com:user/private-repo.git
```

### Cleanup After Deployment
```bash
make deploy-repo REPO=https://github.com/docker/example-voting-app.git CLEANUP=true
```

## 📁 Repository Structure

The repository should contain a Docker Compose file compatible with Docker Swarm:

```
your-repo/
├── docker-stack.yml          # Main compose file
├── docker-compose.yml        # Alternative compose file
├── README.md                  # Documentation
└── other-files/              # Supporting files
```

## 🐳 Compose File Requirements

The compose file should be Swarm-compatible:

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure
    networks:
      - frontend

networks:
  frontend:
    driver: overlay
```

### Key Requirements:
- **Version**: Use `3.8` or higher
- **Deploy Section**: Each service should have a `deploy` section
- **Networks**: Use overlay networks for multi-service communication
- **Ports**: Specify port mappings for external access

## 🔍 What the Playbook Does

1. **Install Git**: Ensures git is available on the manager node
2. **Clone Repository**: Downloads the repository to `/tmp/<stack-name>`
3. **Validate Stack File**: Checks if the compose file exists
4. **Deploy Stack**: Uses `docker stack deploy` to deploy services
5. **Show Services**: Lists deployed services and their status
6. **Optional Cleanup**: Removes the cloned repository if requested

## 📊 Example Output

```bash
$ make deploy-repo REPO=https://github.com/docker/example-voting-app.git

PLAY [Deploy Stack from Git Repository] *************************

TASK [Display stack file content] *******************************
ok: [docker_swarm1] => {
    "msg": "Found stack file: docker-stack.yml"
}

TASK [Deploy Docker Stack] **************************************
changed: [docker_swarm1]

TASK [Display deployment result] ********************************
ok: [docker_swarm1] => {
    "msg": "Stack deployment completed!\nStack: voting-app\nRepository: https://github.com/docker/example-voting-app.git\nBranch: main\nCompose File: docker-stack.yml\nResult: SUCCESS"
}

TASK [Show stack services] **************************************
changed: [docker_swarm1]

TASK [Display stack services] **********************************
ok: [docker_swarm1] => {
    "msg": [
        "ID                  NAME                MODE                REPLICAS            IMAGE               PORT",
        "q7x8y9z1a2b3c       voting-app_visualizer replicated          1/1                 dockersamples/visualizer:stable   *:8083->8080/tcp",
        "r4s5t6u7v8w9x       voting-app_redis      replicated          1/1                 redis:alpine",
        "s1t2u3v4w5x6y       voting-app_db        replicated          1/1                 postgres:9.4",
        "t7u8v9w0x1y2z       voting-app_result    replicated          1/1                 dockersamples/examplevotingapp_result:latest",
        "u2v3w4x5y6z7a       voting-app_vote      replicated          2/2                 dockersamples/examplevotingapp_vote:before",
        "v8w9x0y1z2a3b       voting-app_worker    replicated          1/1                 dockersamples/examplevotingapp_worker:latest",
        "w3x4y5z6a7b8c       voting-app_web       replicated          2/2                 dockersamples/examplevotingapp_vote:before   *:5000->80/tcp"
    ]
}
```

## 🛠️ Advanced Usage

### Environment Variables
You can pass environment variables to the stack by modifying the compose file or using Ansible variables:

```yaml
services:
  web:
    image: nginx:alpine
    environment:
      - "ENVIRONMENT=${ENVIRONMENT:-production}"
      - "DEBUG=${DEBUG:-false}"
```

### Secrets and Configs
For production deployments, use Docker secrets:

```yaml
services:
  web:
    image: nginx:alpine
    secrets:
      - ssl_cert
      - ssl_key

secrets:
  ssl_cert:
    external: true
  ssl_key:
    external: true
```

### Placement Constraints
Control where services run:

```yaml
services:
  database:
    image: postgres:13
    deploy:
      placement:
        constraints:
          - "node.role == manager"
          - "node.labels.database == true"
```

## 🔧 Troubleshooting

### Common Issues

1. **Repository Not Found**
   ```
   fatal: [docker_swarm1]: FAILED! => Repository not found
   ```
   **Solution**: Check the repository URL and ensure it's accessible

2. **Stack File Not Found**
   ```
   fatal: [docker_swarm1]: FAILED! => Stack file not found
   ```
   **Solution**: Verify the compose file name and path in the repository

3. **Deploy Failed**
   ```
   fatal: [docker_swarm1]: FAILED! => docker stack deploy failed
   ```
   **Solution**: Check the compose file syntax and ensure images exist

### Debug Commands

```bash
# Check stack status
docker stack ls

# List stack services
docker stack services <stack-name>

# Check service logs
docker service logs <service-name>

# Remove stack
docker stack rm <stack-name>
```

## 📚 Examples

### Example 1: Simple Web App
```bash
make deploy-repo REPO=https://github.com/docker/example-voting-app.git STACK=voting-app
```

### Example 2: Custom Configuration
```bash
make deploy-repo \
  REPO=https://github.com/company/production-app.git \
  STACK=prod-app \
  COMPOSE=docker-compose.prod.yml \
  BRANCH=main \
  CLEANUP=true
```

### Example 3: Development Environment
```bash
make deploy-repo \
  REPO=https://github.com/user/dev-app.git \
  STACK=dev-app \
  BRANCH=feature/new-ui \
  COMPOSE=docker-compose.dev.yml
```

## 🎯 Best Practices

1. **Use Specific Tags**: Pin image versions for reproducible deployments
2. **Health Checks**: Add health checks to your services
3. **Resource Limits**: Set memory and CPU limits in the deploy section
4. **Network Isolation**: Use separate networks for different service tiers
5. **Secrets Management**: Use Docker secrets for sensitive data
6. **Rollback Strategy**: Configure update strategies for zero-downtime deployments

## 🔄 Integration with CI/CD

This playbook can be integrated into CI/CD pipelines:

```bash
# GitHub Actions example
- name: Deploy to Docker Swarm
  run: |
    make deploy-repo \
      REPO=${{ github.repository }} \
      STACK=${{ github.ref_name }} \
      BRANCH=${{ github.ref_name }} \
      CLEANUP=true
```

## 📝 Notes

- The deployment runs on the Swarm manager node (docker_swarm1)
- Temporary files are stored in `/tmp/<stack-name>`
- Git authentication uses the system's default SSH configuration
- The playbook supports both HTTP and HTTPS repositories
- Private repositories require proper SSH key setup
