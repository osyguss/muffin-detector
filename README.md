# Muffin vs Chihuahua Detector 🧁🐕

Ein Python-Service zur Klassifizierung von Bildern als Muffins oder Chihuahuas mit Hilfe von Machine Learning.

Das berühmte "Muffin vs Chihuahua" Problem der Computer Vision - überraschend schwierig aufgrund der visuellen Ähnlichkeiten!

## Features

- 🧠 **KI-Klassifizierung**: Hugging Face Vision Transformer Models
- 🌐 **REST API**: FastAPI mit automatischer OpenAPI Dokumentation
- 🐳 **Container-Ready**: Optimierter Multi-Stage Docker Build
- ☁️ **Cloud-Native**: Konfiguriert für Google Cloud Run
- 🔄 **CI/CD Pipeline**: Umfassende GitHub Actions Workflows
- 🧪 **Umfassende Tests**: Unit Tests, Integration Tests, Coverage Reports
- 🔒 **Security**: Vulnerability Scanning, Code Security Analysis
- 📊 **Code Quality**: Automated Linting, Formatting, Type Checking

## Installation

1. Repository klonen:
```bash
git clone <repository-url>
cd muffin-detector
```

2. Development Environment Setup:
```bash
# Schnelle Einrichtung
make quickstart

# Oder manuell
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows
pip install -r requirements-dev.txt
```

3. Service starten:
```bash
# Development Server
make dev

# Oder direkt
python app.py

# Mit Reload für Development
make dev-debug
```

## API Endpoints

### POST /predict
Upload ein Bild zur Klassifizierung.

**Request:**
- Content-Type: multipart/form-data
- Body: file (image file)

**Response:**
```json
{
  "prediction": "muffin" | "chihuahua",
  "confidence": 0.95,
  "processing_time": 0.123,
  "filename": "uploaded_image.jpg"
}
```

### GET /health
Health Check Endpoint.

## Deployment

### Docker
```bash
docker build -t muffin-detector .
docker run -p 8000:8000 muffin-detector
```

### Google Cloud Run
Der Service ist für Google Cloud Run optimiert und kann über die CI/CD Pipeline automatisch deployed werden.

## CI/CD Pipeline

### GitHub Actions Workflows

Das Projekt verwendet zwei Haupt-Workflows:

#### 1. **CI Pipeline** (`.github/workflows/ci-only.yml`)
Läuft bei Push und Pull Requests:
- ✅ **Code Quality**: Black, isort, Flake8, MyPy
- 🔒 **Security**: Bandit, Safety Security Scanning
- 🧪 **Tests**: Unit Tests mit Coverage (Python 3.10, 3.11, 3.12)
- 🐳 **Docker**: Container Build und Test (ohne Push)
- 🔗 **Integration**: Service Integration Tests

#### 2. **CD Pipeline** (Deaktiviert für Tests)
- 🚀 **Deployment**: Manuell über `workflow_dispatch`
- 📊 **Monitoring**: Health Checks und Smoke Tests
- 🏷️ **Tagging**: Automatisches Image Tagging mit Git SHA

### Development Commands

```bash
# Code Quality
make quality          # Alle Quality Checks
make format          # Code formatieren
make lint            # Linting
make type-check      # Type Checking

# Testing
make test            # Tests ausführen
make test-cov        # Tests mit Coverage
make ci-local        # Lokale CI Simulation

# Docker
make docker-build    # Docker Image bauen
make docker-test     # Docker Container testen
```

### Setup für Contributors

```bash
# Komplette Entwicklungsumgebung
make quickstart

# Pre-commit Hooks installieren
pre-commit install
```

## Entwicklung

Das Projekt nutzt ein vortrainiertes Hugging Face Model für die Bildklassifizierung. Das Model wird beim ersten Start automatisch heruntergeladen.

### Architektur
- **FastAPI**: Moderne, schnelle Web API
- **Hugging Face Transformers**: State-of-the-art ML Models
- **Docker**: Containerisierte Deployment
- **GitHub Actions**: Automatisierte CI/CD
# Service Account Berechtigungen hinzugefügt
