#!/bin/bash
# Google Cloud Platform Setup für Muffin Detector Service

set -e

# Konfiguration
PROJECT_ID="muffin-detector"  # Eindeutige Project ID
SERVICE_NAME="muffin-detector-service"
REGION="europe-west1"
SERVICE_ACCOUNT_NAME="github-actions"

echo "🚀 Setting up Google Cloud Platform for Muffin Detector"
echo "Project ID: $PROJECT_ID"
echo "Service: $SERVICE_NAME"
echo "Region: $REGION"

# 1. Neues Projekt erstellen (optional)
echo "📋 Creating GCP Project..."
gcloud projects create $PROJECT_ID --name="Muffin Detector" || echo "Project might already exist"

# 2. Projekt als aktiv setzen
echo "🎯 Setting active project..."
gcloud config set project $PROJECT_ID

# 3. Billing Account verknüpfen (manuell erforderlich)
echo "💳 Please link a billing account to this project in the GCP Console:"
echo "https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
read -p "Press Enter when billing is set up..."

# 4. APIs aktivieren
echo "🔧 Enabling required APIs..."
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable artifactregistry.googleapis.com

# 5. Service Account für GitHub Actions erstellen
echo "👤 Creating service account for GitHub Actions..."
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name="GitHub Actions Service Account" \
    --description="Service account for automated deployments from GitHub Actions"

# 6. Berechtigungen zuweisen
echo "🔐 Assigning permissions..."
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Cloud Run Admin
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/run.admin"

# Storage Admin (für Container Registry)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/storage.admin"

# Service Account User (für Cloud Run)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/iam.serviceAccountUser"

# Artifact Registry Admin
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/artifactregistry.admin"

# 7. Service Account Key erstellen
echo "🔑 Creating service account key..."
KEY_FILE="github-actions-key.json"
gcloud iam service-accounts keys create $KEY_FILE \
    --iam-account=$SERVICE_ACCOUNT_EMAIL

echo "✅ Service account key created: $KEY_FILE"
echo "⚠️  Keep this file secure and add it to GitHub Secrets!"

# 8. Container Registry vorbereiten
echo "📦 Setting up Container Registry..."
gcloud auth configure-docker

# 9. Erstelle initiales Cloud Run Service
echo "🌐 Creating initial Cloud Run service..."

# Erstelle ein minimales Docker Image für den ersten Deploy
cat > Dockerfile.init << 'EOF'
FROM nginx:alpine
COPY <<HTML /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html>
<head><title>Muffin Detector - Coming Soon</title></head>
<body>
    <h1>🧁 Muffin vs Chihuahua Detector</h1>
    <p>Service is being deployed...</p>
    <p>This is a placeholder page.</p>
</body>
</html>
HTML
EXPOSE 80
EOF

# Build und push initial image
docker build -f Dockerfile.init -t gcr.io/$PROJECT_ID/$SERVICE_NAME:init .
docker push gcr.io/$PROJECT_ID/$SERVICE_NAME:init

# Deploy zu Cloud Run
gcloud run deploy $SERVICE_NAME \
    --image gcr.io/$PROJECT_ID/$SERVICE_NAME:init \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --port 80 \
    --memory 512Mi \
    --cpu 1 \
    --min-instances 0 \
    --max-instances 10 \
    --quiet

# Service URL abrufen
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME \
    --platform managed \
    --region $REGION \
    --format 'value(status.url)')

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "📋 Summary:"
echo "  Project ID: $PROJECT_ID"
echo "  Service Account: $SERVICE_ACCOUNT_EMAIL"
echo "  Service URL: $SERVICE_URL"
echo "  Key File: $KEY_FILE"
echo ""
echo "📝 Next steps:"
echo "1. Add these GitHub Secrets:"
echo "   GCP_PROJECT_ID: $PROJECT_ID"
echo "   GCP_SA_KEY: $(cat $KEY_FILE | base64 -w 0)"
echo ""
echo "2. Test the service:"
echo "   curl $SERVICE_URL"
echo ""
echo "3. Enable CD Pipeline in GitHub Actions"

# Cleanup
rm Dockerfile.init
rm $KEY_FILE  # Warnung: Key wurde bereits ausgegeben

echo "✅ GCP Setup complete!"
