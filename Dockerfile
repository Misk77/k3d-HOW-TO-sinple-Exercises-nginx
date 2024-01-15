# Use the official Nginx base image
FROM nginx:latest

# Run a shell command to get the content of /etc/hostname and set it as NODE_NAME
RUN export NODE_NAME=$(cat /etc/hostname) && \
    echo "export NODE_NAME=$NODE_NAME" >> /etc/profile.d/custom.sh

# Copy the custom Nginx configuration to the container
COPY nginx.conf /etc/nginx/nginx.conf

