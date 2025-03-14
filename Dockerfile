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

RUN npm install --prefix forms-flow-admin && npm run build --prefix forms-flow-admin
RUN npm install --prefix forms-flow-components && npm run build --prefix forms-flow-components
RUN npm install --prefix forms-flow-integration && npm run build --prefix forms-flow-integration
RUN npm install --prefix forms-flow-nav && npm run build --prefix forms-flow-nav
RUN npm install --prefix forms-flow-rsbcservice && npm run build --prefix forms-flow-rsbcservice
RUN npm install --prefix forms-flow-service && npm run build --prefix forms-flow-service
RUN npm install --prefix forms-flow-theme && npm run build --prefix forms-flow-theme

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

# Serve gzipped JS files
RUN find /usr/share/nginx/html -name '*.js' -exec gzip -k {} \;

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
