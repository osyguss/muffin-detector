#!/bin/bash
# Konfiguration für existierendes GCP Projekt

set -e

# Deine Projekt-ID
PROJECT_ID="muffin-detector"
SERVICE_NAME="muffin-detector"
REGION="europe-west1"
SERVICE_ACCOUNT_NAME="github-actions"

echo "🔧 Configuring existing GCP project: $PROJECT_ID"

# 1. Projekt als aktiv setzen
echo "🎯 Setting active project..."
gcloud config set project $PROJECT_ID

# 2. Billing prüfen
echo "💳 Checking billing status..."
BILLING_ENABLED=$(gcloud beta billing projects describe $PROJECT_ID --format="value(billingEnabled)" 2>/dev/null || echo "false")
if [ "$BILLING_ENABLED" != "True" ]; then
    echo "❌ Billing not enabled. Please enable billing:"
    echo "https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
    read -p "Press Enter when billing is enabled..."
fi

# 3. APIs aktivieren
echo "🔧 Enabling required APIs..."
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable artifactregistry.googleapis.com

echo "⏳ Waiting for APIs to be ready..."
sleep 10

# 4. Service Account erstellen
echo "👤 Creating service account for GitHub Actions..."
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name="GitHub Actions Service Account" \
    --description="Service account for automated deployments from GitHub Actions" \
    2>/dev/null || echo "Service account might already exist"

# 5. Berechtigungen zuweisen
echo "🔐 Assigning permissions..."
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Cloud Run Admin
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/run.admin" \
    --quiet

# Storage Admin (für Container Registry)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/storage.admin" \
    --quiet

# Service Account User (für Cloud Run)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/iam.serviceAccountUser" \
    --quiet

# Artifact Registry Admin
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/artifactregistry.admin" \
    --quiet

# 6. Service Account Key erstellen
echo "🔑 Creating service account key..."
KEY_FILE="github-actions-key.json"
gcloud iam service-accounts keys create $KEY_FILE \
    --iam-account=$SERVICE_ACCOUNT_EMAIL

echo "✅ Service account key created: $KEY_FILE"

# 7. Container Registry vorbereiten
echo "📦 Setting up Container Registry..."
gcloud auth configure-docker --quiet

# 8. Placeholder Cloud Run Service erstellen
echo "🌐 Creating placeholder Cloud Run service..."

# Verwende ein einfaches Hello-World Image für den ersten Deploy
gcloud run deploy $SERVICE_NAME \
    --image gcr.io/cloudrun/hello \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --port 8080 \
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
echo "🎉 Configuration completed successfully!"
echo ""
echo "📋 GitHub Secrets to add:"
echo "========================"
echo "GCP_PROJECT_ID:"
echo "$PROJECT_ID"
echo ""
echo "GCP_SA_KEY:"
cat $KEY_FILE
echo ""
echo "📊 Service Info:"
echo "================"
echo "Service URL: $SERVICE_URL"
echo "Service Account: $SERVICE_ACCOUNT_EMAIL"
echo ""
echo "🧪 Test the placeholder service:"
echo "curl $SERVICE_URL"
echo ""
echo "📝 Next steps:"
echo "1. Add the GitHub Secrets above to your repository"
echo "2. Commit and push to trigger CD pipeline"
echo "3. Your service will be automatically deployed!"

# Cleanup - Key-Datei löschen nach Ausgabe
rm $KEY_FILE

echo ""
echo "✅ Setup complete! Ready for CD pipeline."
