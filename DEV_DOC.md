
# Developer documentation

## Prerequisites

- A Linux virtual machine (tested on Debian 13) with Docker, the Docker Compose plugin, `make` and `git`.
- A user named `jdelattr`: the data folders are in `/home/jdelattr/data`.

## Set up from scratch

1. Clone the repository.
2. Add the domain to `/etc/hosts`:
   ```bash
   echo "127.0.0.1 jdelattr.42.fr" | sudo tee -a /etc/hosts
   ```
3. Create the configuration file and fill it in:
   ```bash
   cp srcs/.env.example srcs/.env
   ```
   | Variable | Meaning |
   |---|---|
   | `DOMAIN_NAME` | Domain of the site |
   | `SQL_DATABASE` | Database name |
   | `SQL_USER` | Database user |
   | `WP_TITLE` | Site title |
   | `WP_ADMIN_USER`, `WP_ADMIN_EMAIL` | WordPress administrator |
   | `WP_USER`, `WP_USER_EMAIL` | WordPress second user |
4. Create the secrets, one password per file, with no trailing newline:
   ```bash
   mkdir -p secrets
   printf 'password' > secrets/db_password.txt
   printf 'password' > secrets/db_root_password.txt
   printf 'password' > secrets/wp_admin_password.txt
   printf 'password' > secrets/wp_user_password.txt
   ```
   `srcs/.env` and `secrets/` are in `.gitignore`.

## Project layout

```
Makefile
secrets/                     passwords (not in git)
srcs/
  docker-compose.yml
  .env                       configuration (not in git)
  requirements/
    mariadb/    Dockerfile, conf/, tools/init.sh
    wordpress/  Dockerfile, conf/, tools/setup.sh
    nginx/      Dockerfile, conf/
```

## Build and launch

`make` creates the data folders, then runs
`docker compose -f srcs/docker-compose.yml up -d --build`.

| Command | Effect |
|---|---|
| `make` | Build and start |
| `make down` | Stop and remove containers and network (data kept) |
| `make clean` | `down`, plus remove Docker volumes and built images (data kept) |
| `make fclean` | `clean`, plus delete everything in `/home/jdelattr/data` |
| `make re` | `fclean`, then `make` |
| `make ps` / `make logs` | Show containers / logs |

## Useful commands

```bash
docker ps                                        # running containers
docker logs wordpress                            # logs of one container
docker exec -it mariadb bash                     # shell inside a container
docker exec wordpress wp user list --allow-root  # WordPress users
docker images                                    # built images
docker network ls                                # networks
docker volume ls                                 # volumes
docker volume inspect inception_mariadb_data     # where a volume stores its data
```

## Where the data is and how it persists

| Volume | Stored on the host | Mounted in the container |
|---|---|---|
| `inception_mariadb_data` | `/home/jdelattr/data/mariadb` | `/var/lib/mysql` (mariadb) |
| `inception_wordpress_data` | `/home/jdelattr/data/wordpress` | `/var/www/html` (wordpress and nginx) |

The data lives on the host, not in the containers, so it survives `make down`,
`make clean` and container restarts. Only `make fclean` deletes it.

The start-up scripts configure the services only on the first start:
`init.sh` checks whether the database folder exists, and `setup.sh` checks whether
`wp-config.php` exists. On the next starts, they skip the installation.

The files in `data/` belong to the container users (`mysql`, `www-data`), so deleting
them by hand needs `sudo`. `make fclean` does it for you.
