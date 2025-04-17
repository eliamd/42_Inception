# Colors
GREEN = \033[0;32m
RED = \033[0;31m
YELLOW = \033[0;33m
BLUE = \033[0;34m
RESET = \033[0m

# Variables
NAME = inception
ENV_FILE = ./srcs/.env
DOCKER_COMPOSE = docker-compose -f ./srcs/docker-compose.yml
DATA_DIRS = /home/edetoh/data/mariadb /home/edetoh/data/wordpress

# Commands
all: setup build up

setup:
	@printf "$(GREEN)Creating data directories if they don't exist...$(RESET)\n"
	@mkdir -p $(DATA_DIRS)

build:
	@printf "$(GREEN)Building containers...$(RESET)\n"
	@$(DOCKER_COMPOSE) build

up:
	@printf "$(GREEN)Starting containers...$(RESET)\n"
	@$(DOCKER_COMPOSE) up -d

down:
	@printf "$(RED)Stopping containers...$(RESET)\n"
	@$(DOCKER_COMPOSE) down

ps:
	@printf "$(BLUE)Container status:$(RESET)\n"
	@$(DOCKER_COMPOSE) ps

logs:
	@printf "$(BLUE)Container logs:$(RESET)\n"
	@$(DOCKER_COMPOSE) logs

follow:
	@printf "$(BLUE)Following logs...$(RESET)\n"
	@$(DOCKER_COMPOSE) logs -f

# Commandes pour accéder aux conteneurs
nginx:
	@printf "$(YELLOW)Connecting to nginx container...$(RESET)\n"
	@docker exec -it nginx /bin/bash

wordpress:
	@printf "$(YELLOW)Connecting to wordpress container...$(RESET)\n"
	@docker exec -it wordpress /bin/bash

mariadb:
	@printf "$(YELLOW)Connecting to mariadb container...$(RESET)\n"
	@docker exec -it mariadb /bin/bash

# Commandes de nettoyage
clean: down
	@printf "$(RED)Removing all containers and images...$(RESET)\n"
	@docker system prune -af

fclean: clean
	@printf "$(RED)Removing volumes...$(RESET)\n"
	@docker volume rm -f $$(docker volume ls -q | grep inception) 2>/dev/null || true
	@docker volume prune -f

re: fclean all

status:
	@printf "$(BLUE)Docker status:$(RESET)\n"
	@docker info
	@printf "\n$(BLUE)Images:$(RESET)\n"
	@docker images
	@printf "\n$(BLUE)Volumes:$(RESET)\n"
	@docker volume ls
	@printf "\n$(BLUE)Networks:$(RESET)\n"
	@docker network ls

.PHONY: all build up down ps logs clean fclean re follow nginx wordpress mariadb status
