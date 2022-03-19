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
build: ## Build docker image
	docker build -t $(APP_TAG) .
build-nc: ## Build the container without caching
	docker build --no-cache -t $(APP_TAG) .
run2: ## Run container on port configured in `config.env`
	docker run -i -t --rm --env-file=./config.env -p=$(PORT):$(PORT) --name="$(APP_NAME)" $(APP_NAME)
run: ## Run docker image
	docker run --name $(APP_NAME) --rm -d -p $(PORT):80 $(APP_TAG)
up: build run ## Run container on port configured in `config.env` (Alias to run)
stop: ## Stop and remove a running container
	docker stop $(APP_NAME); docker rm $(APP_NAME)
c-build:
	@docker-compose build
c-up:
	@docker-compose up -d

.DEFAULT_GOAL := help
