# Unprivileged image: runs as non-root (uid 101) and listens on 8080.
FROM nginxinc/nginx-unprivileged:alpine

# Copy only static assets served by nginx.
COPY index.html /usr/share/nginx/html/index.html
COPY app.js /usr/share/nginx/html/app.js
COPY style.css /usr/share/nginx/html/style.css

# Render nginx config from environment at container startup.
COPY nginx.conf.template /etc/nginx/templates/default.conf.template
EXPOSE 8080
