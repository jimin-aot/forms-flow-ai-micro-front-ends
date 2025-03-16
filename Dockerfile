FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json for each microfrontend before running npm install
COPY forms-flow-admin/package.json forms-flow-admin/
COPY forms-flow-admin/package-lock.json forms-flow-admin/

COPY forms-flow-components/package.json forms-flow-components/
COPY forms-flow-components/package-lock.json forms-flow-components/

COPY forms-flow-integration/package.json forms-flow-integration/
COPY forms-flow-integration/package-lock.json forms-flow-integration/

COPY forms-flow-nav/package.json forms-flow-nav/
COPY forms-flow-nav/package-lock.json forms-flow-nav/

COPY forms-flow-rsbcservice/package.json forms-flow-rsbcservice/
COPY forms-flow-rsbcservice/package-lock.json forms-flow-rsbcservice/

COPY forms-flow-service/package.json forms-flow-service/
COPY forms-flow-service/package-lock.json forms-flow-service/

COPY forms-flow-theme/package.json forms-flow-theme/
COPY forms-flow-theme/package-lock.json forms-flow-theme/

# Install dependencies for each microfrontend
RUN npm install --prefix forms-flow-admin --legacy-peer-deps || true
RUN npm install --prefix forms-flow-components --legacy-peer-deps || true
RUN npm install --prefix forms-flow-integration --legacy-peer-deps || true
RUN npm install --prefix forms-flow-nav --legacy-peer-deps || true
RUN npm install --prefix forms-flow-rsbcservice --legacy-peer-deps || true
RUN npm install --prefix forms-flow-service --legacy-peer-deps || true
RUN npm install --prefix forms-flow-theme --legacy-peer-deps || true

# Copy source code and install dependencies
COPY forms-flow-admin /app/forms-flow-admin
COPY forms-flow-components /app/forms-flow-components
COPY forms-flow-integration /app/forms-flow-integration
COPY forms-flow-nav /app/forms-flow-nav
COPY forms-flow-rsbcservice /app/forms-flow-rsbcservice
COPY forms-flow-service /app/forms-flow-service
COPY forms-flow-theme /app/forms-flow-theme

# Build each microfrontend
RUN npm run build --prefix forms-flow-admin || true
RUN npm run build --prefix forms-flow-components || true
RUN npm run build --prefix forms-flow-integration || true
RUN npm run build --prefix forms-flow-nav || true
RUN npm run build --prefix forms-flow-rsbcservice || true
RUN npm run build --prefix forms-flow-service || true
RUN npm run build --prefix forms-flow-theme || true

# Compress JavaScript files
# RUN find /app -name '*.js' -exec sh -c 'gzip -9 -c "$1" > "${1%.js}.gz.js"' _ {} \;

# Use Nginx to serve the static files
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built files from builder
COPY --from=builder /app/forms-flow-admin/dist /usr/share/nginx/html/forms-flow-admin
COPY --from=builder /app/forms-flow-components/dist /usr/share/nginx/html/forms-flow-components
COPY --from=builder /app/forms-flow-integration/dist /usr/share/nginx/html/forms-flow-integration
COPY --from=builder /app/forms-flow-nav/dist /usr/share/nginx/html/forms-flow-nav
COPY --from=builder /app/forms-flow-rsbcservice/dist /usr/share/nginx/html/forms-flow-rsbcservice
COPY --from=builder /app/forms-flow-service/dist /usr/share/nginx/html/forms-flow-service
COPY --from=builder /app/forms-flow-theme/dist /usr/share/nginx/html/forms-flow-theme

# Expose Nginx port
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
