FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y openssl vsftpd

COPY ./entrypoint.sh /etc/entrypoint.sh

RUN chmod +x /etc/entrypoint.sh

COPY ./vsftpd.conf /etc/vsftpd.conf

ENTRYPOINT ["/etc/entrypoint.sh"]