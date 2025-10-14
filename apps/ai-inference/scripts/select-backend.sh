#!/bin/bash
# Backend Selection Script for AI Base Layer
# Automatically selects best GPU backend based on hardware and availability

set -e

# Source detection script
SCRIPT_DIR="$(dirname "$0")"

# Get GPU_BACKEND from environment or auto-detect
BACKEND="${GPU_BACKEND:-auto}"

if [ "$BACKEND" = "auto" ]; then
    echo "Auto-detecting GPU backend..."

    # Check for NVIDIA
    if command -v nvidia-smi &> /dev/null && [ "$GPU_VARIANT" = "nvidia" ] || [ "$GPU_VARIANT" = "all" ]; then
        BACKEND="cuda"
        echo "Selected: CUDA (NVIDIA GPU detected)"

    # Check for AMD
    elif command -v rocm-smi &> /dev/null && [ "$GPU_VARIANT" = "rocm" ] || [ "$GPU_VARIANT" = "all" ]; then
        BACKEND="rocm"
        echo "Selected: ROCm (AMD GPU detected)"

    # Default to Vulkan
    elif command -v vulkaninfo &> /dev/null; then
        BACKEND="vulkan"
        echo "Selected: Vulkan (universal fallback)"

    else
        echo "Warning: No GPU detected, using CPU mode"
        BACKEND="cpu"
    fi
fi

# Export selected backend
export GPU_BACKEND="$BACKEND"

# Set appropriate environment variables for each backend
case "$BACKEND" in
    cuda)
        export LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"
        export PATH="/usr/local/cuda/bin:${PATH}"
        export CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-0}"
        echo "CUDA environment configured"
        ;;

    rocm)
        export LD_LIBRARY_PATH="/opt/rocm/lib:${LD_LIBRARY_PATH}"
        export PATH="/opt/rocm/bin:${PATH}"
        export HSA_OVERRIDE_GFX_VERSION="${HSA_OVERRIDE_GFX_VERSION:-10.3.0}"
        echo "ROCm environment configured"
        ;;

    vulkan)
        export VK_LAYER_PATH="/usr/share/vulkan/explicit_layer.d"
        export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}"
        echo "Vulkan environment configured"
        ;;

    cpu)
        echo "CPU-only mode (no GPU acceleration)"
        ;;

    *)
        echo "Error: Unknown backend '$BACKEND'"
        echo "Valid options: cuda, rocm, vulkan, cpu, auto"
        exit 1
        ;;
esac

# Print final configuration
echo ""
echo "=== Backend Configuration ==="
echo "GPU_BACKEND: $GPU_BACKEND"
echo "GPU_VARIANT: ${GPU_VARIANT:-not set}"
echo "LD_LIBRARY_PATH: ${LD_LIBRARY_PATH}"
echo ""
