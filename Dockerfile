FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy source code and install dependencies
COPY forms-flow-admin /app/forms-flow-admin
COPY forms-flow-components /app/forms-flow-components
COPY forms-flow-integration /app/forms-flow-integration
COPY forms-flow-nav /app/forms-flow-nav
COPY forms-flow-rsbcservice /app/forms-flow-rsbcservice
COPY forms-flow-service /app/forms-flow-service
COPY forms-flow-theme /app/forms-flow-theme

# Install all dependencies before building to avoid redundant installations
RUN npm install --legacy-peer-deps

# Fix TypeScript issues in react-i18next
RUN npm install --prefix forms-flow-admin @types/i18next --legacy-peer-deps

# Build each microfrontend
RUN npm run build --prefix forms-flow-admin
RUN npm run build --prefix forms-flow-components
RUN npm run build --prefix forms-flow-integration
RUN npm run build --prefix forms-flow-nav
RUN npm run build --prefix forms-flow-rsbcservice
RUN npm run build --prefix forms-flow-service
RUN npm run build --prefix forms-flow-theme

# Compress JavaScript files
RUN find /app -name '*.js' -exec gzip -k {} \;

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
