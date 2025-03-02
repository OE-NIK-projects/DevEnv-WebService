# Makefile for setting up the GitLab environment

# Variables
DC=docker compose
DOCKER_DIR=config/docker
ENV_CONFIG=$(DOCKER_DIR)/.env
DOMAIN_NAME?=example.com

.PHONY: all configure-env update-env setup-docker disable-systemd-resolved start-containers configure-firewall get-gitlab-password

# Main setup command
all: configure-env update-env setup-docker disable-systemd-resolved start-containers configure-firewall
	@echo "Setup completed successfully."
	@echo "GitLab will be running on 'https://$(DOMAIN_NAME)'"
	@echo "To get GitLab initial_root_password run: sudo make get-gitlab-password"
	@echo "GitLab is starting. This may take a few minutes. Check the logs with 'sudo docker logs -f gitlab'."

# Step 1: Configure environment variables
configure-env:
	cp $(DOCKER_DIR)/.env-example $(ENV_CONFIG)
	@echo "Environment file copied. Please edit .env file manually if necessary."

# Step 2: Update .env file with the domain name
update-env:
	sed -i "s/^GITLAB_URL=.*/GITLAB_URL=gitlab.$(DOMAIN_NAME)/" $(ENV_CONFIG) && \
	echo "Updated $(ENV_CONFIG) with GITLAB_URL=gitlab.$(DOMAIN_NAME)"

# Step 4: Navigate to docker directory, create gitlab directories and pull images
setup-docker:
	mkdir -p $(DOCKER_DIR)/gitlab/config $(DOCKER_DIR)/gitlab/logs $(DOCKER_DIR)/gitlab/data
	cd $(DOCKER_DIR) && sudo $(DC) pull

# Step 6: Start the containers
start-containers:
	cd $(DOCKER_DIR) && sudo $(DC) up -d
	@echo "Containers started."

# Step 7: Configure firewall rules
configure-firewall:
	sudo ufw allow 22/tcp
	sudo ufw allow 53/tcp
	sudo ufw allow 53/udp
	sudo ufw allow 443/tcp
	sudo ufw allow 2424/tcp
	sudo ufw enable
	sudo ufw reload
	@echo "Firewall rules configured."

# Step 8: Retrieve GitLab root password
get-gitlab-password:
	sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
