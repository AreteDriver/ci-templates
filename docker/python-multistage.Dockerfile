# Multi-stage Python Dockerfile
# Used in: BenchGoblins, EVE_Gatekeeper, RedOPS
#
# Pattern: builder installs deps into venv, runtime copies only what's needed
# Result: ~150MB image vs ~800MB with naive approach

# --- Builder ---
FROM python:3.12-slim AS builder

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY pyproject.toml .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir .

COPY src/ src/
COPY scripts/ scripts/
COPY data/migrations/ data/migrations/

# --- Runtime ---
FROM python:3.12-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends libpq5 curl && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /sbin/nologin appuser

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app /app

WORKDIR /app
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1

USER appuser

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8000}/health || exit 1

EXPOSE ${PORT:-8000}

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
