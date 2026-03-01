# Check playbook syntax
check-syntax:
	ansible-playbook --syntax-check main.yml

# Help - show available targets
help:
	@echo "Available targets:"
	@echo ""
	@echo "VM Creation:"
	@echo "  create-vm              - Create single VM (legacy mode)"
	@echo "  create-multiple-vms     - Create multiple VMs (docker_swarm, vm1, vm2)"
	@echo "  create-docker-swarm     - Create Docker Swarm cluster VMs"
	@echo "  custom_vm               - Create custom VM with specific settings"
	@echo "  create-vm-force         - Create single VM with force recreate"
	@echo "  create-multiple-vms-force - Create multiple VMs with force recreate"
	@echo ""
	@echo "VM Management:"
	@echo "  vm-status              - Show status of all VMs"
	@echo "  vm-cleanup             - Clean up VMs"
	@echo "  vm-overview            - Show workspace overview"
	@echo "  clean_full             - Complete cleanup of all VMs and storage"
	@echo ""
	@echo "VM Configuration:"
	@echo "  configure-vm           - Configure all created VMs"
	@echo "Docker Swarm:"
	@echo "  init-swarm             - Initialize Docker Swarm on manager"
	@echo "  join-swarm             - Join workers to Swarm"
	@echo "  setup-swarm            - Complete Swarm setup (init + join)"
	@echo "  swarm-status           - Show Swarm status and info"
	@echo "  leave-swarm            - Leave Swarm cluster"
	@echo "  deploy-services        - Deploy Swarm services"
	@echo "  deploy-nginx           - Deploy test Nginx service"
	@echo "  deploy-redis           - Deploy Redis services"
	@echo "  deploy-stack           - Deploy full application stack"
	@echo "  deploy-repo            - Deploy stack from Git repository"
	@echo "  create-networks        - Create Swarm networks"
	@echo ""
	@echo "Service Management:"
	@echo "  list-services          - List all Swarm services"
	@echo "  inspect-service        - Inspect service details (NAME=service_name)"
	@echo "  scale-service          - Scale service (NAME=service_name REPLICAS=n)"
	@echo "  remove-service         - Remove service (NAME=service_name)"
	@echo "  service-logs           - Show service logs (NAME=service_name)"
	@echo ""
	@echo "Inventory:"
	@echo "  list-vms               - List all created VMs"
	@echo "  show-inventory         - Show detailed inventory"
	@echo ""
	@echo "Utilities:"
	@echo "  check-syntax           - Validate playbook syntax"
	@echo "  vars                   - Show all variables"
	@echo "  setup-vm-full          - Setup virtualization and create VM"
	@echo ""
	@echo "Examples:"
	@echo "  make create-multiple-vms"
	@echo "  make ping-vm VM=docker_swarm1"
	@echo "  make configure-vm-specific VM=docker_swarm2"
	@echo "  make init-swarm"
	@echo "  make setup-swarm"
	@echo "  make swarm-status"
	@echo "  make deploy-nginx"
	@echo "  make list-services"
	@echo "  make scale-service NAME=nginx_test REPLICAS=3"
	@echo "  make deploy-repo REPO=https://github.com/user/repo.git"

.PHONY: help check-syntax create-vm create-multiple-vms create-docker-swarm custom_vm create-vm-force create-multiple-vms-force configure-vm configure-vm-specific ping-vms ping-vm list-vms show-inventory vm-status vm-cleanup vm-overview clean_full vars setup-vm-full init-swarm join-swarm setup-swarm swarm-status leave-swarm deploy-services deploy-nginx deploy-redis deploy-stack deploy-repo create-networks list-services inspect-service scale-service remove-service service-logs

# Create single VM (legacy mode)
create-vm:
	ansible-playbook -i inventory/inventory.yml main.yml --tags create_vm

# Create multiple VMs (docker_swarm, vm1, vm2)
create-multiple-vms:
	ansible-playbook -i inventory/inventory.yml main.yml --tags create_vm

# Create Docker Swarm cluster VMs
create-docker-swarm:
	ansible-playbook -i inventory/inventory.yml main.yml --tags create_vm

# Create VM with force recreate (useful for testing)
create-vm-force:
	ansible-playbook -i inventory/inventory.yml main.yml --tags create_vm -e "force_recreate=true"

# Create multiple VMs with force recreate
create-multiple-vms-force:
	ansible-playbook -i inventory/inventory.yml main.yml --tags create_vm -e "force_recreate=true"

setup-vm-full: setup-virtualization create-vm


# Initialize Docker Swarm on manager
init-swarm:
	ansible-playbook -i inventory/created_vms.yml playbooks/setup/setup_docker_swarm.yml --tags swarm_init

# Join workers to Swarm
join-swarm:
	ansible-playbook -i inventory/created_vms.yml playbooks/setup/setup_docker_swarm.yml --tags swarm_join

# Complete Swarm setup (init + join)
setup-swarm:
	ansible-playbook -i inventory/created_vms.yml playbooks/setup/setup_docker_swarm.yml

# Show Swarm status and info
swarm-status:
	ansible-playbook -i inventory/created_vms.yml playbooks/setup/setup_docker_swarm.yml --tags swarm_status

leave-swarm:
	ansible-playbook -i inventory/created_vms.yml playbooks/setup/setup_docker_swarm.yml --tags swarm_leave

