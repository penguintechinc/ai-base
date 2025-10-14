# Multi-Variant AI Base Layer Image
# Supports: Ollama, llama.cpp, EXO
# GPU Backends: Vulkan (default, WORKING), CUDA (NVIDIA, IN PROGRESS), ROCm (AMD, IN PROGRESS)
#
# Build variants:
#   vulkan: docker build --build-arg GPU_VARIANT=vulkan -t ai-base:vulkan . [WORKING]
#   nvidia: docker build --build-arg GPU_VARIANT=nvidia -t ai-base:nvidia . [IN PROGRESS - requires Ubuntu base or NVIDIA base image]
#   rocm:   docker build --build-arg GPU_VARIANT=rocm -t ai-base:rocm . [IN PROGRESS - requires Ubuntu base or AMD base image]
#   latest: docker build --build-arg GPU_VARIANT=all -t ai-base:latest . [Pending NVIDIA/ROCm fixes]
#
# NOTE: NVIDIA and ROCm variants currently skip GPU toolkit installation due to package availability issues on Debian.
#       For production NVIDIA/ROCm builds, consider using nvidia/cuda or rocm/dev-ubuntu base images.

ARG GPU_VARIANT=vulkan
ARG DEBIAN_VERSION=stable-slim
ARG VULKAN_SDK_VERSION=1.3.275
ARG CUDA_VERSION=11.8
ARG ROCM_VERSION=6.0

# =============================================================================
# Stage 1: Base System Dependencies
# =============================================================================
FROM debian:${DEBIAN_VERSION} AS base-system

LABEL maintainer="Penguin Tech Group LLC <info@penguintech.group>"
LABEL org.opencontainers.image.source="https://github.com/penguincloud/ai-base"
LABEL org.opencontainers.image.description="Multi-backend AI inference base layer"
LABEL org.opencontainers.image.licenses="AGPL-3.0"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH="/usr/local/bin:$PATH"

# Install common dependencies
# Note: Install gcc-12 for CUDA compatibility (CUDA 12.3 doesn't support GCC 14)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc-12 \
    g++-12 \
    ca-certificates \
    curl \
    libcurl4-openssl-dev \
    wget \
    git \
    cmake \
    ninja-build \
    pkg-config \
    libgomp1 \
    libopenblas-dev \
    python3 \
    python3-pip \
    python3-venv \
    pciutils \
    lshw \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Create working directories
RUN mkdir -p /opt/ai-base/{bin,lib,scripts,models} \
    && mkdir -p /usr/local/share/ai-base

# =============================================================================
# Stage 2: Vulkan SDK (Required for ALL variants - used by Ollama)
# =============================================================================
FROM base-system AS vulkan-sdk

