import io
import logging
import time
from typing import Any, Dict

from fastapi import FastAPI, File, HTTPException, UploadFile
from PIL import Image

from classifier import MuffinChihuahuaClassifier

# Logging konfigurieren
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# FastAPI App initialisieren
app = FastAPI(
    title="Muffin vs Chihuahua Detector",
    description="Ein Service zur Klassifizierung von Bildern als Muffins oder Chihuahuas - das berühmte Computer Vision Problem!",
    version="1.0.0",
)

# Classifier initialisieren
classifier = None


@app.on_event("startup")
async def startup_event():
    """Initialisiert den Classifier beim App-Start"""
    global classifier
    logger.info("Initialisiere Muffin/Chihuahua Classifier...")
    classifier = MuffinChihuahuaClassifier()
    logger.info("Classifier erfolgreich initialisiert!")


@app.get("/")
async def root():
    """Root endpoint mit Service-Informationen"""
    return {
        "service": "Muffin vs Chihuahua Detector",
        "version": "1.0.0",
        "status": "running",
        "description": "Das berühmte Computer Vision Problem: Unterscheide zwischen Muffins und Chihuahuas!",
        "endpoints": {
            "predict": "/predict - POST - Upload ein Bild zur Klassifizierung",
            "health": "/health - GET - Health Check",
        },
    }


@app.get("/health")
async def health_check():
    """Health Check Endpoint"""
    return {
        "status": "healthy",
        "timestamp": time.time(),
        "classifier_ready": classifier is not None,
    }


@app.post("/predict")
async def predict_image(file: UploadFile = File(...)) -> Dict[str, Any]:
    """
    Klassifiziert ein hochgeladenes Bild als Muffin oder Chihuahua

    Args:
        file: Hochgeladene Bilddatei

    Returns:
        Dict mit Vorhersage, Konfidenz und Verarbeitungszeit
    """
    start_time = time.time()

    try:
        # Validiere Dateityp
        if not file.content_type or not file.content_type.startswith("image/"):
            raise HTTPException(
                status_code=400, detail="Nur Bilddateien sind erlaubt (JPEG, PNG, etc.)"
            )

        # Lade und verarbeite das Bild
        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data))

        # Konvertiere zu RGB falls nötig
        if image.mode != "RGB":
            image = image.convert("RGB")

        # Klassifiziere das Bild
        if classifier is None:
            raise HTTPException(
                status_code=503,
                detail="Classifier ist nicht bereit. Versuche es später erneut.",
            )

        prediction, confidence = classifier.predict(image)

        processing_time = time.time() - start_time

        logger.info(
            f"Bild klassifiziert als {prediction} mit Konfidenz {confidence:.3f} in {processing_time:.3f}s"
        )

        return {
            "prediction": prediction,
            "confidence": round(confidence, 3),
            "processing_time": round(processing_time, 3),
            "filename": file.filename,
        }

    except HTTPException:
        # Re-raise HTTPExceptions (400, 503, etc.)
        raise
    except Exception as e:
        logger.error(f"Fehler bei der Bildklassifizierung: {str(e)}")
        raise HTTPException(
            status_code=500, detail=f"Fehler bei der Bildverarbeitung: {str(e)}"
        )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
