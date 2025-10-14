# AI Base Layer - Multi-Backend Inference Foundation

```
    _    ___   ____
   / \  |_ _| | __ )  __ _ ___  ___
  / _ \  | |  |  _ \ / _` / __|/ _ \
 / ___ \ | |  | |_) | (_| \__ \  __/
/_/   \_\___| |____/ \__,_|___/\___|

Multi-Backend AI Inference Base Layer
```

Production-ready Docker base images for AI inference applications with support for NVIDIA CUDA, AMD ROCm, and universal Vulkan GPU acceleration.

## Overview

The AI Base Layer provides optimized foundation images for building AI inference applications. Each variant is specifically tailored for different GPU hardware while maintaining a consistent interface and tooling.

### Key Features

- **4 Optimized Variants** - Vulkan (universal), NVIDIA (CUDA), AMD (ROCm), Latest (multi-backend)
- **4 Inference Engines** - Ollama, llama.cpp, llm-d, EXO (distributed inference)
- **Size Optimized** - Minimal footprint per variant (3-15GB depending on variant)
- **Multi-Architecture** - Built for amd64 and arm64
- **Production Ready** - Health checks, GPU detection, validation scripts
- **Open Source** - Limited AGPL3 with fair use preamble

## Variants

| Tag | GPU Support | Default Backend | Size | Best For |
|-----|-------------|-----------------|------|----------|
| `vulkan` | Universal (NVIDIA/AMD/Intel) | Vulkan | ~3-4GB | Maximum compatibility |
| `nvidia` | NVIDIA only | CUDA | ~5-6GB | NVIDIA performance |
| `rocm` | AMD only | ROCm | ~8-9GB | AMD performance |
| `latest` | All (auto-detect) | Vulkan | ~12-15GB | Flexibility, multi-GPU |

### Inference Engines (All Variants)

- **Ollama** - Easy model management with built-in library
- **llama.cpp** - Highly optimized C++ inference engine
- **llm-d** - D language implementation for research
- **EXO** - Distributed inference across multiple nodes

## Quick Start

### Using as a Base Image

```dockerfile
# Dockerfile
FROM ghcr.io/penguincloud/ai-base:vulkan

WORKDIR /app
COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY . .

CMD ["python3", "app.py"]
```

### Testing the Image

```bash
# Pull and test vulkan variant
docker pull ghcr.io/penguincloud/ai-base:vulkan
docker run --rm ghcr.io/penguincloud/ai-base:vulkan gpu-info

# Test with GPU access
docker run --rm --device=/dev/dri \
  ghcr.io/penguincloud/ai-base:vulkan \
  validate-gpu
```

### Building Locally

```bash
# Build specific variant
make ai-base-build-vulkan
make ai-base-build-nvidia
make ai-base-build-rocm
make ai-base-build-latest

# Build all variants
make ai-base-build-all

# Test all variants
make ai-base-test-all
```

## Usage Guide

### Selecting the Right Variant

#### Use `vulkan` when:
- You need maximum compatibility across different GPUs
- Deploying to mixed environments (NVIDIA/AMD/Intel)
- Container size is a concern
- You don't know the target GPU in advance

#### Use `nvidia` when:
- You're certain the target hardware is NVIDIA
- You want maximum CUDA performance
- You need NVIDIA-specific optimizations

#### Use `rocm` when:
- You're certain the target hardware is AMD
- You want maximum ROCm performance
- You need AMD-specific optimizations

#### Use `latest` when:
- Deploying to environments with varying GPU types
- You want automatic backend selection
- You need all backends available simultaneously

### Environment Variables

```bash
# GPU Backend Selection (latest variant only)
GPU_BACKEND=vulkan|cuda|rocm|auto  # Default: vulkan

# Model Paths
OLLAMA_MODELS=/models/ollama
LLAMA_MODELS=/models/llama
EXO_MODELS=/models/exo

# Logging
LOG_LEVEL=info|debug|warning

# Ollama Configuration
OLLAMA_HOST=0.0.0.0:11434
OLLAMA_NUM_PARALLEL=1
OLLAMA_MAX_LOADED_MODELS=1
```

### Utility Commands

The following commands are available in all variants:

```bash
# GPU detection and information
detect-gpu      # Detect available GPU hardware
gpu-info        # Show comprehensive system information
validate-gpu    # Validate GPU setup and backends
select-backend  # Manually select and configure backend
```

## Example Applications

### Simple Ollama Application

```dockerfile
FROM ghcr.io/penguincloud/ai-base:vulkan

WORKDIR /app

# Copy your application
COPY app.py .

# Install Python dependencies
RUN pip3 install --no-cache-dir flask requests

# Expose port
EXPOSE 5000

# Run application
CMD ["python3", "app.py"]
```

```python
# app.py
import subprocess
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/generate', methods=['POST'])
def generate():
    data = request.json
    prompt = data.get('prompt', '')

    # Use Ollama for inference
    result = subprocess.run(
        ['ollama', 'run', 'llama2', prompt],
        capture_output=True,
        text=True
    )

    return jsonify({'response': result.stdout})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### Multi-GPU Application with Backend Selection

```dockerfile
FROM ghcr.io/penguincloud/ai-base:latest

WORKDIR /app
COPY app.py requirements.txt ./
RUN pip3 install -r requirements.txt

ENV GPU_BACKEND=auto

CMD ["python3", "app.py"]
```

```python
# app.py - Auto-selects best backend
import os
import subprocess

def get_gpu_backend():
    """Get the selected GPU backend"""
    backend = os.getenv('GPU_BACKEND', 'vulkan')
    if backend == 'auto':
        # Run backend selector
        result = subprocess.run(
            ['/usr/local/bin/select-backend'],
            capture_output=True,
            text=True
        )
        return os.getenv('GPU_BACKEND', 'vulkan')
    return backend

# Your application logic here
backend = get_gpu_backend()
print(f"Using GPU backend: {backend}")
```

### Distributed Inference with EXO

```yaml
# docker-compose.yml
version: '3.8'

services:
  exo-node-1:
    image: ghcr.io/penguincloud/ai-base:vulkan
    environment:
      - INFERENCE_ENGINE=exo
      - EXO_MODE=distributed
      - EXO_NODE_ID=node1
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu]

  exo-node-2:
    image: ghcr.io/penguincloud/ai-base:vulkan
    environment:
      - INFERENCE_ENGINE=exo
      - EXO_MODE=distributed
      - EXO_NODE_ID=node2
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu]
```

## Advanced Configuration

### Custom Model Loading

```dockerfile
FROM ghcr.io/penguincloud/ai-base:vulkan

# Pre-download models during build
RUN ollama pull llama2
RUN ollama pull mistral

# Or copy pre-downloaded models
COPY models/ /models/ollama/

WORKDIR /app
COPY . .

CMD ["python3", "app.py"]
```

### Performance Tuning

```bash
# Environment variables for performance
OMP_NUM_THREADS=8              # OpenMP threads
OPENBLAS_NUM_THREADS=8         # OpenBLAS threads
OLLAMA_NUM_PARALLEL=2          # Parallel requests
OLLAMA_MAX_LOADED_MODELS=3     # Concurrent models

# NVIDIA-specific
CUDA_VISIBLE_DEVICES=0,1       # Multi-GPU
CUDA_LAUNCH_BLOCKING=0         # Async kernels

# AMD-specific
HIP_VISIBLE_DEVICES=0,1        # Multi-GPU
HSA_ENABLE_SDMA=0              # Disable SDMA
```

## Installed Paths

All variants include the following binaries:

```
/opt/ai-base/bin/
  ├── ollama              # Ollama CLI
  ├── llama-cli           # llama.cpp CLI
  ├── llama-server        # llama.cpp server
  ├── llama-quantize      # Model quantization
  ├── llama-*             # Additional llama.cpp tools
  └── llm-d               # llm-d binary (if built)

/usr/local/bin/
  ├── detect-gpu          # GPU detection script
  ├── select-backend      # Backend selection
  ├── validate-gpu        # Validation script
  └── gpu-info            # Information display

/models/
  ├── ollama/             # Ollama models
  ├── llama/              # llama.cpp models
  └── exo/                # EXO models
```

## GPU Hardware Requirements

### Vulkan Variant
- **Any GPU** with Vulkan 1.3+ support
- NVIDIA, AMD, or Intel GPUs
- Minimum 4GB VRAM recommended

### NVIDIA Variant
- **NVIDIA GPU** with CUDA Compute Capability 6.0+
- CUDA Toolkit 12.x included
- Minimum 6GB VRAM recommended
- Driver version 525.60.13 or newer

### ROCm Variant
- **AMD GPU** with ROCm 6.0+ support
- ROCm toolkit included
- Minimum 8GB VRAM recommended
- Supported GPUs: RX 6000 series, MI100/200/300

### Latest Variant
- Any of the above GPUs
- Automatically detects and uses best backend
- Minimum 8GB VRAM recommended for multi-backend

## Troubleshooting

### GPU Not Detected

```bash
# Run detection
docker run --rm --device=/dev/dri \
  ghcr.io/penguincloud/ai-base:vulkan \
  detect-gpu

# Check permissions
ls -la /dev/dri/
groups $(whoami)
```

### Validation Failures

```bash
# Run full validation
docker run --rm --device=/dev/dri \
  ghcr.io/penguincloud/ai-base:vulkan \
  validate-gpu

# Check GPU access
docker run --rm --device=/dev/dri \
  ghcr.io/penguincloud/ai-base:vulkan \
  vulkaninfo --summary
```

### Wrong Backend Selected

```bash
# Force specific backend (latest variant only)
docker run --rm -e GPU_BACKEND=cuda \
  --gpus all \
  ghcr.io/penguincloud/ai-base:latest \
  gpu-info
```

### Model Loading Issues

```bash
# Check model paths
docker run --rm -v $(pwd)/models:/models \
  ghcr.io/penguincloud/ai-base:vulkan \
  sh -c "ls -la /models/ollama/"

# Verify Ollama configuration
docker run --rm ghcr.io/penguincloud/ai-base:vulkan \
  env | grep OLLAMA
```

## Performance Benchmarks

Approximate inference speeds for Llama-2-7B (tokens/sec):

| Variant | Hardware | Speed | Notes |
|---------|----------|-------|-------|
| vulkan | RTX 4090 | 45-50 | Universal compatibility |
| nvidia | RTX 4090 | 80-90 | CUDA optimized |
| vulkan | RX 7900 XTX | 40-45 | Universal compatibility |
| rocm | RX 7900 XTX | 70-75 | ROCm optimized |
| vulkan | Intel Arc A770 | 25-30 | Universal compatibility |

*Benchmarks measured with default settings, single model inference*

## Building from Source

```bash
# Clone repository
git clone https://github.com/penguincloud/ai-base.git
cd ai-base

# Build specific variant
cd apps/ai-inference
docker build --build-arg GPU_VARIANT=vulkan -t ai-base:vulkan .

# Or use Makefile
cd ../..
make ai-base-build-all
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the Limited AGPL3 with preamble for fair use - see [LICENSE.md](../../LICENSE.md) for details.

## Support

- **Documentation**: [Complete docs](../../docs/)
- **Issues**: [GitHub Issues](https://github.com/penguincloud/ai-base/issues)
- **Community**: https://community.penguintech.io

## Acknowledgments

Built with:
- [Ollama](https://ollama.ai/) - Easy LLM deployment
- [llama.cpp](https://github.com/ggerganov/llama.cpp) - Efficient inference
- [llm-d](https://github.com/symmetryinvestments/llm-d) - D language implementation
- [EXO](https://github.com/exo-explore/exo) - Distributed inference

---

**Maintained by**: Penguin Tech Inc
**Homepage**: https://www.penguintech.io
