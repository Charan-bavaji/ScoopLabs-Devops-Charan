# WordPress + MySQL with Docker Compose

This project uses a single `docker-compose.yml` file to orchestrate a two-container stack:
- **db** — MySQL 5.7 database (backend, stateful)
- **wordpress** — WordPress latest (frontend, web app)

Both containers sit on a custom isolated bridge network (`wp-network`) so they can talk to each other by service name, and both use named volumes so data survives container restarts or crashes.

## How the `docker-compose.yml` Works

```yaml
version: '3.8'

services:
  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppassword
    volumes:
      - db_data:/var/lib/mysql
    networks:
      - wp-network

  wordpress:
    image: wordpress:latest
    depends_on:
      - db
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppassword
    ports:
      - "8080:80"
    volumes:
      - wp_data:/var/www/html
    networks:
      - wp-network

volumes:
  db_data:
  wp_data:

networks:
  wp-network:
    driver: bridge
```

**db service** — runs MySQL, sets up the initial database/user via environment variables, and stores its data files outside the container using the `db_data` volume.

**wordpress service** — runs WordPress, waits for `db` to start (`depends_on`), connects to it using the environment variables (`WORDPRESS_DB_HOST`, etc.), exposes the site on host port 8080, and stores uploaded files/themes/plugins in the `wp_data` volume.

**networks** — a custom bridge network (`wp-network`) is declared at the bottom and attached to both services, isolating this stack from other Docker projects on the same machine.

**volumes** — two named volumes (`db_data`, `wp_data`) are declared at the bottom so Docker manages their storage on the host, independent of container lifecycle.

## How the Two Containers Connect

Docker Compose automatically creates a private DNS on the `wp-network` bridge network. Any service can reach another service using its **service name as a hostname**. That's why `WORDPRESS_DB_HOST` is set to `db:3306` instead of an IP address — `db` resolves to the MySQL container's internal IP automatically. No manual IP configuration and no host port needs to be exposed for this internal communication; only WordPress's port 8080 is published externally so it's reachable from the browser.

## Why `depends_on` Matters

The `depends_on` directive tells Docker Compose to **start the `db` container before the `wordpress` container**. Without it, Compose would start both containers at roughly the same time, and WordPress could try to connect to MySQL before MySQL is even listening for connections — causing WordPress to fail its database connection check and throw an "Error establishing a database connection" message.

It's worth noting that `depends_on` only controls **start order**, not **readiness**. MySQL's container process can start before the MySQL server inside it is actually ready to accept connections. In this simple two-service setup, WordPress's own retry logic on the PHP side is usually enough to handle the short delay. For production-grade setups, a `healthcheck` combined with `condition: service_healthy` is used to make Compose wait until MySQL is truly ready, not just "started."

## Why Persistent Volumes Are Critical for Databases

Containers are meant to be **disposable** — they can be stopped, removed, rebuilt, or replaced at any time (for updates, scaling, or recovery from a crash). By default, anything written inside a container's filesystem is lost the moment that container is deleted.

For a database, that's a serious problem: all blog posts, users, comments, and settings live inside MySQL's data directory (`/var/lib/mysql`). If that directory only existed inside the container, deleting or recreating the `db` container (which happens often — updates, restarts, redeploys) would **permanently wipe the entire WordPress site**.

By mapping a **named volume** (`db_data`) to `/var/lib/mysql`, the actual database files live on the host machine, managed by Docker, completely independent of the container's lifecycle. This means:
- The `db` container can be stopped, removed, and recreated freely.
- The next time it starts and mounts `db_data`, all the data is exactly as it was.
- The blog's content survives crashes, upgrades, and redeployments.

The same reasoning applies to the `wp_data` volume mapped to `/var/www/html` — it preserves uploaded media, themes, and plugins independently of the WordPress container.

## Verification

Ran `docker-compose up -d`, confirmed both containers were up with `docker ps`, and confirmed the WordPress installation screen loaded at `http://localhost:8080`.

### `docker ps` output — both containers running
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/a3e5f14e-35b8-4747-8d58-a89a16422ee2" />


### WordPress installation screen at localhost:8080
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/34fdfd83-e2b9-462d-b3d3-26f9cd50c5b2" />


## Environment Variables Used

| Variable | Service | Purpose |
|---|---|---|
| `MYSQL_ROOT_PASSWORD` | db | Root password for MySQL admin access |
| `MYSQL_DATABASE` | db | Database created on first startup |
| `MYSQL_USER` / `MYSQL_PASSWORD` | db | Non-root user WordPress connects as |
| `WORDPRESS_DB_HOST` | wordpress | Points to `db:3306` (service name + port) |
| `WORDPRESS_DB_NAME` | wordpress | Must match `MYSQL_DATABASE` |
| `WORDPRESS_DB_USER` / `WORDPRESS_DB_PASSWORD` | wordpress | Must match MySQL's user credentials |

> **Note:** The passwords above are for local/demo use only. In a real deployment, these would be handled via Docker secrets or a `.env` file rather than hardcoded.
