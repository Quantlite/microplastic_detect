# Multi-stage build: Backend (Python)
FROM python:3.10-slim as backend-builder

WORKDIR /tmp/build
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    && rm -rf /var/lib/apt/lists/*

COPY backend.zip .
RUN unzip -q backend.zip

# Final stage: Runtime
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy backend from builder
COPY --from=backend-builder /tmp/build/backend /app/backend

# Install Python dependencies
RUN pip install --no-cache-dir -r /app/backend/requirements.txt

# Copy frontend
COPY frontend.zip .
RUN apt-get update && apt-get install -y --no-install-recommends unzip && \
    unzip -q frontend.zip && \
    rm -rf /var/lib/apt/lists/* frontend.zip

# Expose port
EXPOSE 8000

# Set working directory and run backend
WORKDIR /app/backend
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
