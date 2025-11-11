FROM nginx:latest

# Install logrotate
RUN apt-get update && apt-get -y install logrotate

COPY ./config/nginx.conf /etc/nginx/nginx.conf

COPY ./config/security.conf /etc/nginx/conf.d/security.conf

#RUN chown -R www-data:www-data /var/www/html

#Copy logrotate nginx configuration
COPY ./config/logrotate.d/nginx /etc/logrotate.d/

CMD service cron start && nginx -g 'daemon off;'
