# Docker Swarm Project

This is a Docker Swarm project that manages multiple virtual machines (VMs) using Ansible.

## What the Project Does

The project consists of a set of files and directories that define how to create, manage, and deploy multiple VMs using Docker Swarm. It uses Ansible as the configuration management tool.

## File Relationships

* `./setup_docker_swarm.yml` is used to configure the Docker Swarm environment.
* `./ansible.cfg` sets up Ansible's configuration files.
* `./requirements.txt` lists the dependencies required for the project, including Ansible and YamlLint.
* The various `.yml` files in the `inventory` directory define the inventory files for different environments (e.g., `vm-docker-swarm1.yml`, `vm-docker-swarm2.yml`).
* The `roles` directory contains Playbooks that define the configuration for each environment.

## Usage Instructions

To use this project, follow these steps:

1. Initialize a new Git repository and clone it into your local machine.
2. Create a new directory for your project and navigate into it.
3. Run `docker swarm init` to create a Docker Swarm cluster.
4. Create an inventory file for your environment (e.g., `vm-docker-swarm1.yml`) using the `./inventory/vm-docker-swarm1.yml` template.
5. Use Ansible to deploy and manage your VMs, referencing the inventory files and roles defined in this project.

## Example Playbook

Here is an example of a simple playbook that creates two VMs:
```yaml
---
- name: Create two VMs
  hosts: localhost
  become: yes

  tasks:
    - name: Create VM1
      docker_image:
        name: my-docker-image
        tag: "latest"
      register: vm1

    - name: Create VM2
      docker_image:
        name: my-other-docker-image
        tag: "latest"
      register: vm2

    - name: Deploy VMs to Swarm cluster
      docker_swarm:
        image: "{{ item }}"
        tags: "{{ item }}"
        host_vars: "{{ lookup('hostvars', 'localhost') }}"
        state: present
      loop: [vm1, vm2]
```
This playbook creates two VMs with different Docker images and references the `./roles/docker` role to deploy them to a Swarm cluster.

