FROM nginx:latest

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libpcre2-dev \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    wget \
    ca-certificates \
    unzip \
    libbrotli-dev \
    && rm -rf /var/lib/apt/lists/*

# Lấy source nginx + module brotli
RUN cd /tmp && \
     NGINX_VERSION=$(nginx -v 2>&1 | cut -d/ -f2) && \
     wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
     tar zxvf nginx-$NGINX_VERSION.tar.gz && \
     git clone --recursive https://github.com/google/ngx_brotli.git && \
     cd ngx_brotli && git submodule update --init && cd .. && \
     cd nginx-$NGINX_VERSION && \
     ./configure --with-compat --add-dynamic-module=../ngx_brotli && \
     make modules && \
     cp objs/ngx_http_brotli_filter_module.so /etc/nginx/modules/ && \
     cp objs/ngx_http_brotli_static_module.so /etc/nginx/modules/ && \
     cd / && rm -rf /tmp/*

# Load module trong nginx.conf
RUN mkdir -p /etc/nginx/modules-enabled && \
    echo "load_module modules/ngx_http_brotli_filter_module.so;" > /etc/nginx/modules-enabled/50-mod-http-brotli.conf && \
    echo "load_module modules/ngx_http_brotli_static_module.so;" >> /etc/nginx/modules-enabled/50-mod-http-brotli.conf

# Install logrotate
RUN apt-get update && apt-get -y install logrotate

COPY ./config/nginx.conf /etc/nginx/nginx.conf

COPY ./config/security.conf /etc/nginx/conf.d/security.conf

#Copy logrotate nginx configuration
COPY ./config/logrotate.d/nginx /etc/logrotate.d/

CMD service cron start && nginx -g 'daemon off;'
