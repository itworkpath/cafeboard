# ── Multi-stage build for CafeBoard Frontend (React + Vite) ────
# Stage 1: builder — install deps and build static assets
FROM node:20-alpine AS builder

WORKDIR /build

# Copy package files first (layer cache)
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm ci --ignore-scripts

# Copy source and build
COPY . .
RUN npm run build

# Stage 2: runtime — serve with nginx, non-root
FROM nginx:alpine AS runtime

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config (SPA + API proxy + WebSocket)
COPY nginx.conf /etc/nginx/conf.d/cafeboard.conf

# Copy built assets from builder
COPY --from=builder /build/dist /usr/share/nginx/html

# Run nginx as non-root (alpine image already has nginx user)
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
