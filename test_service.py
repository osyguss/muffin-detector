#!/usr/bin/env python3
"""
Einfaches Test-Script für den Muffin vs Chihuahua Detector Service
"""

import sys
from pathlib import Path

import requests


def test_service(image_path: str, service_url: str = "http://localhost:8000"):
    """
    Testet den Service mit einem Bild

    Args:
        image_path: Pfad zum Testbild
        service_url: URL des Services
    """

    # Prüfe ob das Bild existiert
    if not Path(image_path).exists():
        print(f"❌ Bild nicht gefunden: {image_path}")
        return False

    try:
        # Health Check
        print("🔍 Prüfe Service Status...")
        health_response = requests.get(f"{service_url}/health")
        if health_response.status_code == 200:
            print("✅ Service ist erreichbar")
        else:
            print("❌ Service nicht erreichbar")
            return False

        # Bild hochladen und klassifizieren
        print(f"📤 Lade Bild hoch: {image_path}")

        with open(image_path, "rb") as f:
            files = {"file": f}
            response = requests.post(f"{service_url}/predict", files=files)

        if response.status_code == 200:
            result = response.json()
            print("🎉 Klassifizierung erfolgreich!")
            print(f"   Vorhersage: {result['prediction']}")
            print(f"   Konfidenz: {result['confidence']:.3f}")
            print(f"   Verarbeitungszeit: {result['processing_time']:.3f}s")

            # Emoji basierend auf Vorhersage
            emoji = "🧁" if result["prediction"] == "muffin" else "🐕"
            print(
                f"   {emoji} Das Bild wurde als {result['prediction']} klassifiziert!"
            )

            return True
        else:
            print(f"❌ Fehler bei der Klassifizierung: {response.status_code}")
            print(f"   {response.text}")
            return False

    except requests.exceptions.ConnectionError:
        print("❌ Kann keine Verbindung zum Service herstellen")
        print(
            "   Stelle sicher, dass der Service läuft: uvicorn main:app --host 0.0.0.0 --port 8000"
        )
        return False
    except Exception as e:
        print(f"❌ Unerwarteter Fehler: {e}")
        return False


def main():
    """Hauptfunktion"""
    if len(sys.argv) != 2:
        print("Usage: python test_service.py <image_path>")
        print("Beispiel: python test_service.py test_muffin.jpg")
        sys.exit(1)

    image_path = sys.argv[1]
    success = test_service(image_path)

    if success:
        print("\n✅ Test erfolgreich abgeschlossen!")
    else:
        print("\n❌ Test fehlgeschlagen!")
        sys.exit(1)


if __name__ == "__main__":
    main()
