FROM nginx:alpine

RUN echo '<h1>🚀 Demo Jenkins CI/CD</h1>' \
    > /usr/share/nginx/html/index.html

EXPOSE 80