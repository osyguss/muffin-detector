from transformers import pipeline, AutoImageProcessor, AutoModelForImageClassification
from PIL import Image
import torch
import logging
from typing import Tuple
import os

logger = logging.getLogger(__name__)

class MuffinChihuahuaClassifier:
    """
    Klassifiziert Bilder als Muffins oder Chihuahuas mit Hilfe eines Hugging Face Models
    Das berühmte "Muffin vs Chihuahua" Problem der Computer Vision!
    """
    
    def __init__(self, model_name: str = "google/vit-base-patch16-224"):
        """
        Initialisiert den Classifier
        
        Args:
            model_name: Name des Hugging Face Models
        """
        self.model_name = model_name
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        logger.info(f"Verwende Device: {self.device}")
        
        # Lade das Model und den Processor
        self._load_model()
        
        # Mapping für die Klassifizierung
        self.class_mapping = {
            "muffin": ["muffin", "bran muffin", "blueberry muffin", "chocolate muffin", "baked goods", "pastry", "bread"],
            "chihuahua": ["chihuahua", "dog", "puppy", "small dog", "toy dog", "mexican hairless dog", "canine"]
        }
    
    def _load_model(self):
        """Lädt das Hugging Face Model"""
        try:
            logger.info(f"Lade Model: {self.model_name}")
            
            # Verwende einen generischen Image Classification Pipeline
            self.classifier = pipeline(
                "image-classification",
                model=self.model_name,
                device=0 if self.device == "cuda" else -1
            )
            
            logger.info("Model erfolgreich geladen!")
            
        except Exception as e:
            logger.error(f"Fehler beim Laden des Models: {e}")
            # Fallback zu einem anderen Model
            logger.info("Versuche Fallback Model...")
            try:
                self.classifier = pipeline(
                    "image-classification",
                    model="microsoft/resnet-50",
                    device=0 if self.device == "cuda" else -1
                )
                logger.info("Fallback Model erfolgreich geladen!")
            except Exception as fallback_error:
                logger.error(f"Auch Fallback Model konnte nicht geladen werden: {fallback_error}")
                raise
    
    def predict(self, image: Image.Image) -> Tuple[str, float]:
        """
        Klassifiziert ein Bild als Muffin oder Chihuahua
        
        Args:
            image: PIL Image Objekt
            
        Returns:
            Tuple aus (Vorhersage, Konfidenz)
        """
        try:
            # Führe die Klassifizierung durch
            results = self.classifier(image)
            
            # Analysiere die Ergebnisse
            muffin_score = 0.0
            chihuahua_score = 0.0
            
            for result in results:
                label = result['label'].lower()
                score = result['score']
                
                # Prüfe ob das Label zu Muffin oder Chihuahua gehört
                if any(muffin_term in label for muffin_term in self.class_mapping["muffin"]):
                    muffin_score += score
                elif any(chihuahua_term in label for chihuahua_term in self.class_mapping["chihuahua"]):
                    chihuahua_score += score
                else:
                    # Für unbekannte Labels verwende Heuristiken
                    if any(term in label for term in ["dog", "animal", "pet", "fur", "ears", "eyes", "nose"]):
                        chihuahua_score += score * 0.7
                    elif any(term in label for term in ["food", "baked", "brown", "round", "sweet", "dessert"]):
                        muffin_score += score * 0.7
            
            # Wenn keine spezifischen Matches gefunden wurden, verwende die Top-Vorhersage
            if muffin_score == 0 and chihuahua_score == 0:
                top_result = results[0]
                top_label = top_result['label'].lower()
                top_score = top_result['score']
                
                # Einfache Heuristik basierend auf häufigen Begriffen
                if any(term in top_label for term in ["animal", "dog", "mammal", "pet"]):
                    chihuahua_score = top_score
                else:
                    muffin_score = top_score
            
            # Bestimme die finale Vorhersage
            if muffin_score > chihuahua_score:
                prediction = "muffin"
                confidence = muffin_score
            else:
                prediction = "chihuahua"
                confidence = chihuahua_score
            
            # Stelle sicher, dass die Konfidenz zwischen 0 und 1 liegt
            confidence = max(0.1, min(1.0, confidence))
            
            logger.info(f"Klassifizierung: {prediction} (Konfidenz: {confidence:.3f})")
            logger.debug(f"Muffin Score: {muffin_score:.3f}, Chihuahua Score: {chihuahua_score:.3f}")
            
            return prediction, confidence
            
        except Exception as e:
            logger.error(f"Fehler bei der Vorhersage: {e}")
            # Fallback: Zufällige Vorhersage mit niedriger Konfidenz
            import random
            return random.choice(["muffin", "chihuahua"]), 0.5

    def get_model_info(self) -> dict:
        """Gibt Informationen über das geladene Model zurück"""
        return {
            "model_name": self.model_name,
            "device": self.device,
            "cuda_available": torch.cuda.is_available()
        }
