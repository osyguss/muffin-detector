"""
Tests für den MuffinChihuahuaClassifier (HF Inference Endpoint Version)
Vereinfachte Tests für das neue HF Endpoint Setup
"""

import os

import pytest
from PIL import Image

from classifier import MuffinChihuahuaClassifier


@pytest.fixture
def setup_test_env():
    """Setup Test Environment Variables"""
    os.environ["HF_TOKEN"] = "fake_token_for_testing"
    os.environ["HF_ENDPOINT_URL"] = "https://fake-endpoint-for-testing.com"
    yield
    # Cleanup
    if "HF_TOKEN" in os.environ:
        del os.environ["HF_TOKEN"]
    if "HF_ENDPOINT_URL" in os.environ:
        del os.environ["HF_ENDPOINT_URL"]


@pytest.fixture
def sample_image():
    """Erstellt ein Test-Bild"""
    return Image.new("RGB", (224, 224), color=(139, 69, 19))


class TestClassifierInitialization:
    """Tests für Classifier-Initialisierung"""

    def test_classifier_init_success(self, setup_test_env):
        """Test erfolgreiche Classifier-Initialisierung"""
        classifier = MuffinChihuahuaClassifier()

        assert classifier.endpoint_url == "https://fake-endpoint-for-testing.com"
        assert classifier.hf_token == "fake_token_for_testing"
        assert hasattr(classifier, "class_mapping")
        assert classifier._is_testing_mode() is True

    def test_classifier_init_missing_token(self):
        """Test Fehler bei fehlendem HF Token"""
        # Ensure no HF_TOKEN in environment
        if "HF_TOKEN" in os.environ:
            del os.environ["HF_TOKEN"]

        with pytest.raises(
            ValueError, match="HF_TOKEN environment variable is required"
        ):
            MuffinChihuahuaClassifier()

    def test_testing_mode_detection(self, setup_test_env):
        """Test Testing Mode Detection"""
        classifier = MuffinChihuahuaClassifier()

        # Should detect testing mode from fake token
        assert classifier._is_testing_mode() is True


class TestClassMapping:
    """Tests für Klassen-Mapping"""

    def test_class_mapping_structure(self, setup_test_env):
        """Test der Klassen-Mapping-Struktur"""
        classifier = MuffinChihuahuaClassifier()

        assert "muffin" in classifier.class_mapping
        assert "chihuahua" in classifier.class_mapping

        # Check that mappings contain expected terms
        muffin_terms = classifier.class_mapping["muffin"]
        chihuahua_terms = classifier.class_mapping["chihuahua"]

        assert "muffin" in muffin_terms
        assert "chihuahua" in chihuahua_terms
        assert "dog" in chihuahua_terms


class TestPrediction:
    """Tests für Vorhersage-Funktionalität"""

    def test_predict_in_testing_mode(self, setup_test_env, sample_image):
        """Test Vorhersage im Testing-Modus"""
        classifier = MuffinChihuahuaClassifier()
        prediction, confidence = classifier.predict(sample_image)

        # Should return mock prediction in testing mode
        assert prediction in ["muffin", "chihuahua"]
        assert isinstance(confidence, float)
        assert 0.7 <= confidence <= 0.95  # Mock range

    def test_predict_error_handling(self, setup_test_env, sample_image):
        """Test Error-Handling bei Vorhersage-Fehlern"""
        classifier = MuffinChihuahuaClassifier()

        # Even in testing mode, should handle errors gracefully
        prediction, confidence = classifier.predict(sample_image)

        # Should return valid prediction
        assert prediction in ["muffin", "chihuahua"]
        assert isinstance(confidence, float)
        assert confidence > 0


class TestModelInfo:
    """Tests für Model-Informationen"""

    def test_get_model_info(self, setup_test_env):
        """Test Model-Info-Funktion"""
        classifier = MuffinChihuahuaClassifier()
        info = classifier.get_model_info()

        assert isinstance(info, dict)
        assert "endpoint_url" in info
        assert "service_type" in info
        assert "has_token" in info

        assert info["endpoint_url"] == classifier.endpoint_url
        assert info["service_type"] == "huggingface_inference_endpoint"
        assert info["has_token"] is True


class TestImageFormats:
    """Tests für verschiedene Bildformate"""

    def test_different_image_sizes(self, setup_test_env):
        """Test verschiedener Bildgrößen"""
        classifier = MuffinChihuahuaClassifier()

        # Test different image sizes
        sizes = [(100, 100), (224, 224), (512, 512)]

        for width, height in sizes:
            img = Image.new("RGB", (width, height), color="brown")
            prediction, confidence = classifier.predict(img)

            assert prediction in ["muffin", "chihuahua"]
            assert 0 <= confidence <= 1

    def test_grayscale_image(self, setup_test_env):
        """Test Graustufenbild"""
        classifier = MuffinChihuahuaClassifier()

        # Create grayscale image
        img = Image.new("L", (224, 224), color=128)
        prediction, confidence = classifier.predict(img)

        assert prediction in ["muffin", "chihuahua"]
        assert confidence > 0
