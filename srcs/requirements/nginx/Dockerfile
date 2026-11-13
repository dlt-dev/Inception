FROM debian:bookworm


#nginx = web server, openssl = to make the TLS certificate
#RUN apt-get update && apt-get install -y --no install-recommends \
    #nginx openssl \
    #&& rm -rf /var/lib/apt/lists/*

# install NGINX and openssl (tool for certificate)
# clean to keep image small
RUN apt update && \
    apt install -y nginx openssl && \
    apt upgrade -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# remove le site par default port 80 (we need 443)
RUN rm -f /etc/nginx/sites-enabled/default

# ss -tlnp | grep ':80 ' (check)


# create a selfsigned certificate + options 
# (1 year, no passphrse, where the key and certificate are writen ...)
RUN mkdir -p /etc/nginx/ssl && openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=IDF/L=PARIS/0=42/CN=jdelattr.42.fr"

# copy new config into the folder NGINX reads
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# port 443
EXPOSE 443

# the programthe container is buit to run 
# Without deamon off NGINX goes to the background, PID 1 exits, and the container stops
CMD ["nginx", "-g", "daemon off;"]

