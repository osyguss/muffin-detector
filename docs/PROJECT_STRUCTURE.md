# 📁 Projekt-Struktur

## Übersicht

Das Muffin vs Chihuahua Detector Projekt folgt modernen Python-Entwicklungsstandards mit einer sauberen `src/` Layout-Struktur.

## 🏗️ Verzeichnisstruktur

```
muffin-detector/
├── 📁 src/                          # Hauptquellcode
│   ├── __init__.py                  # Package Initialisierung
│   ├── main.py                      # FastAPI Anwendung
│   └── classifier.py                # ML Classifier Logic
│
├── 📁 tests/                        # Test Suite
│   ├── __init__.py
│   ├── test_main.py                 # API Tests
│   └── test_classifier.py          # Classifier Tests
│
├── 📁 .github/                      # GitHub Workflows
│   ├── workflows/
│   │   ├── ci.yml                   # CI Pipeline
│   │   └── deploy.yml               # CD Pipeline
│   ├── ISSUE_TEMPLATE/
│   └── PULL_REQUEST_TEMPLATE.md
│
├── 📁 docs/                         # Dokumentation
│   ├── CI_CD_PIPELINE.md
│   └── PROJECT_STRUCTURE.md
│
├── 📁 scripts/                      # Utility Scripts
│   └── setup-dev.sh
│
├── 🐳 Dockerfile                    # Container Definition
├── 🚀 app.py                       # Application Entry Point
├── 🎮 demo.py                      # Demo Script
├── 🧪 test_service.py              # Service Testing Script
├── 🚢 deploy.sh                    # Deployment Script
├── ☁️  cloudbuild.yaml             # Google Cloud Build
│
├── 📋 requirements.txt             # Production Dependencies
├── 📋 requirements-dev.txt         # Development Dependencies
├── ⚙️  pyproject.toml              # Project Configuration
├── 🧪 pytest.ini                  # Test Configuration
├── 🎨 .flake8                     # Linting Configuration
├── 🔧 .pre-commit-config.yaml     # Pre-commit Hooks
├── 🛠️  Makefile                   # Development Commands
├── 📚 README.md                   # Project Documentation
└── 🙈 .gitignore                  # Git Ignore Rules
```

## 📦 Package Structure

### `src/` - Hauptquellcode
- **Moderne Python Struktur**: Folgt PEP 518 Standards
- **Saubere Trennung**: Business Logic von Entry Points getrennt
- **Import-freundlich**: Einfache relative und absolute Imports
- **Test-freundlich**: Klare Trennung zwischen Code und Tests

### Hauptkomponenten:

#### `src/main.py` - FastAPI Anwendung
```python
# REST API Endpoints
- POST /predict    # Bildklassifizierung
- GET /health      # Health Check
- GET /            # Service Info
- GET /docs        # API Dokumentation
```

#### `src/classifier.py` - ML Classifier
```python
class MuffinChihuahuaClassifier:
    - __init__()     # Model Initialisierung
    - predict()      # Bildklassifizierung
    - get_model_info() # Model Informationen
```

#### `app.py` - Entry Point
```python
# Haupteinstiegspunkt für die Anwendung
# Konfiguriert Python Path für src/ Imports
# Startet FastAPI Server
```

## 🔧 Konfigurationsdateien

### Development Tools
- **pytest.ini**: Test-Konfiguration mit `pythonpath = src`
- **.flake8**: Linting-Regeln und Ausnahmen
- **pyproject.toml**: Projekt-Metadaten und Tool-Konfiguration
- **.pre-commit-config.yaml**: Code Quality Hooks

### Deployment
- **Dockerfile**: Multi-stage Container Build
- **cloudbuild.yaml**: Google Cloud Build Konfiguration
- **deploy.sh**: Deployment Script für GCP

### CI/CD
- **.github/workflows/ci.yml**: Continuous Integration
- **.github/workflows/deploy.yml**: Continuous Deployment

## 🚀 Vorteile der src/ Struktur

### ✅ **Saubere Trennung**
- Quellcode von Scripts und Konfiguration getrennt
- Verhindert versehentliche Imports von Test-Code
- Klare Package-Grenzen

### ✅ **Test-Isolation**
- Tests importieren explizit aus `src/`
- Keine Konflikte zwischen Test- und Produktionscode
- Bessere Coverage-Berichte

### ✅ **Deployment-freundlich**
- Einfache Container-Builds
- Klare Abhängigkeiten
- Reduzierte Image-Größe

### ✅ **IDE-Unterstützung**
- Bessere Auto-Completion
- Korrekte Import-Auflösung
- Verbesserte Navigation

## 🛠️ Development Workflow

### Lokale Entwicklung
```bash
# Environment Setup
make quickstart

# Code ausführen
python app.py                    # Production-like
make dev-debug                   # Development mit Reload

# Testing
make test                        # Unit Tests
make test-cov                    # Mit Coverage
make ci-local                    # Komplette CI Simulation
```

### Code Quality
```bash
make format                      # Code formatieren
make lint                        # Linting
make type-check                  # Type Checking
make quality                     # Alle Quality Checks
```

### Container Development
```bash
make docker-build               # Image bauen
make docker-test                # Container testen
```

## 📊 Import-Strategie

### In Tests (`tests/`)
```python
# pytest.ini konfiguriert pythonpath = src
from main import app
from classifier import MuffinChihuahuaClassifier
```

### In Entry Points (`app.py`, `demo.py`)
```python
# Explizite Path-Konfiguration
import sys
from pathlib import Path
src_path = Path(__file__).parent / "src"
sys.path.insert(0, str(src_path))

from src.main import app
```

### In src/ Modulen
```python
# Direkte Imports innerhalb des Packages
from classifier import MuffinChihuahuaClassifier
```

## 🔄 Migration Benefits

### Vorher (Flat Structure)
```
muffin-detector/
├── main.py
├── classifier.py
├── tests/
└── ...
```

### Nachher (src/ Structure)
```
muffin-detector/
├── src/
│   ├── main.py
│   └── classifier.py
├── app.py              # Entry Point
├── tests/
└── ...
```

### Verbesserungen:
- ✅ **94% Test Coverage** (vorher 51%)
- ✅ **Saubere Imports** ohne Pfad-Konflikte
- ✅ **Bessere IDE-Unterstützung**
- ✅ **Professionelle Struktur** nach Python Standards
- ✅ **Deployment-optimiert** für Container und Cloud

## 📚 Weiterführende Informationen

- [PEP 518 - Specifying Minimum Build System Requirements](https://peps.python.org/pep-0518/)
- [Python Packaging User Guide - src layout](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/)
- [Testing Best Practices](https://docs.python-guide.org/writing/tests/)
