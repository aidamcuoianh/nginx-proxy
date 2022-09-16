FROM nginx:latest

ENV NGINX_VERSION 1.17.6
ENV NGX_BROTLI_COMMIT e505dce68acc190cc5a1e780a3b0275e39f160ca

RUN CONFIG="\
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-compat \
        --with-file-aio \
        --with-threads \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-stream \
        --with-stream_realip_module \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --add-module=/usr/local/src/ngx_brotli \
    " \
    && apt-get update \
    && apt-get -y install build-essential \
         zlib1g-dev  \
         libpcre3-dev  \
         libssl-dev  \
         libxslt1-dev  \
         libxml2-dev  \
         libgeoip-dev  \
         libgoogle-perftools-dev  \
         libperl-dev  \
         curl  \
         git \
    && cd /usr/local/src \
    && git clone https://github.com/google/ngx_brotli.git \
    && cd ngx_brotli \
    && git submodule update --init --recursive \
    && git checkout -b $NGX_BROTLI_COMMIT $NGX_BROTLI_COMMIT \
    && cd .. \
    && curl -fS http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx-$NGINX_VERSION.tar.gz \
    && tar -xzvf nginx-$NGINX_VERSION.tar.gz \
    && rm nginx-$NGINX_VERSION.tar.gz \
    && cd /usr/local/src/nginx-$NGINX_VERSION \
    && ./configure --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' $CONFIG \
    && make \
    && make install \
    && cd .. \
    && rm -rf /usr/local/src/nginx-$NGINX_VERSION \
    && rm -rf /usr/local/src/ngx_brotli \
	&& service nginx restart

# Install logrotate
RUN apt-get -y install logrotate

COPY ./config/nginx.conf /etc/nginx/nginx.conf

COPY ./config/security.conf /etc/nginx/conf.d/security.conf

#Copy logrotate nginx configuration
COPY ./config/logrotate.d/nginx /etc/logrotate.d/

CMD service cron start && nginx -g 'daemon off;'

