.PHONY: help install install-dev test test-cov lint format type-check security clean docker-build docker-run docker-test pre-commit setup-dev

# Default target
help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Installation
install: ## Install production dependencies
	pip install -r requirements.txt

install-dev: ## Install development dependencies
	pip install -r requirements-dev.txt
	pre-commit install

setup-dev: ## Setup development environment
	python -m venv venv
	. venv/bin/activate && pip install --upgrade pip
	. venv/bin/activate && make install-dev
	@echo "✅ Development environment setup complete!"
	@echo "Activate with: source venv/bin/activate"

# Testing
test: ## Run tests
	pytest tests/ -v

test-cov: ## Run tests with coverage
	pytest tests/ -v --cov=. --cov-report=html --cov-report=term-missing

test-fast: ## Run tests without coverage (faster)
	pytest tests/ -v --no-cov

# Code Quality
lint: ## Run linting checks
	flake8 .

format: ## Format code
	black .
	isort .

format-check: ## Check code formatting
	black --check --diff .
	isort --check-only --diff .

type-check: ## Run type checking
	mypy . --ignore-missing-imports

security: ## Run security checks
	safety check

# Quality checks (all)
quality: format-check lint type-check security ## Run all quality checks

# Pre-commit
pre-commit: ## Run pre-commit hooks on all files
	pre-commit run --all-files

pre-commit-update: ## Update pre-commit hooks
	pre-commit autoupdate

# Docker
docker-build: ## Build Docker image
	docker build -t muffin-detector .

docker-run: ## Run Docker container
	docker run -p 8000:8000 muffin-detector

docker-test: ## Test Docker container
	docker build -t muffin-detector:test .
	docker run -d --name muffin-test -p 8000:8000 muffin-detector:test
	sleep 10
	curl -f http://localhost:8000/health || (docker stop muffin-test && docker rm muffin-test && exit 1)
	docker stop muffin-test
	docker rm muffin-test
	@echo "✅ Docker test passed!"

# Development server
dev: ## Start development server
	python app.py

dev-debug: ## Start development server with debug logging
	PYTHONPATH=src uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload --log-level debug

# Testing with service
test-service: ## Test the running service
	python test_service.py demo_image.jpg || echo "Create a test image first"

# Demo
demo: ## Run demo script
	python demo.py

# Cloud Deployment
gcp-setup: ## Setup Google Cloud Platform
	./scripts/setup-gcp.sh

deploy-quick: ## Quick deploy to Cloud Run (local)
	./scripts/quick-deploy.sh

deploy-status: ## Check Cloud Run service status
	gcloud run services describe muffin-detector --region=europe-west1 --format="table(metadata.name,status.url,status.conditions[0].type)"

deploy-logs: ## View Cloud Run service logs
	gcloud logs read --service=muffin-detector --region=europe-west1 --limit=50

# Cleanup
clean: ## Clean up temporary files
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	rm -rf .pytest_cache
	rm -rf htmlcov
	rm -rf .coverage
	rm -rf dist
	rm -rf build
	rm -rf *.egg-info/
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete

clean-all: clean ## Clean up everything including venv
	rm -rf venv/

# CI simulation
ci-local: ## Simulate CI pipeline locally
	@echo "🚀 Running local CI simulation..."
	make format-check
	make lint
	make type-check
	make security
	make test-cov
	make docker-test
	@echo "✅ Local CI simulation completed!"

# Documentation
docs-serve: ## Serve documentation locally
	mkdocs serve

docs-build: ## Build documentation
	mkdocs build

# Release preparation
release-check: ## Check if ready for release
	@echo "🔍 Checking release readiness..."
	make quality
	make test-cov
	make docker-test
	@echo "✅ Release checks passed!"

# Git hooks
install-hooks: ## Install git hooks
	pre-commit install
	pre-commit install --hook-type commit-msg

# Environment info
env-info: ## Show environment information
	@echo "Python version: $(shell python --version)"
	@echo "Pip version: $(shell pip --version)"
	@echo "Virtual environment: $(VIRTUAL_ENV)"
	@echo "Current directory: $(PWD)"
	@echo "Git branch: $(shell git branch --show-current 2>/dev/null || echo 'Not a git repository')"

# Quick setup for new contributors
quickstart: ## Quick setup for new contributors
	@echo "🚀 Setting up Muffin Detector development environment..."
	make setup-dev
	make install-hooks
	@echo ""
	@echo "✅ Setup complete! Next steps:"
	@echo "1. Activate virtual environment: source venv/bin/activate"
	@echo "2. Start development server: make dev"
	@echo "3. Run tests: make test"
	@echo "4. Check code quality: make quality"
