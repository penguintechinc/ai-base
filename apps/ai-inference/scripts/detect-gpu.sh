#!/bin/bash
# GPU Detection Script for AI Base Layer
# Detects available GPU hardware and recommends backend

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== GPU Detection ===${NC}"

# Check for NVIDIA GPU
check_nvidia() {
    if command -v nvidia-smi &> /dev/null; then
        echo -e "${GREEN}✓ NVIDIA GPU detected${NC}"
        nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>/dev/null || echo "  Unable to query GPU details"
        return 0
    fi
    return 1
}

# Check for AMD GPU
check_amd() {
    if command -v rocm-smi &> /dev/null; then
        echo -e "${GREEN}✓ AMD GPU detected (ROCm)${NC}"
        rocm-smi --showproductname 2>/dev/null || echo "  Unable to query GPU details"
        return 0
    elif lspci 2>/dev/null | grep -i 'amd.*vga\|amd.*display\|amd.*radeon' > /dev/null; then
        echo -e "${YELLOW}⚠ AMD GPU detected but ROCm not available${NC}"
        lspci | grep -i 'amd.*vga\|amd.*display\|amd.*radeon'
        return 1
    fi
    return 1
}

# Check for Intel GPU
check_intel() {
    if lspci 2>/dev/null | grep -i 'intel.*vga\|intel.*display\|intel.*graphics' > /dev/null; then
        echo -e "${GREEN}✓ Intel GPU detected${NC}"
        lspci | grep -i 'intel.*vga\|intel.*display\|intel.*graphics'
        return 0
    fi
    return 1
}

# Check for Vulkan support
check_vulkan() {
    if command -v vulkaninfo &> /dev/null; then
        echo -e "${GREEN}✓ Vulkan runtime detected${NC}"
        VULKAN_DEVICES=$(vulkaninfo --summary 2>/dev/null | grep -c "GPU" || echo "0")
        if [ "$VULKAN_DEVICES" -gt 0 ]; then
            echo "  Vulkan-capable devices: $VULKAN_DEVICES"
            vulkaninfo --summary 2>/dev/null | grep "deviceName" || true
        fi
        return 0
    fi
    return 1
}

# Detect GPUs
NVIDIA_FOUND=0
AMD_FOUND=0
INTEL_FOUND=0
VULKAN_FOUND=0

check_nvidia && NVIDIA_FOUND=1 || true
check_amd && AMD_FOUND=1 || true
check_intel && INTEL_FOUND=1 || true
check_vulkan && VULKAN_FOUND=1 || true

echo ""
echo -e "${BLUE}=== Backend Recommendations ===${NC}"

# Recommend backend based on detection
if [ $NVIDIA_FOUND -eq 1 ] && [ "$GPU_VARIANT" = "nvidia" ] || [ "$GPU_VARIANT" = "all" ]; then
    echo -e "${GREEN}Recommended: GPU_BACKEND=cuda${NC}"
    echo "  NVIDIA GPU with CUDA support available"
elif [ $AMD_FOUND -eq 1 ] && [ "$GPU_VARIANT" = "rocm" ] || [ "$GPU_VARIANT" = "all" ]; then
    echo -e "${GREEN}Recommended: GPU_BACKEND=rocm${NC}"
    echo "  AMD GPU with ROCm support available"
elif [ $VULKAN_FOUND -eq 1 ]; then
    echo -e "${GREEN}Recommended: GPU_BACKEND=vulkan${NC}"
    echo "  Vulkan provides universal GPU support"
else
    echo -e "${YELLOW}⚠ No GPU detected or no drivers available${NC}"
    echo "  Falling back to CPU mode"
fi

echo ""
echo -e "${BLUE}=== Container Variant ===${NC}"
echo "  GPU_VARIANT: ${GPU_VARIANT:-not set}"
echo "  Available backends in this image:"

case "${GPU_VARIANT}" in
    vulkan)
        echo "    - Vulkan (universal)"
        ;;
    nvidia)
        echo "    - CUDA (NVIDIA optimized)"
        echo "    - Vulkan (fallback)"
        ;;
    rocm)
        echo "    - ROCm (AMD optimized)"
        echo "    - Vulkan (fallback)"
        ;;
    all)
        echo "    - Vulkan (universal)"
        echo "    - CUDA (NVIDIA)"
        echo "    - ROCm (AMD)"
        ;;
    *)
        echo "    - Unknown variant"
        ;;
esac

echo ""
