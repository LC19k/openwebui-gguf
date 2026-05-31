FROM node:20 AS frontend-builder
WORKDIR /app
RUN git clone https://github.com/open-webui/open-webui.git .
RUN npm install --legacy-peer-deps
RUN npm run build

FROM python:3.11-slim AS backend-builder
WORKDIR /app
RUN apt-get update && apt-get install -y git build-essential cmake
RUN git clone https://github.com/open-webui/open-webui.git .
RUN pip install --no-cache-dir -r requirements.txt

# Build llama.cpp backend
RUN git clone https://github.com/ggerganov/llama.cpp.git /llama.cpp
WORKDIR /llama.cpp
RUN make -j

# Final runtime image
FROM python:3.11-slim
WORKDIR /app

# Install runtime deps
RUN apt-get update && apt-get install -y libstdc++6 libgomp1

# Copy backend
COPY --from=backend-builder /app /app
COPY --from=backend-builder /llama.cpp /llama.cpp

# Copy frontend
COPY --from=frontend-builder /app/build /app/frontend/build

# Expose port
EXPOSE 8080

# Start OpenWebUI
CMD ["python3", "-m", "open_webui"]
