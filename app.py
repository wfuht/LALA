# app.py
import gradio as gr
from transformers import pipeline

# Use a specific, small model for demonstration
MODEL_NAME = "distilbert-base-uncased-finetuned-sst-2-english"

# Initialize the pipeline. Because we baked the model in the Dockerfile,
# this will load instantly from local disk.
sentiment_pipeline = pipeline("sentiment-analysis", model=MODEL_NAME)

def analyze_sentiment(text):
    result = sentiment_pipeline(text)[0]
    return f"Label: {result['label']}, Score: {round(result['score'], 4)}"

# Create Gradio interface
demo = gr.Interface(
    fn=analyze_sentiment,
    inputs=gr.Textbox(lines=3, placeholder="Enter text here..."),
    outputs="text",
    title="Hugging Face Sentiment Analysis Docker",
    description=f"Serving model: {MODEL_NAME}"
)

if __name__ == "__main__":
    # Gradio listens on port 7860 by default
    demo.launch(server_name="0.0.0.0", server_port=7860)
