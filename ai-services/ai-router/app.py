"""
AI Router Service - Multi-Provider LLM Gateway
Routes requests to Ollama (Mistral), Google Gemini, and other AI providers
"""

from flask import Flask, request, jsonify
import os
import time
import requests
from datetime import datetime

app = Flask(__name__)

# Configuration
PORT = int(os.getenv('PORT', 8080))
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY', 'sk-dummy-key')
ANTHROPIC_API_KEY = os.getenv('ANTHROPIC_API_KEY', 'dummy-key')
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY', '')
OLLAMA_BASE_URL = os.getenv('OLLAMA_BASE_URL', 'http://localhost:11434')

# Provider endpoints
PROVIDER_ENDPOINTS = {
    'ollama': f"{OLLAMA_BASE_URL}/api/generate",
    'ollama_chat': f"{OLLAMA_BASE_URL}/api/chat",
    'gemini': 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent'
}

# Provider configurations
PROVIDER_MODELS = {
    "ollama": {
        "default_model": "mistral",
        "available_models": ["mistral", "llama2", "codellama", "phi"],
        "type": "local"
    },
    "gemini": {
        "default_model": "gemini-2.0-flash",
        "available_models": ["gemini-2.5-flash", "gemini-2.5-pro", "gemini-2.0-flash"],
        "type": "cloud"
    },
    "openai": {
        "default_model": "gpt-4",
        "available_models": ["gpt-4", "gpt-3.5-turbo"],
        "type": "cloud"
    },
    "anthropic": {
        "default_model": "claude-3-opus",
        "available_models": ["claude-3-opus", "claude-3-sonnet"],
        "type": "cloud"
    }
}

def call_ollama(message, model="mistral", stream=False):
    """Call Ollama API (local Mistral model)"""
    try:
        payload = {
            "model": model,
            "prompt": message,
            "stream": stream
        }

        response = requests.post(
            PROVIDER_ENDPOINTS['ollama'],
            json=payload,
            timeout=30
        )

        if response.status_code == 200:
            data = response.json()
            return {
                "success": True,
                "content": data.get("response", ""),
                "model": model,
                "provider": "ollama",
                "tokens": {
                    "prompt": data.get("prompt_eval_count", 0),
                    "completion": data.get("eval_count", 0),
                    "total": data.get("prompt_eval_count", 0) + data.get("eval_count", 0)
                },
                "metadata": {
                    "total_duration": data.get("total_duration", 0),
                    "load_duration": data.get("load_duration", 0),
                    "eval_duration": data.get("eval_duration", 0)
                }
            }
        else:
            return {
                "success": False,
                "error": f"Ollama error: {response.status_code}",
                "details": response.text
            }
    except requests.exceptions.ConnectionError:
        return {
            "success": False,
            "error": "Ollama not running. Start with: ollama run mistral",
            "fallback": "mock"
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Ollama error: {str(e)}",
            "fallback": "mock"
        }

def call_gemini(message, model="gemini-2.0-flash"):
    """Call Google Gemini API"""
    if not GEMINI_API_KEY:
        return {
            "success": False,
            "error": "GEMINI_API_KEY not configured",
            "fallback": "mock"
        }

    try:
        # Use v1 API
        url = f"https://generativelanguage.googleapis.com/v1/models/{model}:generateContent?key={GEMINI_API_KEY}"

        payload = {
            "contents": [{
                "parts": [{
                    "text": message
                }]
            }]
        }

        response = requests.post(url, json=payload, timeout=30)

        if response.status_code == 200:
            data = response.json()

            # Extract response text
            content = ""
            if "candidates" in data and len(data["candidates"]) > 0:
                candidate = data["candidates"][0]
                if "content" in candidate and "parts" in candidate["content"]:
                    parts = candidate["content"]["parts"]
                    content = " ".join([part.get("text", "") for part in parts])

            # Extract token counts
            usage_metadata = data.get("usageMetadata", {})

            return {
                "success": True,
                "content": content,
                "model": model,
                "provider": "gemini",
                "tokens": {
                    "prompt": usage_metadata.get("promptTokenCount", 0),
                    "completion": usage_metadata.get("candidatesTokenCount", 0),
                    "total": usage_metadata.get("totalTokenCount", 0)
                },
                "metadata": {
                    "finish_reason": data.get("candidates", [{}])[0].get("finishReason", "STOP"),
                    "safety_ratings": data.get("candidates", [{}])[0].get("safetyRatings", [])
                }
            }
        else:
            return {
                "success": False,
                "error": f"Gemini error: {response.status_code}",
                "details": response.text
            }
    except Exception as e:
        return {
            "success": False,
            "error": f"Gemini error: {str(e)}",
            "fallback": "mock"
        }

def get_mock_response(provider, model, message):
    """Generate mock response when provider is unavailable"""
    mock_messages = {
        "ollama": f"[MOCK] Mistral response: This would be a real response from locally-run Mistral model. To enable: 1) Install Ollama 2) Run 'ollama pull mistral' 3) Start service.",
        "gemini": f"[MOCK] Gemini response: This would be a real response from Google Gemini. To enable: Set GEMINI_API_KEY environment variable.",
        "openai": "[MOCK] OpenAI GPT-4 response: This would connect to OpenAI API in production.",
        "anthropic": "[MOCK] Anthropic Claude response: This would connect to Anthropic API in production."
    }

    return {
        "success": True,
        "content": mock_messages.get(provider, f"[MOCK] {provider} response"),
        "model": model,
        "provider": provider,
        "mode": "mock",
        "tokens": {
            "prompt": len(message.split()),
            "completion": 50,
            "total": len(message.split()) + 50
        }
    }

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "service": "ai-router",
        "timestamp": datetime.utcnow().isoformat()
    })

