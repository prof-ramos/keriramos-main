# Multi-stage Dockerfile for Brazilian Astrology API
# Stage 1: Builder stage for dependencies and compilation
FROM python:3.14-slim as builder

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies for building Python packages
# Group update and install commands, cleanup in same layer to reduce image size
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime stage for production
FROM python:3.14-slim as runtime

# Install runtime system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# Create non-root user for security with specific UID/GID
RUN groupadd -r astrology --gid 1001 && useradd -r -g astrology --uid 1001 astrology

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONPATH="/app"

# Copy virtual environment from builder stage
COPY --from=builder --chown=astrology:astrology /opt/venv /opt/venv

# Create application directory
RUN mkdir -p /app

# Set working directory
WORKDIR /app

# Copy application code with proper ownership
COPY --chown=astrology:astrology . .

# Create necessary directories with proper permissions
RUN mkdir -p /app/logs /app/cache && \
    chown -R astrology:astrology /app/logs /app/cache

# Switch to non-root user
USER astrology

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Default command
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1", "--timeout-keep-alive", "30"]

# Stage 3: Development stage
FROM runtime as development

# Switch back to root for development setup
USER root

# Install development dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    vim \
    htop \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install development Python packages
COPY requirements-dev.txt .
RUN pip install --no-cache-dir -r requirements-dev.txt

# Switch back to astrology user
USER astrology

# Override default command for development
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload", "--log-level", "info", "--timeout-keep-alive", "30"]

# Stage 4: Testing stage
FROM development as testing

# Copy test files
COPY --chown=astrology:astrology tests/ ./tests/

# Install test dependencies
RUN pip install --no-cache-dir pytest pytest-cov pytest-asyncio httpx

# Run tests
CMD ["pytest", "--cov=.", "--cov-report=term-missing", "--cov-report=xml"]