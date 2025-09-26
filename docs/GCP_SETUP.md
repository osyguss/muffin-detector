# 🚀 Google Cloud Platform Setup für Muffin Detector

## Übersicht

Diese Anleitung führt dich durch das Setup von Google Cloud Run für den Muffin vs Chihuahua Detector Service.

## 📋 Voraussetzungen

- Google Cloud Account
- Billing Account aktiviert
- Browser-Zugang zur GCP Console

## 🛠️ Setup Schritte

### 1. Neues GCP Projekt erstellen

1. Gehe zur [GCP Console](https://console.cloud.google.com/)
2. Klicke auf "Projekt auswählen" → "Neues Projekt"
3. **Projekt-Name**: `Muffin Detector`
4. **Projekt-ID**: `muffin-detector-[eindeutige-nummer]`
5. Klicke "Erstellen"

### 2. Billing Account verknüpfen

1. Gehe zu [Billing](https://console.cloud.google.com/billing)
2. Wähle dein Projekt aus
3. Verknüpfe ein Billing Account

### 3. APIs aktivieren

Gehe zu [APIs & Services](https://console.cloud.google.com/apis) und aktiviere:

- ✅ **Cloud Run API**
- ✅ **Cloud Build API** 
- ✅ **Container Registry API**
- ✅ **Artifact Registry API**

```bash
# Oder via gcloud CLI:
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable artifactregistry.googleapis.com
```

### 4. Service Account erstellen

1. Gehe zu [IAM & Admin → Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts)
2. Klicke "Service Account erstellen"
3. **Name**: `github-actions`
4. **Beschreibung**: `Service account for automated deployments from GitHub Actions`

### 5. Berechtigungen zuweisen

Weise dem Service Account folgende Rollen zu:

- ✅ **Cloud Run Admin** (`roles/run.admin`)
- ✅ **Storage Admin** (`roles/storage.admin`)
- ✅ **Service Account User** (`roles/iam.serviceAccountUser`)
- ✅ **Artifact Registry Admin** (`roles/artifactregistry.admin`)

### 6. Service Account Key erstellen

1. Klicke auf den erstellten Service Account
2. Gehe zu "Keys" → "Add Key" → "Create new key"
3. Wähle **JSON** Format
4. **Speichere die JSON-Datei sicher!**

### 7. GitHub Secrets konfigurieren

Gehe zu deinem GitHub Repository → Settings → Secrets and variables → Actions:

#### Secrets hinzufügen:

1. **`GCP_PROJECT_ID`**
   ```
   muffin-detector-[deine-nummer]
   ```

2. **`GCP_SA_KEY`**
   ```json
   {
     "type": "service_account",
     "project_id": "muffin-detector-...",
     "private_key_id": "...",
     "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
     "client_email": "github-actions@muffin-detector-....iam.gserviceaccount.com",
     "client_id": "...",
     "auth_uri": "https://accounts.google.com/o/oauth2/auth",
     "token_uri": "https://oauth2.googleapis.com/token",
     "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
     "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/github-actions%40muffin-detector-....iam.gserviceaccount.com"
   }
   ```

### 8. Initiales Cloud Run Service erstellen

#### Option A: Via gcloud CLI

```bash
# Projekt setzen
gcloud config set project muffin-detector-[deine-nummer]

# Placeholder Service erstellen
gcloud run deploy muffin-detector \
  --image gcr.io/cloudrun/hello \
  --platform managed \
  --region europe-west1 \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10
```

#### Option B: Via GCP Console

1. Gehe zu [Cloud Run](https://console.cloud.google.com/run)
2. Klicke "Service erstellen"
3. **Container Image URL**: `gcr.io/cloudrun/hello` (Placeholder)
4. **Service Name**: `muffin-detector`
5. **Region**: `europe-west1`
6. **Authentication**: Allow unauthenticated invocations
7. **Container Port**: `8080`
8. **Memory**: `512 MiB`
9. **CPU**: `1`
10. **Min instances**: `0`
11. **Max instances**: `10`
12. Klicke "Erstellen"

### 9. Service URL notieren

Nach der Erstellung findest du die Service URL in der Cloud Run Console:
```
https://muffin-detector-[hash]-ew.a.run.app
```

## ✅ Verifikation

### Test des Placeholder Service:

```bash
curl https://muffin-detector-[hash]-ew.a.run.app
```

Du solltest eine "Hello World" Nachricht sehen.

### GitHub Secrets prüfen:

Gehe zu deinem Repository → Settings → Secrets:
- ✅ `GCP_PROJECT_ID` ist gesetzt
- ✅ `GCP_SA_KEY` ist gesetzt (JSON-Inhalt)

## 🚀 CD Pipeline aktivieren

Sobald das Setup abgeschlossen ist:

1. **CD Pipeline aktivieren**:
   ```bash
   mv .github/workflows/cd-deploy.yml.disabled .github/workflows/cd-deploy.yml
   ```

2. **Commit und Push**:
   ```bash
   git add .
   git commit -m "feat: enable CD pipeline for Cloud Run deployment"
   git push origin main
   ```

3. **Pipeline beobachten**:
   - Gehe zu GitHub Actions
   - Die CD Pipeline sollte automatisch starten
   - Nach ~10-15 Minuten sollte der Service deployed sein

## 🔧 Troubleshooting

### Häufige Probleme:

#### 1. "Permission denied" Fehler
- Prüfe Service Account Berechtigungen
- Stelle sicher, dass alle APIs aktiviert sind

#### 2. "Billing not enabled"
- Aktiviere Billing für das Projekt
- Verknüpfe ein gültiges Billing Account

#### 3. "Service not found"
- Prüfe Projekt-ID in GitHub Secrets
- Stelle sicher, dass Cloud Run API aktiviert ist

#### 4. "Invalid service account key"
- Erstelle einen neuen Service Account Key
- Prüfe JSON-Format in GitHub Secret

### Logs prüfen:

```bash
# Cloud Run Logs
gcloud logs read --service=muffin-detector --region=europe-west1

# Build Logs
gcloud builds list --limit=10
```

## 📊 Kosten

Geschätzte monatliche Kosten bei geringer Nutzung:
- **Cloud Run**: ~$0-5 (Pay-per-use)
- **Container Registry**: ~$0-1 (Storage)
- **Cloud Build**: ~$0-2 (Build-Zeit)

**Total**: ~$0-8/Monat bei Development-Nutzung

## 🎯 Nächste Schritte

Nach erfolgreichem Setup:

1. ✅ CD Pipeline testen
2. ✅ Service-Monitoring einrichten
3. ✅ Custom Domain konfigurieren (optional)
4. ✅ SSL/TLS Zertifikat (automatisch)
5. ✅ Logging und Alerting konfigurieren
