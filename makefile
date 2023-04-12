CONTAINER_NAME:=vaults-pgres
IMAGE_NAME:=seed-vault

POSTGRES_PASSWORD:=$(pw)
POSTGRES_DB:=vaults

DEFAULT_GOAL:=start

### Project setup ###

development: build pip-requirements tailwind
	@echo
	@echo "Ready to go!"

start: postgres
	@echo
	@$(MAKE) -s flask

stop: postgres-stop
# TODO: flask-stop

restart: stop start ## Restart postgres container

build: ## Build docker image for postgres container
	@docker build -t $(IMAGE_NAME) .

.PHONY: development start stop restart

### Manage flask app ###

pip-requirements: ## install pip requirements
	@echo "Installing pip requirements..."
	@pip install -r requirements.txt
	@echo "Installed pip requirements"

flask: ## start flask app
	@echo "Starting flask app..."
	@flask --app vaults run --debug

.PHONY: pip-requirements flask tailwind

### Tailwind ###

tailwind: ## building css ##
	@echo "Installing npm packages..."
	@npm ci
	@echo "Installed npm packages"
	@echo
	@echo "Building tailwind css..."
	@npm run create-css
	@echo "Built tailwind css"

.PHONY: tailwind

### Interact with postgres container ###

postgres: validate_password ## Start postgres container
	@echo "Starting postgres container $(CONTAINER_NAME)..."
	@docker run --name $(CONTAINER_NAME) --rm -d -p 5431:5431 -e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) -e POSTGRES_DB=$(POSTGRES_DB) $(IMAGE_NAME) > /dev/null
	@echo "Started $(CONTAINER_NAME) successfully"

postgres-stop: ## Stop postgres container
	@echo "Stopping postgres container $(CONTAINER_NAME)..."
	@docker container stop $(CONTAINER_NAME) > /dev/null
	@echo "Stopped $(CONTAINER_NAME)"

postgres-shell: ## Connect to postgres container
	@docker exec -it $(CONTAINER_NAME) psql -U postgres vaults

logs: ## Show logs of postgres container
	@docker container logs $(CONTAINER_NAME)

.PHONY: postgres postgres-stop postgres-shell logs

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