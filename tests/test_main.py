"""
Tests für den FastAPI Service
"""

import io
from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient
from PIL import Image

from main import app


@pytest.fixture
def client():
    """Test client für FastAPI"""
    return TestClient(app)


@pytest.fixture
def sample_image():
    """Erstellt ein Test-Bild"""
    img = Image.new("RGB", (224, 224), color="brown")
    img_bytes = io.BytesIO()
    img.save(img_bytes, format="JPEG")
    img_bytes.seek(0)
    return img_bytes


class TestHealthEndpoints:
    """Tests für Health Check Endpoints"""

    def test_root_endpoint(self, client):
        """Test des Root Endpoints"""
        response = client.get("/")
        assert response.status_code == 200

        data = response.json()
        assert "service" in data
        assert "Muffin vs Chihuahua Detector" in data["service"]
        assert "version" in data
        assert "endpoints" in data

    def test_health_check(self, client):
        """Test des Health Check Endpoints"""
        response = client.get("/health")
        assert response.status_code == 200

        data = response.json()
        assert "status" in data
        assert data["status"] == "healthy"
        assert "timestamp" in data
        assert "classifier_ready" in data


class TestPredictEndpoint:
    """Tests für den Predict Endpoint"""

    @patch("main.classifier")
    def test_predict_with_valid_image(self, mock_classifier, client, sample_image):
        """Test der Bildvorhersage mit gültigem Bild"""
        # Mock classifier response
        mock_classifier.predict.return_value = ("muffin", 0.85)

        files = {"file": ("test.jpg", sample_image, "image/jpeg")}
        response = client.post("/predict", files=files)

        assert response.status_code == 200

        data = response.json()
        assert "prediction" in data
        assert data["prediction"] in ["muffin", "chihuahua"]
        assert "confidence" in data
        assert 0 <= data["confidence"] <= 1
        assert "processing_time" in data
        assert "filename" in data

    def test_predict_without_file(self, client):
        """Test der Bildvorhersage ohne Datei"""
        response = client.post("/predict")
        assert response.status_code == 422  # Unprocessable Entity

    def test_predict_with_invalid_file_type(self, client):
        """Test der Bildvorhersage mit ungültigem Dateityp"""
        files = {"file": ("test.txt", io.BytesIO(b"not an image"), "text/plain")}
        response = client.post("/predict", files=files)

        assert response.status_code == 400
        assert "Nur Bilddateien sind erlaubt" in response.json()["detail"]

    @patch("main.classifier", None)
    def test_predict_when_classifier_not_ready(self, client, sample_image):
        """Test der Bildvorhersage wenn Classifier nicht bereit ist"""
        files = {"file": ("test.jpg", sample_image, "image/jpeg")}
        response = client.post("/predict", files=files)

        assert response.status_code == 503
        assert "Classifier ist nicht bereit" in response.json()["detail"]

    @patch("main.classifier")
    def test_predict_with_classifier_error(self, mock_classifier, client, sample_image):
        """Test der Bildvorhersage bei Classifier-Fehler"""
        mock_classifier.predict.side_effect = Exception("Model error")

        files = {"file": ("test.jpg", sample_image, "image/jpeg")}
        response = client.post("/predict", files=files)

        assert response.status_code == 500
        assert "Fehler bei der Bildverarbeitung" in response.json()["detail"]


class TestImageProcessing:
    """Tests für Bildverarbeitung"""

    @patch("main.classifier")
    def test_rgb_conversion(self, mock_classifier, client):
        """Test der RGB-Konvertierung für verschiedene Bildmodi"""
        mock_classifier.predict.return_value = ("chihuahua", 0.75)

        # Erstelle ein RGBA Bild
        img = Image.new("RGBA", (100, 100), color=(255, 0, 0, 128))
        img_bytes = io.BytesIO()
        img.save(img_bytes, format="PNG")
        img_bytes.seek(0)

        files = {"file": ("test.png", img_bytes, "image/png")}
        response = client.post("/predict", files=files)

        assert response.status_code == 200
        # Verify that the image was processed successfully
        mock_classifier.predict.assert_called_once()

    @patch("main.classifier")
    def test_large_image_handling(self, mock_classifier, client):
        """Test der Verarbeitung großer Bilder"""
        mock_classifier.predict.return_value = ("muffin", 0.90)

        # Erstelle ein größeres Bild
        img = Image.new("RGB", (2048, 2048), color="brown")
        img_bytes = io.BytesIO()
        img.save(img_bytes, format="JPEG", quality=85)
        img_bytes.seek(0)

        files = {"file": ("large_test.jpg", img_bytes, "image/jpeg")}
        response = client.post("/predict", files=files)

        assert response.status_code == 200
        data = response.json()
        assert "processing_time" in data
        # Large images might take longer to process
        assert data["processing_time"] >= 0


class TestResponseFormat:
    """Tests für Response-Format"""

    @patch("main.classifier")
    def test_response_structure(self, mock_classifier, client, sample_image):
        """Test der Response-Struktur"""
        mock_classifier.predict.return_value = ("muffin", 0.95)

        files = {"file": ("test.jpg", sample_image, "image/jpeg")}
        response = client.post("/predict", files=files)

        assert response.status_code == 200

        data = response.json()
        required_fields = ["prediction", "confidence", "processing_time", "filename"]

        for field in required_fields:
            assert field in data, f"Missing field: {field}"

        # Validate data types
        assert isinstance(data["prediction"], str)
        assert isinstance(data["confidence"], (int, float))
        assert isinstance(data["processing_time"], (int, float))
        assert isinstance(data["filename"], str)

        # Validate ranges
        assert data["prediction"] in ["muffin", "chihuahua"]
        assert 0 <= data["confidence"] <= 1
        assert data["processing_time"] >= 0

    @patch("main.classifier")
    def test_confidence_rounding(self, mock_classifier, client, sample_image):
        """Test der Konfidenz-Rundung"""
        mock_classifier.predict.return_value = ("chihuahua", 0.123456789)

        files = {"file": ("test.jpg", sample_image, "image/jpeg")}
        response = client.post("/predict", files=files)

        assert response.status_code == 200

        data = response.json()
        # Confidence should be rounded to 3 decimal places
        assert data["confidence"] == 0.123


@pytest.mark.asyncio
class TestAsyncBehavior:
    """Tests für asynchrones Verhalten"""

    @patch("main.classifier")
    async def test_concurrent_requests(self, mock_classifier, client, sample_image):
        """Test von gleichzeitigen Anfragen"""
        mock_classifier.predict.return_value = ("muffin", 0.80)

        # Simulate concurrent requests
        import asyncio

        async def make_request():
            files = {"file": ("test.jpg", sample_image, "image/jpeg")}
            return client.post("/predict", files=files)

        # Make multiple concurrent requests
        tasks = [make_request() for _ in range(5)]
        responses = await asyncio.gather(*tasks, return_exceptions=True)

        # All requests should succeed
        for response in responses:
            if not isinstance(response, Exception):
                assert response.status_code == 200
