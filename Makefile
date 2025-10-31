# Brazilian Astrology API - Makefile
# Simplifies common development and deployment tasks

.PHONY: help build up down restart logs test lint format clean deploy status backup

# Default target
help: ## Show this help message
	@echo "Brazilian Astrology API - Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# Development commands
build: ## Build development containers
	./docker/scripts/dev.sh rebuild

up: ## Start development environment
	./docker/scripts/dev.sh start

down: ## Stop development environment
	./docker/scripts/dev.sh stop

restart: ## Restart development environment
	./docker/scripts/dev.sh restart

logs: ## Show logs for API service
	./docker/scripts/dev.sh logs api

logs-%: ## Show logs for specific service (e.g., make logs-postgres)
	./docker/scripts/dev.sh logs $*

shell: ## Enter API container shell
	./docker/scripts/dev.sh shell api

shell-%: ## Enter shell for specific service (e.g., make shell-postgres)
	./docker/scripts/dev.sh shell $*

status: ## Show development environment status
	./docker/scripts/dev.sh status

# Testing and code quality
test: ## Run tests
	./docker/scripts/dev.sh test

lint: ## Run code linting
	./docker/scripts/dev.sh lint

format: ## Format code
	./docker/scripts/dev.sh format

# Production commands
deploy: ## Deploy to production
	./docker/scripts/deploy.sh deploy

deploy-status: ## Show production deployment status
	./docker/scripts/deploy.sh status

deploy-logs: ## Show production API logs
	./docker/scripts/deploy.sh logs api

deploy-update: ## Update production services
	./docker/scripts/deploy.sh update

deploy-rollback: ## Rollback production deployment
	./docker/scripts/deploy.sh rollback

deploy-scale-api: ## Scale API service (usage: make deploy-scale-api REPLICAS=3)
	./docker/scripts/deploy.sh scale api $(REPLICAS)

deploy-test: ## Run production smoke tests
	./docker/scripts/deploy.sh test

deploy-backup: ## Create production backup
	./docker/scripts/deploy.sh backup

deploy-restore: ## Restore production from backup (usage: make deploy-restore BACKUP_FILE=backup.sql.gz)
	./docker/scripts/deploy.sh restore $(BACKUP_FILE)

# Maintenance
clean: ## Clean up Docker resources
	./docker/scripts/dev.sh clean

# Quick development workflow
dev: down build up ## Full development reset (down -> build -> up)
	@echo "Development environment ready!"
	@echo "API: http://localhost:8000"
	@echo "Docs: http://localhost:8000/docs"

# CI/CD simulation
ci: lint test ## Run CI checks (lint + test)

# Environment setup
setup: ## Initial project setup
	@echo "Setting up development environment..."
	@cp .env.example .env 2>/dev/null || echo ".env already exists"
	@echo "Please edit .env file with your configuration"
	@echo "Then run: make dev"

# Database operations
db-shell: ## Enter PostgreSQL shell
	./docker/scripts/dev.sh db-shell

db-logs: ## Show PostgreSQL logs
	./docker/scripts/dev.sh logs postgres

# Redis operations
redis-cli: ## Enter Redis CLI
	./docker/scripts/dev.sh redis-cli

redis-logs: ## Show Redis logs
	./docker/scripts/dev.sh logs redis

# Monitoring
monitor-grafana: ## Open Grafana in browser (if running locally)
	@echo "Grafana: http://localhost:3000"
	@echo "User: admin"
	@echo "Pass: admin123"

monitor-prometheus: ## Open Prometheus in browser (if running locally)
	@echo "Prometheus: http://localhost:9090"

# Utility commands
install-hooks: ## Install git hooks
	@echo "Installing git hooks..."
	@chmod +x .git/hooks/pre-commit 2>/dev/null || true
	@echo "Git hooks installed"

update-deps: ## Update Python dependencies
	@echo "Updating dependencies..."
	@docker-compose exec api pip install --upgrade -r requirements.txt
	@echo "Dependencies updated"

# Information
info: ## Show project information
	@echo "=== Brazilian Astrology API ==="
	@echo "Version: 2.0.0"
	@echo "Framework: FastAPI"
	@echo "Database: PostgreSQL"
	@echo "Cache: Redis"
	@echo ""
	@echo "Development URLs:"
	@echo "  API: http://localhost:8000"
	@echo "  Docs: http://localhost:8000/docs"
	@echo "  PgAdmin: http://localhost:5050"
	@echo "  Redis Commander: http://localhost:8081"
	@echo ""
	@echo "Production URLs:"
	@echo "  API: https://api.astrologia.br"
	@echo "  Grafana: https://grafana.astrologia.br"
	@echo "  Prometheus: https://prometheus.astrologia.br"
	@echo "  PgAdmin: https://pgadmin.astrologia.br"
	@echo "  Traefik: https://traefik.astrologia.br"
	@echo "  Portainer: https://portainer.astrologia.br"