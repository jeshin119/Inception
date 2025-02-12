## Subject

`Inception` project is about setting up and running a small infrastructure of services in order to have a functional `wordpress` website, with `nginx` as web-server and a database relying on `MariaDB` service. 
As it is forbidden to pull and use ready-made `docker images` from `DockerHub` for these services. The image for each of the given services (`nginx`, `wordpress`, `MariaDB`) has to be build from a `Dockerfile` solely based on the `image` of either `Alpine` or `Debian` (penultimate stable version). 
It is mandatory to be using `docker compose`, through a `Makefile` to coordinate the services, while building them and running them, and for maintaing a user-defined network between these services.
It is also mandatory to use an `.env` file for `docker compose`.
### Services

• A Docker container that contains NGINX with TLSv1.2 or TLSv1.3 only.
• A Docker container that contains WordPress + php-fpm (it must be installed and
configured) only without nginx.
• A Docker container that contains MariaDB only without nginx.

### Volumes and Network

• A volume that contains your WordPress database.
• A second volume that contains your WordPress website files.

• A docker-network that establishes the connection between your containers.
```
Nginx     <-- port 443 TLS --> web browsing 
Nginx     <-- port 9000    --> Wordpress
Wordpress <-- port 3306    --> MariaDB
```

### Forbidden
- Pulling `DockerHub` images other than `alpine` or `debian`.
- In `docker-compose.yml` : `network: host` or `--link` or `links:`.
