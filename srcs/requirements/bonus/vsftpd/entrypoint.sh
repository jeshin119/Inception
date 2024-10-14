#!/bin/bash

mkdir -p /var/run/vsftpd/empty
chown root:root /var/run/vsftpd/empty
chmod 755 /var/run/vsftpd/empty

adduser $FTP_U_NAME --disabled-password
echo "$FTP_U_NAME:$FTP_U_PASS" | /usr/sbin/chpasswd &> /dev/null
chmod a-w /home/$FTP_U_NAME
chown -R $FTP_U_NAME:$FTP_U_NAME /var/www/wordpress

echo "FTP server start"

/usr/sbin/vsftpd /etc/vsftpd.conf