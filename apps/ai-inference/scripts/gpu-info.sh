#!/bin/bash
# GPU Information Display Script
# Shows comprehensive GPU and inference engine information

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear

echo -e "${BLUE}"
cat << "EOF"
    _    ___   ____
   / \  |_ _| | __ )  __ _ ___  ___
  / _ \  | |  |  _ \ / _` / __|/ _ \
 / ___ \ | |  | |_) | (_| \__ \  __/
/_/   \_\___| |____/ \__,_|___/\___|

Multi-Backend AI Inference Base Layer
EOF
echo -e "${NC}"

echo "================================================"
echo "  Container Information"
echo "================================================"
echo "Variant: ${GPU_VARIANT:-unknown}"
echo "Default Backend: ${GPU_BACKEND:-vulkan}"
echo "Image Version: $(cat /etc/os-release | grep VERSION= | cut -d'"' -f2)"
echo ""

echo "================================================"
echo "  Available Inference Engines"
echo "================================================"

# Check each engine
if command -v ollama &> /dev/null; then
    OLLAMA_VERSION=$(ollama --version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓${NC} Ollama ($OLLAMA_VERSION)"
    echo "  Path: $(which ollama)"
else
    echo "✗ Ollama: not installed"
fi

if [ -f /opt/ai-base/bin/llama-cli ] || command -v llama-cli &> /dev/null; then
    echo -e "${GREEN}✓${NC} llama.cpp"
    echo "  Path: /opt/ai-base/bin/"
    ls -1 /opt/ai-base/bin/llama-* 2>/dev/null | head -3 | sed 's/^/    /'
else
    echo "✗ llama.cpp: not installed"
fi

if [ -f /opt/ai-base/bin/llm-d ] || command -v llm-d &> /dev/null; then
    echo -e "${GREEN}✓${NC} llm-d"
    echo "  Path: $(which llm-d 2>/dev/null || echo '/opt/ai-base/bin/llm-d')"
else
    echo "✗ llm-d: not installed"
fi

if python3 -c "import exo" 2>/dev/null; then
    EXO_VERSION=$(python3 -c "import exo; print(exo.__version__)" 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓${NC} EXO ($EXO_VERSION)"
    echo "  Python package installed"
else
    echo "✗ EXO: not installed"
fi

echo ""
echo "================================================"
echo "  GPU Hardware Detection"
echo "================================================"

# NVIDIA
if command -v nvidia-smi &> /dev/null; then
    echo -e "${GREEN}NVIDIA GPU:${NC}"
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>/dev/null | sed 's/^/  /'
    echo ""
else
    echo "NVIDIA: not detected"
fi

# AMD
if command -v rocm-smi &> /dev/null; then
    echo -e "${GREEN}AMD GPU:${NC}"
    rocm-smi --showproductname 2>/dev/null | sed 's/^/  /'
    echo ""
elif lspci 2>/dev/null | grep -i 'amd.*vga\|amd.*display' > /dev/null; then
    echo -e "${YELLOW}AMD GPU: detected but ROCm not available${NC}"
    lspci | grep -i 'amd.*vga\|amd.*display' | sed 's/^/  /'
    echo ""
fi

# Intel
if lspci 2>/dev/null | grep -i 'intel.*vga\|intel.*display' > /dev/null; then
    echo -e "${GREEN}Intel GPU:${NC}"
    lspci | grep -i 'intel.*vga\|intel.*display' | sed 's/^/  /'
    echo ""
fi

# Vulkan
if command -v vulkaninfo &> /dev/null; then
    VULKAN_DEVICES=$(vulkaninfo --summary 2>/dev/null | grep -c "GPU" || echo "0")
    if [ "$VULKAN_DEVICES" -gt 0 ]; then
        echo -e "${GREEN}Vulkan Devices: $VULKAN_DEVICES${NC}"
        vulkaninfo --summary 2>/dev/null | grep "deviceName" | sed 's/^/  /' || true
        echo ""
    fi
fi

echo "================================================"
echo "  Backend Support (This Variant)"
echo "================================================"

case "${GPU_VARIANT}" in
    vulkan)
        echo "  • Vulkan (universal)"
        ;;
    nvidia)
        echo "  • CUDA (NVIDIA optimized)"
        echo "  • Vulkan (fallback)"
        ;;
    rocm)
        echo "  • ROCm (AMD optimized)"
        echo "  • Vulkan (fallback)"
        ;;
    all)
        echo "  • Vulkan (universal)"
        echo "  • CUDA (NVIDIA)"
        echo "  • ROCm (AMD)"
        ;;
esac

echo ""
echo "================================================"
echo "  Model Paths"
echo "================================================"
echo "Ollama: ${OLLAMA_MODELS:-/models/ollama}"
echo "llama.cpp: ${LLAMA_MODELS:-/models/llama}"
echo "EXO: ${EXO_MODELS:-/models/exo}"
echo ""

echo "================================================"
echo "  Utility Commands"
echo "================================================"
echo "  detect-gpu      - Detect GPU hardware"
echo "  select-backend  - Select GPU backend"
echo "  validate-gpu    - Validate GPU setup"
echo "  gpu-info        - Show this information"
echo ""

echo "================================================"
echo "  Getting Started"
echo "================================================"
echo "1. Run 'detect-gpu' to identify your GPU"
echo "2. Set GPU_BACKEND environment variable if needed"
echo "3. Use this image as a base layer:"
echo "   FROM ghcr.io/penguincloud/ai-base:${GPU_VARIANT:-vulkan}"
echo ""
