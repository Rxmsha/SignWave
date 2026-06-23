# SignWave Django + ML backend — built for Hugging Face Spaces (Docker SDK).
# The frontend deploys separately to Vercel and talks to this over HTTP.
FROM python:3.12-slim

# System libraries required by opencv-python and mediapipe.
RUN apt-get update && apt-get install -y --no-install-recommends \
        libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Hugging Face Spaces runs the container as a non-root user with UID 1000.
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    HF_HOME=/home/user/.cache/huggingface

WORKDIR /app

# Install CPU-only PyTorch first — much smaller than the default CUDA build.
RUN pip install --no-cache-dir --user \
        torch==2.12.1 torchvision==0.27.1 \
        --index-url https://download.pytorch.org/whl/cpu

# Install the remaining Python dependencies (pins keep mediapipe's legacy
# solutions API compatible with TensorFlow — see backend/requirements.txt).
COPY --chown=user backend/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir --user -r /app/requirements.txt

# Copy the backend source (includes the 849 MB reference_signs landmark data).
COPY --chown=user backend/ /app/

# Backend runtime config. CORS_ALLOW_ALL lets any frontend origin call the API
# (accounts are disabled in this build, so no cross-site cookies are involved).
ENV DEBUG=False \
    ALLOWED_HOSTS=* \
    CORS_ALLOW_ALL=True

# Hugging Face Spaces routes external traffic to port 7860.
EXPOSE 7860

# --preload loads the WSGI app (and the ML models) in the master process before
# forking, so the heavy model load happens once and avoids worker-boot timeouts.
CMD python manage.py migrate --noinput && \
    gunicorn backend.wsgi:application \
        --bind 0.0.0.0:7860 \
        --workers 1 \
        --timeout 300 \
        --preload
