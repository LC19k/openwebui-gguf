FROM ubuntu:22.04 AS builder

# Install dependencies
RUN apt-get update && apt-get install -y \
    git python3 python3-pip python3-venv \
    build-essential cmake curl

# Clone the GGUF-enabled branch
RUN git clone --branch local-backend https://github.com/open-webui/open-webui.git /app

# Build llama.cpp backend
RUN git clone https://github.com/ggerganov/llama.cpp.git /llama.cpp
WORKDIR /llama.cpp
RUN cmake -B build
RUN cmake --build build --config Release -j

# Install backend Python deps
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

# Build frontend
WORKDIR /app/frontend
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
RUN apt-get install -y nodejs
RUN npm install
RUN npm run build

# Final runtime image
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y python3 python3-pip libstdc++6 libgomp1

WORKDIR /app

# Copy backend
COPY --from=builder /app /app

# Copy llama.cpp
COPY --from=builder /llama.cpp/build/bin /llama-bin

# Expose port
EXPOSE 8080

CMD ["python3", "-m", "open_webui"]
