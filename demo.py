#!/usr/bin/env python3
"""
Demo Script für den Muffin vs Chihuahua Detector
Zeigt die Funktionalität des Classifiers ohne FastAPI
"""

import sys
from pathlib import Path

from PIL import Image

# Add src to Python path
src_path = Path(__file__).parent / "src"
sys.path.insert(0, str(src_path))

from src.classifier import MuffinChihuahuaClassifier


def create_demo_image():
    """Erstellt ein einfaches Demo-Bild für Tests"""
    # Erstelle ein einfaches braunes Rechteck als Platzhalter
    img = Image.new("RGB", (224, 224), color="brown")
    return img


def demo_classifier():
    """Demonstriert den Classifier direkt"""
    print("🧁🐕 Muffin vs Chihuahua Detector Demo")
    print("=" * 50)

    try:
        print("📥 Initialisiere Classifier...")
        classifier = MuffinChihuahuaClassifier()

        print("✅ Classifier erfolgreich geladen!")
        print(f"   Model: {classifier.model_name}")
        print(f"   Device: {classifier.device}")

        # Demo mit einem einfachen Bild
        print("\n🖼️  Teste mit Demo-Bild...")
        demo_img = create_demo_image()

        prediction, confidence = classifier.predict(demo_img)

        print("\n🎯 Ergebnis:")
        print(f"   Vorhersage: {prediction}")
        print(f"   Konfidenz: {confidence:.3f}")

        emoji = "🧁" if prediction == "muffin" else "🐕"
        print(f"   {emoji} Das Bild wurde als {prediction} klassifiziert!")

        print("\n📊 Model Info:")
        model_info = classifier.get_model_info()
        for key, value in model_info.items():
            print(f"   {key}: {value}")

    except Exception as e:
        print(f"❌ Fehler: {e}")
        print("\n💡 Mögliche Lösungen:")
        print("   - Stelle sicher, dass alle Dependencies installiert sind")
        print("   - Prüfe die Internetverbindung (Model wird heruntergeladen)")
        print("   - Versuche es mit einem anderen Model")


def demo_api_usage():
    """Zeigt wie die API verwendet wird"""
    print("\n" + "=" * 50)
    print("📡 API Usage Demo")
    print("=" * 50)

    print("🌐 FastAPI Service starten:")
    print("   uvicorn main:app --host 0.0.0.0 --port 8000")

    print("\n📤 Bild hochladen (curl):")
    print('   curl -X POST -F "file=@your_image.jpg" \\')
    print("        http://localhost:8000/predict")

    print("\n📤 Bild hochladen (Python):")
    print(
        """
import requests

with open('your_image.jpg', 'rb') as f:
    files = {'file': f}
    response = requests.post('http://localhost:8000/predict', files=files)
    result = response.json()
    print(f"Vorhersage: {result['prediction']}")
    print(f"Konfidenz: {result['confidence']}")
"""
    )

    print("\n🔍 Health Check:")
    print("   curl http://localhost:8000/health")

    print("\n📚 API Dokumentation:")
    print("   http://localhost:8000/docs")


if __name__ == "__main__":
    demo_classifier()
    demo_api_usage()

    print("\n" + "=" * 50)
    print("🚀 Nächste Schritte:")
    print("=" * 50)
    print("1. Service starten: uvicorn main:app --host 0.0.0.0 --port 8000")
    print("2. Testen: python test_service.py path/to/image.jpg")
    print(
        "3. Docker: docker build -t muffin-detector . && docker run -p 8000:8000 muffin-detector"
    )
    print("4. Cloud Deploy: ./deploy.sh")
    print("\n🎉 Viel Spaß beim Testen des Muffin vs Chihuahua Detectors!")
