FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html
COPY chart.umd.min.js /usr/share/nginx/html/chart.umd.min.js
EXPOSE 80
