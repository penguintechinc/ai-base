#!/bin/bash
# GPU Validation Script
# Validates GPU availability and backend compatibility

set -e

EXIT_CODE=0

echo "=== GPU Validation ==="
echo ""

# Get requested backend
BACKEND="${GPU_BACKEND:-vulkan}"

echo "Validating backend: $BACKEND"
echo ""

# Validate based on backend
case "$BACKEND" in
    cuda)
        echo "Checking CUDA availability..."
        if command -v nvidia-smi &> /dev/null; then
            nvidia-smi > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo "✓ CUDA runtime available"
                nvidia-smi --query-gpu=name --format=csv,noheader
            else
                echo "✗ CUDA runtime check failed"
                EXIT_CODE=1
            fi
        else
            echo "✗ nvidia-smi not found"
            EXIT_CODE=1
        fi

        if [ "$GPU_VARIANT" != "nvidia" ] && [ "$GPU_VARIANT" != "all" ]; then
            echo "✗ CUDA not available in variant: $GPU_VARIANT"
            EXIT_CODE=1
        fi
        ;;

    rocm)
        echo "Checking ROCm availability..."
        if command -v rocm-smi &> /dev/null; then
            rocm-smi --showproductname > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo "✓ ROCm runtime available"
                rocm-smi --showproductname
            else
                echo "✗ ROCm runtime check failed"
                EXIT_CODE=1
            fi
        else
            echo "✗ rocm-smi not found"
            EXIT_CODE=1
        fi

        if [ "$GPU_VARIANT" != "rocm" ] && [ "$GPU_VARIANT" != "all" ]; then
            echo "✗ ROCm not available in variant: $GPU_VARIANT"
            EXIT_CODE=1
        fi
        ;;

    vulkan)
        echo "Checking Vulkan availability..."
        if command -v vulkaninfo &> /dev/null; then
            VULKAN_DEVICES=$(vulkaninfo --summary 2>/dev/null | grep -c "GPU" || echo "0")
            if [ "$VULKAN_DEVICES" -gt 0 ]; then
                echo "✓ Vulkan runtime available with $VULKAN_DEVICES device(s)"
                vulkaninfo --summary 2>/dev/null | grep "deviceName" || true
            else
                echo "✗ No Vulkan devices found"
                EXIT_CODE=1
            fi
        else
            echo "✗ vulkaninfo not found"
            EXIT_CODE=1
        fi
        ;;

    cpu)
        echo "✓ CPU mode (no GPU validation required)"
        ;;

    *)
        echo "✗ Unknown backend: $BACKEND"
        EXIT_CODE=1
        ;;
esac

echo ""
echo "=== Inference Engine Validation ==="

# Check Ollama
if command -v ollama &> /dev/null; then
    echo "✓ Ollama: $(ollama --version 2>/dev/null || echo 'installed')"
else
    echo "✗ Ollama: not found"
    EXIT_CODE=1
fi

# Check llama.cpp
if command -v llama-cli &> /dev/null || [ -f /opt/ai-base/bin/llama-cli ]; then
    echo "✓ llama.cpp: installed"
else
    echo "⚠ llama.cpp: not found (check /opt/ai-base/bin/)"
fi

# Check llm-d
if command -v llm-d &> /dev/null || [ -f /opt/ai-base/bin/llm-d ]; then
    echo "✓ llm-d: installed"
else
    echo "⚠ llm-d: not found"
fi

# Check EXO
if python3 -c "import exo" 2>/dev/null; then
    echo "✓ EXO: installed"
else
    echo "⚠ EXO: not found"
fi

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "=== Validation: PASSED ==="
else
    echo "=== Validation: FAILED ==="
fi

exit $EXIT_CODE