@app.route('/chat', methods=['POST'])
def chat():
    """
    Unified chat endpoint - routes to Ollama, Gemini, or other providers

    Request body:
    {
        "message": "Your question here",
        "provider": "ollama" | "gemini" | "openai" | "anthropic",
        "model": "mistral" | "gemini-pro" | etc (optional)
    }
    """
    data = request.get_json()

    if not data or 'message' not in data:
        return jsonify({
            "error": "Missing 'message' in request body",
            "example": {
                "message": "What is AI?",
                "provider": "ollama",
                "model": "mistral"
            }
        }), 400

    message = data.get('message')
    provider = data.get('provider', 'ollama').lower()
    model = data.get('model')

    # Set default model for provider if not specified
    if not model and provider in PROVIDER_MODELS:
        model = PROVIDER_MODELS[provider]["default_model"]

    start_time = time.time()

    # Route to appropriate provider
    if provider == 'ollama':
        result = call_ollama(message, model)
    elif provider == 'gemini':
        result = call_gemini(message, model)
    else:
        # Mock response for unsupported providers
        result = get_mock_response(provider, model, message)

    # Calculate latency
    latency_ms = int((time.time() - start_time) * 1000)

    # If provider failed, fall back to mock
    if not result.get("success") and result.get("fallback") == "mock":
        result = get_mock_response(provider, model, message)
        result["fallback_used"] = True

    # Build final response
    response = {
        "success": result.get("success", True),
        "request": {
            "message": message,
            "model": model,
            "provider": provider
        },
        "response": {
            "content": result.get("content", ""),
            "model": result.get("model", model),
            "provider": result.get("provider", provider),
            "tokens": result.get("tokens", {}),
            "mode": result.get("mode", "live")
        },
        "metadata": {
            "timestamp": datetime.utcnow().isoformat(),
            "latency_ms": latency_ms,
            "request_id": f"req_{int(time.time()*1000)}",
            **result.get("metadata", {})
        }
    }

    # Add error info if present
    if "error" in result:
        response["error"] = result["error"]
        if "details" in result:
            response["error_details"] = result["details"]

    if "fallback_used" in result:
        response["fallback_used"] = True

    return jsonify(response)

@app.route('/completions', methods=['POST'])
def completions():
    """OpenAI-compatible completions endpoint"""
    data = request.get_json()

    prompt = data.get('prompt', '')
    model = data.get('model', 'gpt-4')
    max_tokens = data.get('max_tokens', 1024)

    return jsonify({
        "id": f"cmpl-{int(time.time()*1000)}",
        "object": "text_completion",
        "created": int(time.time()),
        "model": model,
        "choices": [{
            "text": f"Mock completion for: {prompt[:50]}...",
            "index": 0,
            "finish_reason": "stop"
        }],
        "usage": {
            "prompt_tokens": len(prompt.split()),
            "completion_tokens": 50,
            "total_tokens": len(prompt.split()) + 50
        }
    })

@app.route('/models', methods=['GET'])
def models():
    """List available models across all providers"""
    models_list = []

    for provider, config in PROVIDER_MODELS.items():
        for model in config["available_models"]:
            models_list.append({
                "id": model,
                "provider": provider,
                "type": config["type"],
                "default": model == config["default_model"]
            })

    # Check provider availability
    status = {
        "ollama": check_ollama_status(),
        "gemini": bool(GEMINI_API_KEY)
    }

    return jsonify({
        "success": True,
        "models": models_list,
        "provider_status": status,
        "recommended": {
            "local": "ollama/mistral",
            "cloud": "gemini/gemini-pro"
        }
    })

def check_ollama_status():
    """Check if Ollama is running"""
    try:
        response = requests.get(f"{OLLAMA_BASE_URL}/api/tags", timeout=2)
        return response.status_code == 200
    except:
        return False

@app.route('/stats', methods=['GET'])
def stats():
    """Service statistics"""
    return jsonify({
        "success": True,
        "statistics": {
            "total_requests": 0,
            "total_tokens": 0,
            "active_providers": ["openai", "anthropic", "bedrock"],
            "uptime_seconds": time.time(),
            "timestamp": datetime.utcnow().isoformat()
        }
    })

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        "error": "Endpoint not found",
        "available_endpoints": [
            "/health",
            "/chat",
            "/completions",
            "/models",
            "/stats"
        ]
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        "error": "Internal server error",
        "message": str(error)
    }), 500

if __name__ == '__main__':
    print(f"🤖 AI Router Service starting on port {PORT}")
    print(f"📡 Providers:")
    print(f"   • Ollama (Mistral) - Local: {OLLAMA_BASE_URL}")
    print(f"   • Google Gemini - Cloud: {'✅ Configured' if GEMINI_API_KEY else '❌ Not configured'}")
    print(f"   • OpenAI, Anthropic - Mock mode")
    print(f"\n🚀 Ready to route AI requests!")
    app.run(host='0.0.0.0', port=PORT, debug=False)
