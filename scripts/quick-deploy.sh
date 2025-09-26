#!/bin/bash
# Quick Deploy Script für lokale Tests

set -e

# Konfiguration
PROJECT_ID="${GCP_PROJECT_ID:-muffin-detector-dev}"
SERVICE_NAME="muffin-detector"
REGION="europe-west1"

echo "🚀 Quick Deploy to Cloud Run"
echo "Project: $PROJECT_ID"
echo "Service: $SERVICE_NAME"

# 1. Prüfe gcloud Installation
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI not found. Please install Google Cloud SDK"
    echo "https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# 2. Prüfe Docker Installation
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker"
    exit 1
fi

# 3. Authentifizierung prüfen
echo "🔐 Checking authentication..."
gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1 || {
    echo "❌ Not authenticated. Please run: gcloud auth login"
    exit 1
}

# 4. Projekt setzen
echo "📋 Setting project..."
gcloud config set project $PROJECT_ID

# 5. Docker für GCR konfigurieren
echo "🐳 Configuring Docker for GCR..."
gcloud auth configure-docker --quiet

# 6. Image bauen
echo "🔨 Building Docker image..."
IMAGE_TAG="gcr.io/$PROJECT_ID/$SERVICE_NAME:$(git rev-parse --short HEAD)"
docker build -t $IMAGE_TAG .

# 7. Image pushen
echo "📤 Pushing image to GCR..."
docker push $IMAGE_TAG

# 8. Zu Cloud Run deployen
echo "🚀 Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image $IMAGE_TAG \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --port 8000 \
    --memory 2Gi \
    --cpu 1 \
    --min-instances 0 \
    --max-instances 10 \
    --timeout 300 \
    --set-env-vars="ENVIRONMENT=development" \
    --quiet

# 9. Service URL abrufen
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
    --platform managed \
    --region $REGION \
    --format 'value(status.url)')

echo ""
echo "✅ Deployment successful!"
echo "🌐 Service URL: $SERVICE_URL"
echo ""
echo "🧪 Testing service..."
curl -f "$SERVICE_URL/health" && echo "✅ Health check passed!" || echo "❌ Health check failed"

echo ""
echo "📊 Service info:"
gcloud run services describe $SERVICE_NAME --region $REGION --format="table(
    metadata.name,
    status.url,
    status.conditions[0].type,
    spec.template.spec.containers[0].image
)"
