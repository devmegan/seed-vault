CONTAINER_NAME:=vaults-pgres
IMAGE_NAME:=seed-vault

POSTGRES_PASSWORD:=$(pw)
POSTGRES_DB:=vaults

DEFAULT_GOAL:=start

### Project setup ###

start: validate_password ## Start postgres container
	@echo "Starting postgres container $(CONTAINER_NAME)..."
	@docker run --name $(CONTAINER_NAME) --rm -d -p 5431:5431 -e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) -e POSTGRES_DB=$(POSTGRES_DB) $(IMAGE_NAME) > /dev/null
	@echo "Started $(CONTAINER_NAME) successfully"

stop: ## Stop postgres container
	@echo "Stopping postgres container $(CONTAINER_NAME)..."
	@docker container stop $(CONTAINER_NAME) > /dev/null
	@echo "Stopped $(CONTAINER_NAME)"

restart: stop start ## Restart postgres container

build: ## Build docker image for postgres container
	@docker build -t $(IMAGE_NAME) .

.PHONY: default start stop restart

### Interact with postgres container ###

postgres: ## Connect to postgres container
	@docker exec -it $(CONTAINER_NAME) psql -U postgres vaults

logs: ## Show logs of postgres container
	@docker container logs $(CONTAINER_NAME)

.PHONY: postgres logs

### Helper targets ###

validate_password: ## Check if POSTGRES_PASSWORD is set
	@if [ -z $(POSTGRES_PASSWORD) ]; then\
        echo "Postgres password has not been set.\n"; \
		echo "Usage for make start or make restart:"; \
		echo "  make start pw=<postgres_password>"; \
		echo "  make restart pw=<postgres_password>\n"; \
		exit 1;\
    fi

.PHONY: validate_password