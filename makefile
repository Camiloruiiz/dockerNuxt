# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# import deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

# grep the version from the mix file
VERSION=$(shell ./version.sh)

.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
buildContainer: ## Build docker image
	docker build -t $(APP_TAG) .
runContainer: ## Run docker image
	docker run --name $(APP_NAME) --rm -d -p $(PORT):80 $(APP_TAG)
build: ## Build docker image.
	docker build -t $(APP_TAG) ./docker/web
build-nc: ## Build the container without caching.
	docker build --no-cache -t $(APP_TAG) ./docker/web
run2: ## Run container on port configured in `config.env`.
	docker run -i -t --rm --env-file=./config.env -p=$(PORT):$(PORT) --name="$(APP_NAME)" $(APP_NAME)
run: ## Run docker image.
	docker run --name $(APP_NAME) \
  --rm -d -p $(PORT):80 \
  -v $(pwd)/docker:/usr/share/nginx/html/:ro \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf \
  $(APP_TAG)
up: build run ## Build the images and runs it with port configured in `config.env` (Alias to run).
stop: ## Stop and remove a running container.
	docker stop $(APP_NAME); docker rm $(APP_NAME)
delete:
	docker rmi -f nuxtnginx_web && docker image prune
exec: ## Get inside the container.
	docker exec -it $(APP_NAME) /bin/sh
c-build: ## Build docker image using docker-compose.
	@docker-compose -f ./docker/docker-compose.yml -p $(APP_TAG) build $(c)
c-build-nc: ## Build the container without caching using docker-compose.
	@docker-compose -f ./docker/docker-compose.yml -p $(APP_TAG) build --no-cache $(c)
c-up: ## Run containers from compose file using docker-compose.
	@docker-compose -f ./docker/docker-compose.yml -p $(APP_TAG) up -d $(c)
c-dev: stop delete c-build-nc c-up ## Delete and build the image from scrach.
c-down: ## Set down containers from compose file using docker-compose.
	@docker-compose -f ./docker/docker-compose.yml -p $(APP_TAG) down $(c)
c-destroy: ## Destroy containers from compose file using docker-compose.
	@docker-compose -f ./docker/docker-compose.yml -p $(APP_TAG) down -v $(c)
c-stop: ## Destroy containers from compose file using docker-compose.
	@docker-compose -f ./docker/docker-compose.yml -p $(APP_TAG) stop $(c)
c-restart: ## Restart containers from compose file using docker-compose.
	@docker-compose -f ./docker/docker-compose.yml -p $(APP_TAG) stop $(c)
	@docker-compose -f ./docker/docker-compose.yml -p $(APP_TAG) up -d $(c)
c-logs: ## Show container logs.
	@docker-compose -f ./docker/docker-compose.yml -p $(APP_TAG) logs --tail=100 -f $(c)

.DEFAULT_GOAL := help
