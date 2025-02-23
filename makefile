# Makefile for setting up the GitLab environment

# Variables
DOCKER_DIR=docker
DC=docker compose
GITLAB_CONTAINER=gitlab
DNS_CONTAINER=dns

.PHONY: all setup-docker configure-env start-containers configure-firewall get-gitlab-password

# Main setup command
all: setup-docker configure-env start-containers configure-firewall get-gitlab-password
	@echo "Setup completed successfully."

# Step 1: Navigate to docker directory and pull images
setup-docker:
	cd $(DOCKER_DIR) && $(DC) pull
	mkdir -p gitlab/config gitlab/logs gitlab/data

# Step 2: Configure environment variables
configure-env:
	cp .env-example .env
	@echo "Environment file copied. Please edit .env file manually if necessary."

# Step 3: Start the containers
start-containers:
	cd $(DOCKER_DIR) && $(DC) up -d
	@echo "Containers started."

# Step 4: Configure firewall rules
configure-firewall:
	sudo ufw allow 22/tcp
	sudo ufw allow 53/tcp
	sudo ufw allow 53/udp
	sudo ufw allow 8000/tcp
	sudo ufw allow 443/tcp
	sudo ufw allow 2424/tcp
	sudo ufw enable
	sudo ufw reload
	@echo "Firewall rules configured."

# Step 5: Retrieve GitLab root password
get-gitlab-password:
	docker exec -it $(GITLAB_CONTAINER) grep 'Password:' /etc/gitlab/initial_root_password
