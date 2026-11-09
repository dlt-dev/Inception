FROM debian:bookworm


#nginx = web server, openssl = to make the TLS certificate
#RUN apt-get update && apt-get install -y --no install-recommends \
    #nginx openssl \
    #&& rm -rf /var/lib/apt/lists/*

RUN apt update && \
    apt install -y nginx openssl && \
    apt upgrade -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# remove le site par default port 80
RUN rm -f /etc/nginx/sites-enabled/default


# 
RUN mkdir -p /etc/nginx/ssl && openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=IDF/L=PARIS/0=42/CN=jdelattr.42.fr"

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

