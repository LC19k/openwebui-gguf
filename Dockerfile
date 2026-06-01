# Base OpenWebUI image (frontend already built)
FROM openwebui/open-webui:latest AS base

# Build llama.cpp
FROM ubuntu:22.04 AS llama-builder
RUN apt-get update && apt-get install -y git build-essential cmake
RUN git clone https://github.com/ggerganov/llama.cpp.git /llama.cpp
WORKDIR /llama.cpp
RUN make -j

# Final image
FROM openwebui/open-webui:latest

# Copy llama.cpp binaries
COPY --from=llama-builder /llama.cpp /llama.cpp

# Enable GGUF backend
ENV WEBUI_ENABLE_LOCAL_MODELS=true

# Default command
CMD ["python3", "-m", "open_webui"]