deploy-services:
	ansible-playbook -i inventory/created_vms.yml playbooks/setup/setup_docker_swarm.yml --tags swarm_services

# Deploy test Nginx service
deploy-nginx:
	ansible-playbook -i inventory/created_vms.yml playbooks/deployments/deploy_nginx.yml

# Deploy Redis services
deploy-redis:
	ansible-playbook -i inventory/created_vms.yml playbooks/deployments/deploy_redis.yml

# Deploy full application stack
deploy-stack:
	ansible-playbook -i inventory/created_vms.yml playbooks/deployments/deploy_stack.yml

# Deploy stack from Git repository
deploy-repo:
	ansible-playbook -i inventory/created_vms.yml playbooks/deployments/deploy_from_repo.yml -e "repo=$(REPO)" -e "branch=$(BRANCH)" -e "stack=$(STACK)" -e "compose=$(COMPOSE)" -e "cleanup=$(CLEANUP)"

# Service management
list-services:
	ansible-playbook -i inventory/created_vms.yml playbooks/management/manage_services.yml -e "action=list"

inspect-service:
	ansible-playbook -i inventory/created_vms.yml playbooks/management/manage_services.yml -e "action=inspect" -e "name=$(NAME)"

scale-service:
	ansible-playbook -i inventory/created_vms.yml playbooks/management/manage_services.yml -e "action=scale" -e "name=$(NAME)" -e "replicas=$(REPLICAS)"

remove-service:
	ansible-playbook -i inventory/created_vms.yml playbooks/management/manage_services.yml -e "action=remove" -e "name=$(NAME)"

service-logs:
	ansible-playbook -i inventory/created_vms.yml playbooks/management/manage_services.yml -e "action=logs" -e "name=$(NAME)"

create-networks:
	ansible-playbook -i inventory/created_vms.yml setup_docker_swarm.yml --tags swarm_networks

# Configure all VMs (using created_vms inventory)
configure-vms:
	@if [ -f "inventory/created_vms.yml" ]; then \
		echo "Configuring all VMs..."; \
		ansible-playbook -i inventory/created_vms.yml playbooks/setup/configure_vm.yml; \
	else \
		echo "No created VMs inventory file found."; \
	fi




# List all created VMs
list-vms:
	@if [ -f "inventory/created_vms.yml" ]; then \
		echo "Created VMs:"; \
		ansible-inventory -i inventory/created_vms.yml --list | grep -A 10 '"created_vms"' | grep -E '"docker_[a-zA-Z0-9_-]+"' | sed 's/^[[:space:]]*"//;s/".*//'; \
	else \
		echo "No created VMs inventory file found."; \
	fi

# Show VM inventory details
show-inventory:
	@if [ -f "inventory/created_vms.yml" ]; then \
		echo "VM Inventory Details:"; \
		ansible-inventory -i inventory/created_vms.yml --list; \
	else \
		echo "No created VMs inventory file found."; \
	fi 


vm-status:
	ansible-playbook -i inventory/inventory.yml main.yml --tags create_vm -e "vm_action=status"

vm-overview:
	@echo "VM Workspace Overview:"
	@if [ -d "$(HOME)/vm-workspace" ]; then \
		echo "Total usage: $$(du -sh $(HOME)/vm-workspace | cut -f1)"; \
		echo "VM directories:"; \
		ls -la $(HOME)/vm-workspace/; \
		echo ""; \
		echo "Structure:"; \
		if command -v tree >/dev/null 2>&1; then \
			tree $(HOME)/vm-workspace -h; \
		else \
			find $(HOME)/vm-workspace -type f -exec ls -lh {} \;; \
		fi; \
	else \
		echo "No workspace found at $(HOME)/vm-workspace"; \
	fi





vm-cleanup:
	ansible-playbook -i inventory/inventory.yml main.yml --tags create_vm -e "vm_cleanup=true"

# Clean all VMs and storage completely using virsh

clean_full:
	@echo "Destroying all VMs and removing all storage..."
	@for vm in $$(virsh list --all --name 2>/dev/null | grep -v '^$$'); do \
		echo "Destroying VM: $$vm"; \
		virsh destroy "$$vm" 2>/dev/null || true; \
		virsh undefine "$$vm" --remove-all-storage 2>/dev/null || true; \
	done
	@echo "Cleaning VM workspace directory..."
	@if [ -d "$(HOME)/vm-workspace" ]; then \
		rm -rf "$(HOME)/vm-workspace"; \
		echo "Removed $(HOME)/vm-workspace"; \
	else \
		echo "No VM workspace found at $(HOME)/vm-workspace"; \
	fi
	@echo "Cleaning inventory files..."
	@if ls inventory/vm-*.yml 1> /dev/null 2>&1; then \
		rm -f inventory/vm-*.yml; \
		echo "Removed individual VM inventory files"; \
	fi
	@if [ -f "inventory/created_vms.yml" ]; then \
		rm -f "inventory/created_vms.yml"; \
		echo "Removed master inventory file"; \
	fi
	@echo "Complete cleanup finished!"


vars:
	ansible -m debug -a var=hostvars all  

check_yaml_syntax:
	yamllint inventory/created_vms.yml

check_all_yaml_files:
	yamllint .

check_ansible_yaml:
	ansible-lint inventory/created_vms.yml

check_inventory:
	ansible-inventory -i inventory/created_vms.yml --list