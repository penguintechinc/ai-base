# Docker Compose Guide - AI Base Layer

This guide helps you choose and use the right docker-compose file for your GPU setup.

## Quick Reference

| File | GPU Type | Use Case | Status |
|------|----------|----------|--------|
| `docker-compose.ai-base-vulkan.yml` | Universal (Intel/AMD/NVIDIA) | Production - Best compatibility | ✅ Working |
| `docker-compose.ai-base-nvidia.yml` | NVIDIA CUDA | Production - NVIDIA GPUs | ⚠️ Vulkan fallback |
| `docker-compose.ai-base-rocm.yml` | AMD ROCm | Production - AMD GPUs | ⚠️ Vulkan fallback |
| `docker-compose.ai-base-latest.yml` | Multi-backend | Production - Auto-detection | ⚠️ Vulkan fallback |
| `docker-compose.ai-base.yml` | All variants | Testing & comparison | ✅ Working |

## Production Usage

### Vulkan Variant (Recommended)

**Best for:** Universal GPU support, Intel/AMD integrated graphics, NVIDIA/AMD with Vulkan

```bash
# Start the base container
docker-compose -f docker-compose.ai-base-vulkan.yml up -d ai-base-vulkan

# Start Ollama server
docker-compose -f docker-compose.ai-base-vulkan.yml up -d ollama-vulkan

# Access Ollama API
curl http://localhost:11434/api/tags

# Interactive shell
docker exec -it ai-base-vulkan bash
```

### NVIDIA Variant

**Best for:** NVIDIA GPUs (currently uses Vulkan fallback)

**Requirements:**
- NVIDIA GPU
- NVIDIA Container Toolkit installed
- `nvidia-container-runtime` configured

```bash
# Start the base container
docker-compose -f docker-compose.ai-base-nvidia.yml up -d ai-base-nvidia

# Start Ollama server
docker-compose -f docker-compose.ai-base-nvidia.yml up -d ollama-nvidia

# Access Ollama API
curl http://localhost:11435/api/tags
```

### ROCm Variant

**Best for:** AMD GPUs (currently uses Vulkan fallback)

**Requirements:**
- AMD GPU with ROCm support
- ROCm drivers installed
- User in `video` and `render` groups

```bash
# Add user to required groups
sudo usermod -aG video,render $USER

# Start the base container
docker-compose -f docker-compose.ai-base-rocm.yml up -d ai-base-rocm

# Start Ollama server
docker-compose -f docker-compose.ai-base-rocm.yml up -d ollama-rocm

# Access Ollama API
curl http://localhost:11436/api/tags
```

### Latest Variant (Multi-Backend)

**Best for:** Systems with mixed GPUs or auto-detection needs

```bash
# Start the base container
docker-compose -f docker-compose.ai-base-latest.yml up -d ai-base-latest

# Start Ollama server
docker-compose -f docker-compose.ai-base-latest.yml up -d ollama-latest

# Access Ollama API
curl http://localhost:11437/api/tags
```

## Testing & Development

Use the comprehensive test suite:

```bash
# Test Vulkan variant
docker-compose -f docker-compose.ai-base.yml up test-vulkan-info
docker-compose -f docker-compose.ai-base.yml up test-vulkan-detect
docker-compose -f docker-compose.ai-base.yml up test-vulkan-validate

# Test NVIDIA variant
docker-compose -f docker-compose.ai-base.yml up test-nvidia-info

# Test ROCm variant
docker-compose -f docker-compose.ai-base.yml up test-rocm-info

# Run all Ollama servers simultaneously (different ports)
docker-compose -f docker-compose.ai-base.yml up vulkan-ollama nvidia-ollama rocm-ollama

# EXO distributed inference cluster
docker-compose -f docker-compose.ai-base.yml up exo-node-1 exo-node-2
```

## Port Assignments

| Service | Port | Variant |
|---------|------|---------|
| Ollama Vulkan | 11434 | Vulkan |
| Ollama NVIDIA | 11435 | NVIDIA |
| Ollama ROCm | 11436 | ROCm |
| Ollama Latest | 11437 | Latest |
| EXO Node 1 | 5678 | Distributed |
| EXO Node 2 | 5679 | Distributed |

## Volume Mounts

All variants mount the following directories:

- `./models/ollama` → `/models/ollama` (Ollama models)
- `./models/llama` → `/models/llama` (llama.cpp models)
- `./models/exo` → `/models/exo` (EXO models)
- `./workspace` → `/workspace` (Your workspace)

