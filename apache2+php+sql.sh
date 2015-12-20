if [ "$(id -u)" != "0" ]; then
	echo "You don't have sufficient privileges to run this script. Restart with root privileges."
	exit 1
fi

apt-get -y install mariadb-server mariadb-client apache2 php5 libapache2-mod-php5
apt-cache search php5
apt-get -y install php5-mysqlnd php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-apcu
service apache2 restart
