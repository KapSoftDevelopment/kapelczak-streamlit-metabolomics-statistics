# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create data directory for user uploads
RUN mkdir -p /app/data

# Expose Streamlit port
EXPOSE 8502

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8502/_stcore/health || exit 1

# Run Streamlit app
CMD ["streamlit", "run", "Statistics_for_Metabolomics.py", "--server.port=8502", "--server.address=0.0.0.0", "--server.headless=true", "--browser.gatherUsageStats=false"]