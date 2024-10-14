# pull base image
FROM debian:bullseye

# update and upgrade
RUN apt-get update && apt-get upgrade -y

# install the required packages
RUN apt-get install -y mariadb-server netcat

# copy file from host to container
COPY ./mdb_conf.sh /mdb_conf.sh

# set permissions to the file
RUN chmod +x /mdb_conf.sh

# define entrypoint command to run when the container starts
ENTRYPOINT ["./mdb_conf.sh"]