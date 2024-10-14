# pull bash image
FROM debian:bullseye

# update and upgrade the system
RUN apt-get update && apt-get upgrade -y

# install the required packages
RUN apt-get install -y nginx openssl

# create the ssl directory
RUN mkdir -p /etc/nginx/ssl

# generate the ssl certificate
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=KR/ST=/L=Seoul/O=42/OU=42/CN=jeshin.42.fr/UID=jeshin"

# copy the nginx conf file
COPY ./nginx.conf /etc/nginx/nginx.conf

#create the wordpress directory
RUN mkdir -p /var/www/wordpress

#change the owner of the wordpress directory to www-data:www-data
RUN chown -R www-data:www-data /var/www/wordpress

#define the command to run when the container starts
CMD ["nginx", "-g", "daemon off;"]