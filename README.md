# Muffin vs Chihuahua Detector 🧁🐕

Ein Python-Service zur Klassifizierung von Bildern als Muffins oder Chihuahuas mit Hilfe von Machine Learning.

Das berühmte "Muffin vs Chihuahua" Problem der Computer Vision - überraschend schwierig aufgrund der visuellen Ähnlichkeiten!

## Features

- REST API für Bild-Upload und Klassifizierung
- Hugging Face Transformers Integration
- Docker-Container Support
- Google Cloud Run Deployment Ready
- CI/CD Pipeline mit GitHub Actions

## Installation

1. Repository klonen:
```bash
git clone <repository-url>
cd muffin-detector
```

2. Dependencies installieren:
```bash
pip install -r requirements.txt
```

3. Service starten:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000
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

## Entwicklung

Das Projekt nutzt ein vortrainiertes Hugging Face Model für die Bildklassifizierung. Das Model wird beim ersten Start automatisch heruntergeladen.
