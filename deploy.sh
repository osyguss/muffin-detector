#!/bin/bash
# Deployment Script für Google Cloud Run

set -e

# Konfiguration
PROJECT_ID=${GCP_PROJECT_ID:-"your-project-id"}
SERVICE_NAME="muffin-detector"
REGION="europe-west1"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

echo "🚀 Deploying Muffin vs Chihuahua Detector to Google Cloud Run"
echo "   Project: ${PROJECT_ID}"
echo "   Service: ${SERVICE_NAME}"
echo "   Region: ${REGION}"

# Prüfe ob gcloud installiert ist
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI ist nicht installiert"
    echo "   Installiere es von: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Prüfe ob Docker installiert ist
if ! command -v docker &> /dev/null; then
    echo "❌ Docker ist nicht installiert"
    exit 1
fi

# Authentifizierung prüfen
echo "🔐 Prüfe Google Cloud Authentifizierung..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ Nicht bei Google Cloud angemeldet"
    echo "   Führe aus: gcloud auth login"
    exit 1
fi

# Docker für GCR konfigurieren
echo "🐳 Konfiguriere Docker für Google Container Registry..."
gcloud auth configure-docker --quiet

# Docker Image bauen
echo "🔨 Baue Docker Image..."
docker build -t ${IMAGE_NAME}:latest .
docker tag ${IMAGE_NAME}:latest ${IMAGE_NAME}:$(date +%Y%m%d-%H%M%S)

# Image zu GCR pushen
echo "📤 Pushe Image zu Google Container Registry..."
docker push ${IMAGE_NAME}:latest

# Service zu Cloud Run deployen
echo "☁️  Deploye Service zu Cloud Run..."
gcloud run deploy ${SERVICE_NAME} \
    --image ${IMAGE_NAME}:latest \
    --platform managed \
    --region ${REGION} \
    --allow-unauthenticated \
    --memory 2Gi \
    --cpu 1 \
    --timeout 300 \
    --max-instances 10 \
    --set-env-vars="ENVIRONMENT=production" \
    --project ${PROJECT_ID}

# Service URL abrufen
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} \
    --region=${REGION} \
    --project=${PROJECT_ID} \
    --format='value(status.url)')

echo ""
echo "🎉 Deployment erfolgreich!"
echo "   Service URL: ${SERVICE_URL}"
echo "   Health Check: ${SERVICE_URL}/health"
echo "   API Docs: ${SERVICE_URL}/docs"
echo ""
echo "📝 Teste den Service:"
echo "   curl -X POST -F \"file=@your_image.jpg\" ${SERVICE_URL}/predict"
