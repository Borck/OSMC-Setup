if [ "$(id -u)" != "0" ]; then
  echo "You don't have sufficient privileges to run this script. Restart with root privileges."
  exit 1
fi

if [ ! -f /etc/apache2/ssl/apache.crt ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt
fi

sed -i 's!SSLCertificateFile.*/.*$!SSLCertificateFile /etc/apache2/ssl/apache.crt!g' /etc/apache2/sites-available/default-ssl.conf
sed -i 's!SSLCertificateKeyFile.*/.*$!SSLCertificateKeyFile /etc/apache2/ssl/apache.key!g' /etc/apache2/sites-available/default-ssl.conf

a2enmod ssl
a2ensite default-ssl.conf

service apache2 reload
