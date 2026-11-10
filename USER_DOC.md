
# User documentation

## What this project provides

A WordPress website, served over HTTPS, made of three services that run in Docker containers:

- **NGINX**: the web server. It is the only entry point (port 443, HTTPS).
- **WordPress**: the website and its administration panel.
- **MariaDB**: the database where WordPress stores its content and users.

## Start and stop

From the project folder:

| Action | Command |
|---|---|
| Start (and build if needed) | `make` |
| Stop (data is kept) | `make down` |
| Start again | `make` |

The first start takes a few minutes. Later starts are much faster.
Warning: `make fclean` and `make re` delete all the website data.

## Access the website

1. The domain name must point to the machine. Add this line once to `/etc/hosts`:
   ```
   127.0.0.1 jdelattr.42.fr
   ```
2. Open **https://jdelattr.42.fr** in a browser.
3. The certificate is self-signed, so the browser shows a warning.
   Accept it to continue (Advanced, then Proceed).

## Access the administration panel

Go to **https://jdelattr.42.fr/wp-admin** and log in with the administrator account.

## Credentials

- **Passwords** are stored in the `secrets/` folder, one file each:
  - `db_password.txt`: database user
  - `db_root_password.txt`: database root
  - `wp_admin_password.txt`: WordPress administrator
  - `wp_user_password.txt`: WordPress second user
- **Names and emails** are in `srcs/.env` (administrator, second user, database name).

These two places are not in git. Do not share them.

To change a WordPress password without losing data, use the administration panel
(Users, then Profile). To change any password in `secrets/`, edit the file and run
`make fclean` then `make`. Warning: this deletes the site and recreates it from scratch.

## Check that everything works

1. List the containers:
   ```bash
   make ps
   ```
   `mariadb`, `wordpress` and `nginx` must all be `Up`.
2. Test the site:
   ```bash
   curl -k -I https://jdelattr.42.fr
   ```
   The answer must start with `HTTP/1.1 200 OK`.
3. If something is wrong, read the logs:
   ```bash
   make logs
   ```
   Right after a start, wait about a minute: WordPress needs the database to be ready.
