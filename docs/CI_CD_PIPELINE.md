# 🚀 CI/CD Pipeline Documentation

## Übersicht

Das Muffin vs Chihuahua Detector Projekt verwendet eine umfassende CI/CD Pipeline mit GitHub Actions, die automatisierte Tests, Code Quality Checks, Security Scans und Deployment zu Google Cloud Run umfasst.

## 📋 Pipeline Struktur

### 1. **CI Pipeline** (`.github/workflows/ci.yml`)
Läuft bei **Pull Requests** und **Feature Branches**

#### Jobs:
- **pre-commit**: Pre-commit Hook Validierung
- **quality**: Code Quality Checks (Black, isort, Flake8, MyPy, Bandit, Safety)
- **test**: Unit Tests mit Coverage (Python 3.10, 3.11, 3.12)
- **integration**: Integration Tests mit laufendem Service
- **docker-test**: Docker Container Build und Test
- **ci-summary**: Zusammenfassung aller CI Ergebnisse

### 2. **CD Pipeline** (`.github/workflows/deploy.yml`)
Läuft bei **Push zu main/master**

#### Jobs:
- **lint**: Code Quality Validierung
- **test**: Unit Tests mit Matrix Testing
- **docker-build**: Docker Build mit Security Scan (Trivy)
- **deploy**: Deployment zu Google Cloud Run
- **notify**: Deployment Status Benachrichtigung

## 🔧 Setup und Konfiguration

### GitHub Secrets
Folgende Secrets müssen in GitHub konfiguriert werden:

```bash
GCP_PROJECT_ID      # Google Cloud Project ID
GCP_SA_KEY         # Service Account Key (JSON)
```

### Service Account Berechtigungen
Der Service Account benötigt folgende Rollen:
- `Cloud Run Admin`
- `Storage Admin` 
- `Container Registry Service Agent`
- `Service Account User`

## 📊 Quality Gates

### Code Quality Standards
- **Black**: Code Formatting (Line Length: 88)
- **isort**: Import Sorting
- **Flake8**: Linting (Max Complexity: 10)
- **MyPy**: Type Checking
- **Bandit**: Security Linting
- **Safety**: Vulnerability Scanning

### Test Coverage
- **Minimum Coverage**: 70%
- **Coverage Reports**: XML, HTML, Terminal
- **Upload zu Codecov**: Automatisch bei Python 3.11

### Security Standards
- **Container Scanning**: Trivy Vulnerability Scanner
- **Dependency Scanning**: Safety Check
- **Code Security**: Bandit Static Analysis
- **SARIF Upload**: GitHub Security Tab Integration

## 🚦 Pipeline Triggers

### CI Pipeline Triggers
```yaml
on:
  pull_request:
    branches: [ main, master, develop ]
  push:
    branches: [ develop, feature/* ]
```

### CD Pipeline Triggers
```yaml
on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master ]
```

## 🐳 Docker Build Process

### Multi-Stage Build
1. **Builder Stage**: Dependencies Installation
2. **Production Stage**: Optimized Runtime Image
3. **Security**: Non-root User, Health Checks
4. **Caching**: GitHub Actions Cache für Build Acceleration

### Container Testing
- **Health Check**: Service Readiness Validation
- **Endpoint Testing**: API Functionality Tests
- **Security Scan**: Trivy Vulnerability Assessment

## ☁️ Cloud Run Deployment

### Deployment Configuration
```yaml
--memory 2Gi
--cpu 1
--timeout 300
--max-instances 10
--min-instances 0
--concurrency 80
--allow-unauthenticated
```

### Environment Variables
- `ENVIRONMENT=production`
- `VERSION=$GITHUB_SHA`

### Labels
- `app=muffin-detector`
- `version=$GITHUB_SHA`
- `environment=production`

## 🧪 Testing Strategy

### Test Types
1. **Unit Tests**: Isolated Component Testing
2. **Integration Tests**: Service-to-Service Testing
3. **Container Tests**: Docker Image Validation
4. **Smoke Tests**: Post-Deployment Validation

### Test Matrix
- **Python Versions**: 3.10, 3.11, 3.12
- **Operating System**: Ubuntu Latest
- **Dependencies**: Latest Compatible Versions

## 📈 Monitoring und Observability

### Pipeline Monitoring
- **GitHub Actions Dashboard**: Real-time Pipeline Status
- **Artifacts**: Test Reports, Coverage Reports, Security Reports
- **Notifications**: Deployment Status Updates

### Application Monitoring
- **Health Checks**: `/health` Endpoint
- **Metrics**: Processing Time, Confidence Scores
- **Logs**: Structured Logging mit Python Logging

## 🔄 Workflow Beispiele

### Feature Development
```bash
1. git checkout -b feature/new-classifier
2. # Entwicklung und Tests
3. git push origin feature/new-classifier
4. # CI Pipeline läuft automatisch
5. # Pull Request erstellen
6. # Code Review und Merge
7. # CD Pipeline deployt automatisch
```

### Hotfix Deployment
```bash
1. git checkout -b hotfix/critical-bug
2. # Bug Fix implementieren
3. git push origin hotfix/critical-bug
4. # Emergency PR und schneller Review
5. # Merge zu main
6. # Automatisches Deployment
```

## 🛠️ Lokale Entwicklung

### Make Commands
```bash
make setup-dev          # Development Environment Setup
make quality            # Alle Quality Checks
make test-cov           # Tests mit Coverage
make docker-test        # Docker Container Test
make ci-local           # Lokale CI Simulation
```

### Pre-commit Hooks
```bash
pre-commit install      # Hook Installation
pre-commit run --all-files  # Alle Hooks ausführen
```

## 🚨 Troubleshooting

### Häufige Probleme

#### 1. **Test Failures**
```bash
# Lokale Tests ausführen
make test-cov

# Spezifische Tests debuggen
pytest tests/test_main.py::TestPredictEndpoint::test_predict_with_valid_image -v
```

#### 2. **Code Quality Issues**
```bash
# Code formatieren
make format

# Quality Checks
make quality
```

#### 3. **Docker Build Failures**
```bash
# Lokaler Docker Test
make docker-test

# Build Logs prüfen
docker build -t muffin-detector . --no-cache
```

#### 4. **Deployment Issues**
```bash
# Service Logs prüfen
gcloud logs read --service=muffin-detector --limit=50

# Service Status
gcloud run services describe muffin-detector --region=europe-west1
```

## 📚 Best Practices

### Code Quality
- **Immer Pre-commit Hooks verwenden**
- **Tests vor Push ausführen**
- **Type Hints verwenden**
- **Docstrings für öffentliche Funktionen**

### Security
- **Keine Secrets in Code committen**
- **Dependencies regelmäßig updaten**
- **Security Scans beachten**
- **Least Privilege Principle**

### Performance
- **Caching strategisch nutzen**
- **Parallele Jobs wo möglich**
- **Artifact Größe minimieren**
- **Build Zeit optimieren**

## 🔗 Weiterführende Links

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Google Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Python Testing Best Practices](https://docs.python.org/3/library/unittest.html)
