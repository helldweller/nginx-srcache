ARG NGINX_VERSION=1.19.2

FROM debian:stretch as build

ARG NGINX_VERSION=1.19.2
ARG SRCACHE_VERSION=0.32
# Nginx Development kit
ARG NDK_VERSION=0.3.1
ARG NGINX_SMM_VERSION=0.32
ARG NGINX_ECHOM_VERSION=0.62
ARG NGX_HTTP_REDIS=0.3.9
ARG NGX_REDIS2=0.15

RUN apt-get update && apt-get -y install gcc libpcre3-dev zlib1g-dev make libssl-dev

ADD "https://github.com/vision5/ngx_devel_kit/archive/refs/tags/v${NDK_VERSION}.tar.gz" /tmp/ngx_devel_kit-${NDK_VERSION}.tar.gz
ADD "https://github.com/openresty/set-misc-nginx-module/archive/refs/tags/v${NGINX_SMM_VERSION}.tar.gz" /tmp/set-misc-nginx-module-${NGINX_SMM_VERSION}.tar.gz
ADD "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" /tmp/nginx-${NGINX_VERSION}.tar.gz
ADD "https://github.com/openresty/srcache-nginx-module/archive/refs/tags/v${SRCACHE_VERSION}.tar.gz" /tmp/srcache-nginx-module-${SRCACHE_VERSION}.tar.gz
ADD "https://github.com/openresty/echo-nginx-module/archive/refs/tags/v${NGINX_ECHOM_VERSION}.tar.gz" /tmp/echo-nginx-module-${NGINX_ECHOM_VERSION}.tar.gz
ADD "https://people.freebsd.org/~osa/ngx_http_redis-${NGX_HTTP_REDIS}.tar.gz" /tmp/ngx_http_redis-${NGX_HTTP_REDIS}.tar.gz
ADD "https://github.com/openresty/redis2-nginx-module/archive/refs/tags/v${NGX_REDIS2}.tar.gz" /tmp/redis2-nginx-module-${NGX_REDIS2}.tar.gz

RUN tar xzf /tmp/nginx-${NGINX_VERSION}.tar.gz -C /usr/src \
    && tar xzf /tmp/srcache-nginx-module-${SRCACHE_VERSION}.tar.gz -C /usr/src \
    && tar xzf /tmp/set-misc-nginx-module-${NGINX_SMM_VERSION}.tar.gz -C /usr/src \
    && tar xzf /tmp/ngx_devel_kit-${NDK_VERSION}.tar.gz -C /usr/src \
    && tar xzf /tmp/echo-nginx-module-${NGINX_ECHOM_VERSION}.tar.gz -C /usr/src \
    && tar xzf /tmp/ngx_http_redis-${NGX_HTTP_REDIS}.tar.gz -C /usr/src \
    && tar xzf /tmp/redis2-nginx-module-${NGX_REDIS2}.tar.gz -C /usr/src

#RUN ls -la /usr/src && exit 1
# drwxrwxr-x 5 root root  4096 Jan 22  2020 echo-nginx-module-0.62
# drwxr-xr-x 8 1001  1001 4096 Apr 21  2020 nginx-1.18.0
# drwxrwxr-x 9 root root  4096 Jan 27  2018 ngx_devel_kit-0.3.1
# drwxr-xr-x 3 1001 staff 4096 Nov  5  2016 ngx_http_redis-0.3.9
# drwxrwxr-x 6 root root  4096 Apr 19  2018 redis2-nginx-module-0.15
# drwxrwxr-x 5 root root  4096 Apr 19  2018 set-misc-nginx-module-0.32
# drwxrwxr-x 5 root root  4096 Jan 22  2020 srcache-nginx-module-0.32

RUN cd /usr/src/nginx-${NGINX_VERSION} \
    && ./configure \
        --with-http_ssl_module \
        --prefix=/opt/nginx \
        --with-compat \
        --add-dynamic-module=/usr/src/srcache-nginx-module-${SRCACHE_VERSION} \
        --add-dynamic-module=/usr/src/ngx_devel_kit-${NDK_VERSION} \
        --add-dynamic-module=/usr/src/set-misc-nginx-module-${NGINX_SMM_VERSION} \
        --add-dynamic-module=/usr/src/echo-nginx-module-${NGINX_ECHOM_VERSION} \
        --add-dynamic-module=/usr/src/ngx_http_redis-${NGX_HTTP_REDIS} \
        --add-dynamic-module=/usr/src/redis2-nginx-module-${NGX_REDIS2} \
    && make -j2 \
    && make install


FROM nginx:${NGINX_VERSION}
COPY --from=build /opt/nginx/modules/ngx_http_srcache_filter_module.so /usr/lib/nginx/modules/
COPY --from=build /opt/nginx/modules/ngx_http_set_misc_module.so /usr/lib/nginx/modules/
COPY --from=build /opt/nginx/modules/ndk_http_module.so /usr/lib/nginx/modules/
COPY --from=build /opt/nginx/modules/ngx_http_echo_module.so /usr/lib/nginx/modules/
COPY --from=build /opt/nginx/modules/ngx_http_redis_module.so /usr/lib/nginx/modules/
COPY --from=build /opt/nginx/modules/ngx_http_redis2_module.so /usr/lib/nginx/modules/
