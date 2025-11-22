# Use a slim Python base image
FROM python:3.10-slim

# --- 1. Environment Setup ---
# Set environment variables to tell Hugging Face where to store/look for cached models.
# This is essential for "baking in" the model.
ENV HF_HOME="/app/hf_cache"
ENV TRANSFORMERS_CACHE="$HF_HOME/hub"
ENV TORCH_HOME="$HF_HOME/torch"

# Don't write pyc files and unbuffer stdout for easier container logging
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# --- 2. Install Dependencies ---
# Install system utilities if needed (e.g., git)
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- 3. "Bake in" the Model ---
# This is the most important step for HF images.
# We run a Python one-liner that triggers the download of the model specified in app.py.
# Because HF_HOME is set above, it will save the model files into the image layer.
RUN python3 -c "from transformers import pipeline; pipeline('sentiment-analysis', model='distilbert-base-uncased-finetuned-sst-2-english')"

# --- 4. Finalize ---
# Copy the actual application code
COPY app.py .

# Create a non-root user for security (optional but recommended for production)
RUN useradd -m -u 1000 user
RUN chown -R user:user /app
USER user

# Expose Gradio port
EXPOSE 7860

CMD ["python", "app.py"]
