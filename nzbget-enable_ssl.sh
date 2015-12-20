if [ "$(id -u)" != "0" ]; then
	echo "You don't have sufficient privileges to run this script. Restart with root privileges."
	exit 1
fi

InstallPath='/opt/nzbget'

if [ ! -f /etc/apache2/ssl/apache.crt ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt
fi

# enable https (ssl) access over port 6791
sed -i "/SecureCert=/c\SecureCert=/etc/apache2/ssl/apache.crt" ${InstallPath}/nzbget.conf
sed -i "/SecureKey=/c\SecureKey=/etc/apache2/ssl/apache.key" ${InstallPath}/nzbget.conf
sed -i "/SecureControl=/c\SecureControl=yes" ${InstallPath}/nzbget.conf