## Environment Variables

### Common Variables

```yaml
GPU_BACKEND: vulkan|cuda|rocm|auto
OLLAMA_MODELS: /models/ollama
LLAMA_MODELS: /models/llama
EXO_MODELS: /models/exo
LOG_LEVEL: info|debug|warning|error
```

### NVIDIA-Specific

```yaml
NVIDIA_VISIBLE_DEVICES: all|0,1,2
NVIDIA_DRIVER_CAPABILITIES: compute,utility
CUDA_VISIBLE_DEVICES: 0
```

### AMD ROCm-Specific

```yaml
HSA_OVERRIDE_GFX_VERSION: 10.3.0  # Adjust for your GPU
ROCR_VISIBLE_DEVICES: 0
HIP_VISIBLE_DEVICES: 0
```

## GPU Device Access

### Vulkan (All Systems)

```yaml
devices:
  - /dev/dri:/dev/dri
```

### NVIDIA

```yaml
runtime: nvidia
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
```

### AMD ROCm

```yaml
devices:
  - /dev/kfd:/dev/kfd
  - /dev/dri:/dev/dri
  - /dev/dri/renderD128:/dev/dri/renderD128
group_add:
  - video
  - render
ipc: host
security_opt:
  - seccomp:unconfined
```

## Customization

### Modify Resource Limits

Edit the `deploy.resources` section in your compose file:

```yaml
deploy:
  resources:
    limits:
      memory: 32G      # Maximum RAM
    reservations:
      memory: 16G      # Reserved RAM
```

### Add Custom Commands

Change the `command` field:

```yaml
# Interactive shell
command: tail -f /dev/null

# Run Ollama
command: ["/opt/ai-base/bin/ollama", "serve"]

# Run llama.cpp
command: ["/opt/ai-base/bin/llama-cli", "--help"]

# Custom script
command: ["/bin/bash", "-c", "detect-gpu && gpu-info"]
```

### Network Configuration

All services use the `ai-base-network` bridge network. Modify as needed:

```yaml
networks:
  ai-base-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16
```

## Troubleshooting

### GPU Not Detected

```bash
# Check GPU access
docker run --rm --device=/dev/dri ai-base:vulkan vulkaninfo --summary

# NVIDIA
docker run --rm --runtime=nvidia ai-base:nvidia nvidia-smi

# AMD ROCm
docker run --rm --device=/dev/kfd --device=/dev/dri ai-base:rocm rocm-smi
```

### Permission Issues (AMD)

```bash
# Add user to groups
sudo usermod -aG video,render $USER
newgrp video

# Check device permissions
ls -l /dev/dri /dev/kfd
```

### Port Conflicts

Change the port mapping in your compose file:

```yaml
ports:
  - "12434:11434"  # Map external port 12434 to container 11434
```

### Container Logs

```bash
# View logs
docker-compose -f docker-compose.ai-base-vulkan.yml logs -f

# Specific service
docker-compose -f docker-compose.ai-base-vulkan.yml logs ollama-vulkan
```

## Examples

### Download and Run a Model

```bash
# Start Ollama
docker-compose -f docker-compose.ai-base-vulkan.yml up -d ollama-vulkan

# Pull a model
docker exec ai-base-vulkan /opt/ai-base/bin/ollama pull llama2

# Run inference
curl http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Why is the sky blue?"
}'
```

### Use llama.cpp Directly

```bash
# Start container
docker-compose -f docker-compose.ai-base-vulkan.yml up -d ai-base-vulkan

# Download a model
docker exec ai-base-vulkan bash -c "cd /models/llama && \
  wget https://huggingface.co/TheBloke/Llama-2-7B-GGUF/resolve/main/llama-2-7b.Q4_K_M.gguf"

# Run inference
docker exec ai-base-vulkan /opt/ai-base/bin/llama-cli \
  -m /models/llama/llama-2-7b.Q4_K_M.gguf \
  -p "Why is the sky blue?" \
  -n 128
```

### Distributed Inference with EXO

```bash
# Start 2-node cluster
docker-compose -f docker-compose.ai-base.yml up -d exo-node-1 exo-node-2

# Check cluster status
docker logs ai-base-exo-node-1
docker logs ai-base-exo-node-2
```

## Support

For issues or questions:
- Check the main README: [apps/ai-inference/README.md](apps/ai-inference/README.md)
- Review logs: `docker-compose logs`
- Verify GPU access with detection scripts
- Ensure you have the required GPU drivers and runtimes installed
