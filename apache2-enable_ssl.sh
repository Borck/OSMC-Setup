
if [ ! -f /etc/apache2/ssl/apache.crt ]; then
	sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt
fi

sudo sed -i 's!SSLCertificateFile.*/.*$!SSLCertificateFile /etc/apache2/ssl/apache.crt!g' /etc/apache2/sites-available/default-ssl.conf
sudo sed -i 's!SSLCertificateKeyFile.*/.*$!SSLCertificateKeyFile /etc/apache2/ssl/apache.key!g' /etc/apache2/sites-available/default-ssl.conf

sudo a2enmod ssl
sudo a2ensite default-ssl.conf

sudo service apache2 reload
