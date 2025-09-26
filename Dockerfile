# Lightweight Python API Container (nur für HF Inference Endpoint)
FROM python:3.11-slim

# Arbeitsverzeichnis erstellen
WORKDIR /app

# System-Dependencies (minimal)
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Python Dependencies installieren
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# App Code kopieren
COPY src/ ./src/
COPY app.py .

# Non-root User erstellen für Sicherheit
RUN useradd --create-home --shell /bin/bash app && \
    chown -R app:app /app
USER app

# Port exposieren
EXPOSE 8000

# Health Check (einfacher)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# App starten
CMD ["python", "app.py"]
