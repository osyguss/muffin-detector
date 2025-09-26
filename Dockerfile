# Multi-stage build für optimierte Container-Größe
FROM python:3.11-slim as builder

# System-Dependencies installieren (mit Cache)
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Python Dependencies installieren (optimiert für Caching)
COPY requirements.txt .

# Pip Cache und Parallel Installation
RUN pip install --no-cache-dir --user \
    --index-url https://download.pytorch.org/whl/cpu \
    torch torchvision torchaudio --extra-index-url https://pypi.org/simple

RUN pip install --no-cache-dir --user -r requirements.txt

# Production Stage
FROM python:3.11-slim

# Arbeitsverzeichnis erstellen
WORKDIR /app

# System-Dependencies für Runtime
RUN apt-get update && apt-get install -y \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Python Dependencies von Builder kopieren
COPY --from=builder /root/.local /root/.local

# PATH für lokale Python Packages
ENV PATH=/root/.local/bin:$PATH

# App Code kopieren
COPY src/ ./src/
COPY app.py .

# Non-root User erstellen für Sicherheit
RUN useradd --create-home --shell /bin/bash app
USER app

# Port exposieren
EXPOSE 8000

# Health Check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')" || exit 1

# App starten
CMD ["python", "app.py"]
