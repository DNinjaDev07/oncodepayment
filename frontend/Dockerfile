FROM nginx:alpine

# Copy only static assets served by nginx.
COPY index.html /usr/share/nginx/html/index.html
COPY app.js /usr/share/nginx/html/app.js
COPY style.css /usr/share/nginx/html/style.css

# Render nginx config from environment at container startup.
COPY nginx.conf.template /etc/nginx/templates/default.conf.template
EXPOSE 80
