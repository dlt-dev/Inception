*This project has been created as part of the 42 curriculum by jdelattr.*

# Inception

<img width="1041" height="639" alt="image" src="https://github.com/user-attachments/assets/d0fac912-b355-44a3-9c3b-2e3fbbe20a13" />

# Description

Inception is a 42 system-administration project that builds a small web infrastructure with Docker Compose, running inside a virtual machine. Three containers, each built from its own Dockerfile on Debian, work together: NGINX (the only entry point, HTTPS on port 443 with TLS 1.2/1.3), WordPress with php-fpm and MariaDB. Data persists in volumes stored on the host, passwords are kept out of git using Docker secrets and a .env file, and a single make command builds and starts everything.

**Design choices (implicated by the subject)**

- One process per container, launched with `exec` so it runs as PID 1 (clean stop, correct signals).
- Start-up scripts configure the service on the first start only, then hand over to it.
- Only port 443 is published; MariaDB and php-fpm stay private.
- Containers restart automatically after a crash (`restart: unless-stopped`).

**The project working (who is talking to who ?)**

<img width="1675" height="502" alt="image" src="https://github.com/user-attachments/assets/d0847191-b4fa-424a-9b72-ddb564978533" />



# General knowledge of the project


**Virtual Machine vs Docker**

-  A VM is a whole separate house. It has its own foundations (a full operating system with its own kernel). It’s well isolated, but heavy: it takes gigabytes and a minute to boot.

-  A Docker container is an apartment in a shared building. It has its own walls (isolated files, processes and network), but it shares the building’s foundations: the host’s kernel. So it’s light (megabytes) and starts in a second.

**Secrets vs Environment Variables**

-  An environment variable is a note stuck on the wall of the room. Simple, and your program reads it easily. But anyone who enters can read it: docker inspect shows it, and every process in the container can see it.

-  A secret is a document in a locked drawer. Docker puts it as a file in /run/secrets/ (in memory, not on disk), and only for the containers you chose. Your script reads the file when it needs it.

**Docker Network vs Host Network**

-  A Docker (bridge) network is a private office network. Containers get their own address and can call each other by name (mariadb, wordpress), like internal phone extensions. The outside only sees the ports you deliberately publish (443).

-  The host network removes the walls. The container is plugged directly into the machine’s own network: no isolation, and two services wanting the same port would clash.

**Docker Volumes vs Bind Mounts**

Both keep data outside the container, so it survives when the container is deleted.

-  A bind mount is “share this exact folder”. You say “container, use /home/jdelattr/data/x”. Simple, but it depends on the host’s folder layout and permissions.

-  A named volume is a storage unit managed by Docker. You give it a name, and Docker decides where and how it’s stored. It’s more portable and independent of the host.

## In the project

| | Option A | Option B | Design choices |
|---|---|---|---|
| **Virtual Machines vs Docker** | A VM emulates a whole machine with its own kernel: strong isolation, but heavy and slow to start. | A container isolates a process and shares the host kernel: light, fast, reproducible. | The VM hosts Docker; the services run as containers. |
| **Secrets vs Environment Variables** | Environment variables are simple, but visible via `docker inspect` and to every process of the container. | Secrets are files mounted in memory under `/run/secrets`, only in the services that need them. | Passwords as secrets; non-sensitive settings (domain, names, emails) in `.env`. |
| **Docker Network vs Host Network** | Host network shares the host's network stack: no isolation, port conflicts. | A dedicated bridge network isolates the containers, resolves them by service name, and only published ports are reachable. | A custom bridge network (`inception`); host network is forbidden by the subject. |
| **Docker Volumes vs Bind Mounts** | A bind mount maps a host path directly: simple, but tied to the host's folder layout and permissions. | A named volume is managed by Docker and independent of the host's layout. | Named volumes whose data is stored in `/home/<login>/data`, so it persists and stays visible on the host. |



# Instructions

### Requirements

- A Linux virtual machine (tested on Debian 13) with **Docker**, the **Docker Compose** plugin, **make** and **git**.
- A user named `jdelattr` (data is stored in `/home/jdelattr/data`).

### Installation

1. Clone the repository and enter it:
   ```bash
   git clone <repository-url> inception && cd inception
   ```
2. Point the domain name to the machine:
   ```bash
   echo "127.0.0.1 jdelattr.42.fr" | sudo tee -a /etc/hosts
   ```
3. Create the configuration file from the template and fill in the values
   (domain, database name and user, WordPress titles, users and emails):
   ```bash
   cp srcs/.env.example srcs/.env
   ```
4. Create the four secret files in `secrets/` (one password per file, no trailing newline):
   ```bash
   mkdir -p secrets
   printf 'your_db_password'       > secrets/db_password.txt
   printf 'your_db_root_password'  > secrets/db_root_password.txt
   printf 'your_wp_admin_password' > secrets/wp_admin_password.txt
   printf 'your_wp_user_password'  > secrets/wp_user_password.txt
   ```
   `srcs/.env` and `secrets/` are listed in `.gitignore` and are never committed.

### Execution

```bash
make
```

This creates the data folders, builds the three images and starts the containers.
The first run takes a few minutes (images are built, then MariaDB and WordPress
initialize themselves).

Then open **https://jdelattr.42.fr** in a browser. The certificate is self-signed,
so the browser shows a warning: accept it to continue.
The administration area is at **https://jdelattr.42.fr/wp-admin**.

### Useful commands

| Command | Effect |
|---|---|
| `make` | Build and start everything |
| `make down` | Stop and remove the containers and the network (data is kept) |
| `make clean` | `down`, plus remove the Docker volumes and the built images (data is kept) |
| `make fclean` | `clean`, plus **delete all data** in `/home/jdelattr/data` |
| `make re` | `fclean` followed by `make` (full reset) |
| `make ps` / `make logs` | Show the containers / their logs |


# Ressources

- Docker documentation: https://docs.docker.com/ (Dockerfile reference, Compose file reference, networks, volumes, secrets)
- NGINX documentation: https://nginx.org/en/docs/ (SSL/TLS settings, FastCGI)
- PHP-FPM: https://www.php.net/manual/en/install.fpm.php
- WP-CLI handbook: https://make.wordpress.org/cli/handbook/
- MariaDB documentation: https://mariadb.com/kb/en/
- GNU Make manual: https://www.gnu.org/software/make/manual/
- OpenSSL `req` manual (self-signed certificate)

- [VM vs Containers: Understanding the Differences](https://www.backblaze.com/blog/vm-vs-containers/)
- [What Are Containers Made From? Kubernetes Story](https://faun.pub/kubernetes-story-linux-namespaces-and-cgroups-what-are-containers-made-from-d544ac9bd622)
- [Understanding Docker Containers: Leveraging Linux Kernels, Namespaces, and Cgroups](https://dev.to/mochafreddo/understanding-docker-containers-leveraging-linux-kernels-namespaces-and-cgroups-4fkk)
- [LXC vs Docker: What’s the Difference?](https://www.docker.com/blog/lxc-vs-docker/#:~:text=Docker%20is%20designed%20for%20developers,the%20operating%20system%20and%20hardware.)
- [The Evolution of Docker Containers](https://www.baeldung.com/linux/docker-containers-evolution)



### Use of AI

- **Understanding concepts:** images, containers, volumes and networks, PID 1, `ENTRYPOINT` vs `CMD`... 
- **Debugging:** reading error messages and logs with it and finding the cause (for example a wrong certificate name, or a script waiting forever for the database).
- **Documentation:** help with the wording and structure of this README, and a diagram of the project.





**Login**: jdelattr
