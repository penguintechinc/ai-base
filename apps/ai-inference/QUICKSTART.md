# AI Base Layer - Quick Start Guide

## Build Commands

```bash
# Build single variant
make ai-base-build-vulkan   # Universal GPU support
make ai-base-build-nvidia   # NVIDIA CUDA optimized
make ai-base-build-rocm     # AMD ROCm optimized
make ai-base-build-latest   # All backends (auto-detect)

# Build all variants at once
make ai-base-build-all

# Clean images
make ai-base-clean
```

## Test Commands

```bash
# Test single variant
make ai-base-test-vulkan
make ai-base-test-nvidia
make ai-base-test-rocm
make ai-base-test-latest

# Test all variants
make ai-base-test-all

# Get variant information
make ai-base-info
```

## Docker Compose Testing

```bash
# Test Vulkan variant
docker-compose -f docker-compose.ai-base.yml up test-vulkan-info
docker-compose -f docker-compose.ai-base.yml up test-vulkan-detect
docker-compose -f docker-compose.ai-base.yml up test-vulkan-validate

# Run Ollama on Vulkan
docker-compose -f docker-compose.ai-base.yml up vulkan-ollama

# Test NVIDIA variant (requires NVIDIA GPU)
docker-compose -f docker-compose.ai-base.yml up test-nvidia-info

# Test EXO distributed inference
docker-compose -f docker-compose.ai-base.yml up exo-node-1 exo-node-2
```

## Usage Examples

### Basic Dockerfile

```dockerfile
FROM ai-base:vulkan

WORKDIR /app
COPY . .

CMD ["python3", "app.py"]
```

### With Ollama

```dockerfile
FROM ai-base:vulkan

WORKDIR /app
COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY . .

# Expose Ollama port
EXPOSE 11434

CMD ["python3", "inference_server.py"]
```

### Multi-GPU with Auto-Detection

```dockerfile
FROM ai-base:latest

ENV GPU_BACKEND=auto

WORKDIR /app
COPY . .

CMD ["python3", "app.py"]
```

## Quick GPU Tests

```bash
# Test GPU detection
docker run --rm --device=/dev/dri ai-base:vulkan detect-gpu

# Show GPU info
docker run --rm --device=/dev/dri ai-base:vulkan gpu-info

# Validate GPU setup
docker run --rm --device=/dev/dri ai-base:vulkan validate-gpu

# Test with NVIDIA GPU
docker run --rm --gpus all ai-base:nvidia detect-gpu

# Test with AMD GPU
docker run --rm --device=/dev/kfd --device=/dev/dri ai-base:rocm detect-gpu
```

## Environment Variables

```bash
# Select GPU backend (latest variant only)
GPU_BACKEND=vulkan|cuda|rocm|auto

# Model paths
OLLAMA_MODELS=/models/ollama
LLAMA_MODELS=/models/llama
EXO_MODELS=/models/exo

# Ollama configuration
OLLAMA_HOST=0.0.0.0:11434
OLLAMA_NUM_PARALLEL=1

# Logging
LOG_LEVEL=info|debug|warning
```

## Variant Selection Guide

**Choose `vulkan` if:**
- You need universal GPU compatibility
- You're deploying to mixed GPU environments
- Container size matters
- You don't know target GPU hardware in advance

**Choose `nvidia` if:**
- You're certain the hardware is NVIDIA
- You want maximum CUDA performance
- You need NVIDIA-specific features

**Choose `rocm` if:**
- You're certain the hardware is AMD
- You want maximum ROCm performance
- You need AMD-specific features

**Choose `latest` if:**
- You have varying GPU hardware
- You want automatic backend detection
- You need all backends available

## Troubleshooting

```bash
# Check if Docker can see GPU
docker run --rm --device=/dev/dri ubuntu:22.04 ls -la /dev/dri

# Check NVIDIA GPU access
docker run --rm --gpus all nvidia/cuda:12.3.1-base-ubuntu22.04 nvidia-smi

# Check AMD GPU access
docker run --rm --device=/dev/kfd --device=/dev/dri ubuntu:22.04 ls -la /dev/kfd

# View container logs
docker logs ai-base-test-vulkan-info

# Run interactive shell
docker run --rm -it --device=/dev/dri ai-base:vulkan bash
```

## Size Targets

| Variant | Target Size | Actual Use Case |
|---------|-------------|-----------------|
| vulkan  | ~3-4GB     | Universal deployment |
| nvidia  | ~5-6GB     | NVIDIA clusters |
| rocm    | ~8-9GB     | AMD clusters |
| latest  | ~12-15GB   | Mixed environments |

## Next Steps

1. **Build your first variant**: `make ai-base-build-vulkan`
2. **Test it**: `make ai-base-test-vulkan`
3. **Read full docs**: `apps/ai-inference/README.md`
4. **Create your app**: Use as base in your Dockerfile
5. **Deploy**: Push to registry and deploy

## Support

- **Full Documentation**: apps/ai-inference/README.md
- **Issues**: https://github.com/penguincloud/ai-base/issues
- **Company**: https://www.penguintech.io