# Install Vulkan runtime libraries and tools from system packages
# More reliable and smaller than downloading full SDK
RUN apt-get update && apt-get install -y --no-install-recommends \
    libvulkan1 \
    libvulkan-dev \
    vulkan-tools \
    vulkan-validationlayers \
    spirv-tools \
    glslang-tools \
    glslc \
    libshaderc-dev \
    mesa-vulkan-drivers \
    && rm -rf /var/lib/apt/lists/*

# Setup Vulkan environment
ENV VK_LAYER_PATH="/usr/share/vulkan/explicit_layer.d" \
    VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/radeon_icd.x86_64.json:/usr/share/vulkan/icd.d/intel_icd.x86_64.json" \
    LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"

# =============================================================================
# Stage 3: CUDA Toolkit (Conditional - nvidia and all variants only)
# =============================================================================
FROM vulkan-sdk AS cuda-toolkit

ARG CUDA_VERSION
ARG GPU_VARIANT

# Only install CUDA if building nvidia or all variant
# NOTE: CUDA packages not available in Debian repos - requires Ubuntu base or nvidia/cuda image
# Creating placeholder directories for now to allow build to continue
RUN if [ "$GPU_VARIANT" = "nvidia" ] || [ "$GPU_VARIANT" = "all" ]; then \
    echo "WARNING: CUDA installation skipped - Debian repos do not contain CUDA packages" && \
    echo "For CUDA support, use nvidia/cuda base image or Ubuntu-based build" && \
    mkdir -p /usr/local/cuda/{bin,lib64,include} && \
    echo "CUDA placeholders created"; \
    else \
    echo "Skipping CUDA installation for variant: $GPU_VARIANT" && \
    mkdir -p /usr/local/cuda; \
    fi

ENV CUDA_HOME="/usr/local/cuda" \
    PATH="/usr/local/cuda/bin:$PATH" \
    LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"

# =============================================================================
# Stage 4: ROCm (Conditional - rocm and all variants only)
# =============================================================================
FROM cuda-toolkit AS rocm-toolkit

ARG ROCM_VERSION
ARG GPU_VARIANT

# Only install ROCm if building rocm or all variant
# NOTE: ROCm packages not available for Debian - requires Ubuntu base or rocm/dev-ubuntu image
# Creating placeholder directories for now to allow build to continue
RUN if [ "$GPU_VARIANT" = "rocm" ] || [ "$GPU_VARIANT" = "all" ]; then \
    echo "WARNING: ROCm installation skipped - Debian not officially supported by AMD" && \
    echo "For ROCm support, use rocm/dev-ubuntu base image or Ubuntu-based build" && \
    mkdir -p /opt/rocm/{bin,lib,include} && \
    echo "ROCm placeholders created"; \
    else \
    echo "Skipping ROCm installation for variant: $GPU_VARIANT" && \
    mkdir -p /opt/rocm; \
    fi

ENV ROCM_PATH="/opt/rocm" \
    PATH="/opt/rocm/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/rocm/lib:$LD_LIBRARY_PATH"

# =============================================================================
# Stage 5: Build llama.cpp with appropriate backends
# =============================================================================
FROM rocm-toolkit AS build-llamacpp

ARG GPU_VARIANT

WORKDIR /tmp/llama-build

# Clone llama.cpp
RUN git clone https://github.com/ggerganov/llama.cpp.git . \
    && git checkout master

# Build llama.cpp based on variant (using newer GGML_ prefix)
# NOTE: NVIDIA and ROCm variants fall back to Vulkan since GPU toolkits aren't available on Debian
RUN if [ "$GPU_VARIANT" = "vulkan" ]; then \
        cmake -B build -S . -DGGML_VULKAN=ON -DCMAKE_BUILD_TYPE=Release && \
        cmake --build build --config Release -j$(nproc); \
    elif [ "$GPU_VARIANT" = "nvidia" ]; then \
        echo "WARNING: Building with Vulkan backend (CUDA toolkit not available)" && \
        cmake -B build -S . -DGGML_VULKAN=ON -DCMAKE_BUILD_TYPE=Release && \
        cmake --build build --config Release -j$(nproc); \
    elif [ "$GPU_VARIANT" = "rocm" ]; then \
        echo "WARNING: Building with Vulkan backend (ROCm toolkit not available)" && \
        cmake -B build -S . -DGGML_VULKAN=ON -DCMAKE_BUILD_TYPE=Release && \
        cmake --build build --config Release -j$(nproc); \
    elif [ "$GPU_VARIANT" = "all" ]; then \
        echo "WARNING: Building with Vulkan backend (CUDA/ROCm toolkits not available)" && \
        cmake -B build -S . -DGGML_VULKAN=ON -DCMAKE_BUILD_TYPE=Release && \
        cmake --build build --config Release -j$(nproc); \
    fi

# Install llama.cpp binaries
RUN mkdir -p /opt/ai-base/bin && \
    if [ -d build/bin ]; then \
        cp build/bin/* /opt/ai-base/bin/; \
    else \
        find build -name "llama-*" -type f -executable -exec cp {} /opt/ai-base/bin/ \;; \
    fi

# =============================================================================
# Stage 6: Install Ollama (Always with Vulkan support)
# =============================================================================
FROM rocm-toolkit AS build-ollama

# Download and install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh \
    && mkdir -p /opt/ai-base/bin \
    && cp /usr/local/bin/ollama /opt/ai-base/bin/

# Configure Ollama to use Vulkan by default
ENV OLLAMA_GPU_BACKEND=vulkan

# =============================================================================
# Stage 7: Install EXO with appropriate backends
# =============================================================================
FROM rocm-toolkit AS build-exo

ARG GPU_VARIANT

# Install Python dependencies for EXO
RUN pip3 install --no-cache-dir --break-system-packages \
    exo-lang \
    torch \
    numpy

# Configure EXO based on variant
RUN if [ "$GPU_VARIANT" = "vulkan" ]; then \
        pip3 install --no-cache-dir --break-system-packages vulkan; \
    elif [ "$GPU_VARIANT" = "nvidia" ]; then \
        pip3 install --no-cache-dir --break-system-packages torch --index-url https://download.pytorch.org/whl/cu121; \
    elif [ "$GPU_VARIANT" = "rocm" ]; then \
        pip3 install --no-cache-dir --break-system-packages torch --index-url https://download.pytorch.org/whl/rocm5.7; \
    elif [ "$GPU_VARIANT" = "all" ]; then \
        pip3 install --no-cache-dir --break-system-packages vulkan && \
        pip3 install --no-cache-dir --break-system-packages torch --index-url https://download.pytorch.org/whl/cu121; \
    fi

# =============================================================================
# Stage 8: Final Runtime Image
# =============================================================================
FROM debian:${DEBIAN_VERSION} AS runtime

ARG GPU_VARIANT=vulkan

LABEL variant="${GPU_VARIANT}"
LABEL engines="ollama,llama.cpp,exo"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    GPU_VARIANT=${GPU_VARIANT} \
    GPU_BACKEND=vulkan \
    PATH="/opt/ai-base/bin:/usr/local/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/ai-base/lib:$LD_LIBRARY_PATH"

# Install minimal runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    libopenblas0 \
    python3 \
    python3-pip \
    curl \
    wget \
    jq \
    pciutils \
    lshw \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy Vulkan libraries and tools (required for all variants)
COPY --from=vulkan-sdk /usr/lib/x86_64-linux-gnu/libvulkan* /usr/lib/x86_64-linux-gnu/
COPY --from=vulkan-sdk /usr/bin/vulkaninfo /usr/bin/
COPY --from=vulkan-sdk /usr/share/vulkan /usr/share/vulkan

# Conditionally copy CUDA libraries
COPY --from=cuda-toolkit /usr/local/cuda /usr/local/cuda

# Conditionally copy ROCm libraries
COPY --from=rocm-toolkit /opt/rocm /opt/rocm

# Copy all built binaries
COPY --from=build-llamacpp /opt/ai-base/bin/* /opt/ai-base/bin/
COPY --from=build-ollama /opt/ai-base/bin/ollama /opt/ai-base/bin/

# Copy Python packages for EXO
# Note: Python version in Debian stable-slim is 3.13
COPY --from=build-exo /usr/local/lib/python3.13/dist-packages /usr/local/lib/python3.13/dist-packages

# Create model directories
RUN mkdir -p /models/{ollama,llama,exo} \
    && chmod -R 777 /models

# Copy helper scripts (will be added in next steps)
COPY scripts/*.sh /opt/ai-base/scripts/
RUN chmod +x /opt/ai-base/scripts/*.sh \
    && ln -s /opt/ai-base/scripts/detect-gpu.sh /usr/local/bin/detect-gpu \
    && ln -s /opt/ai-base/scripts/select-backend.sh /usr/local/bin/select-backend \
    && ln -s /opt/ai-base/scripts/validate-gpu.sh /usr/local/bin/validate-gpu \
    && ln -s /opt/ai-base/scripts/gpu-info.sh /usr/local/bin/gpu-info

# Set environment variables for each variant
RUN if [ "$GPU_VARIANT" = "vulkan" ]; then \
        echo "export GPU_BACKEND=vulkan" >> /etc/environment; \
    elif [ "$GPU_VARIANT" = "nvidia" ]; then \
        echo "export GPU_BACKEND=cuda" >> /etc/environment; \
    elif [ "$GPU_VARIANT" = "rocm" ]; then \
        echo "export GPU_BACKEND=rocm" >> /etc/environment; \
    elif [ "$GPU_VARIANT" = "all" ]; then \
        echo "export GPU_BACKEND=vulkan" >> /etc/environment; \
    fi

# Setup Vulkan environment for runtime
ENV VK_LAYER_PATH="/usr/share/vulkan/explicit_layer.d"

# Environment variables for model paths
ENV OLLAMA_MODELS=/models/ollama \
    LLAMA_MODELS=/models/llama \
    EXO_MODELS=/models/exo \
    LOG_LEVEL=info

WORKDIR /workspace

# Default command shows GPU info
CMD ["/usr/local/bin/gpu-info"]
