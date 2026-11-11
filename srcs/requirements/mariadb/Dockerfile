FROM debian:bookworm

# install Mariadb
RUN apt-get update && apt-get install -y mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

# copy my config on the default one
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# copy my script
COPY tools/init.sh /usr/local/bin/init.sh

# make it executable
RUN chmod +x /usr/local/bin/init.sh

# "this container tlks on 3306"
EXPOSE 3306

# the programthe container is buit to run 
ENTRYPOINT ["/usr/local/bin/init.sh"]

