#!/bin/sh -

#src: http://www.htpcguides.com/install-latest-nzbget-on-raspberry-pi-2-and-b-raspbian/

InstallPath='/opt/nzbget'
InstallUser=$(id -nu 1000) #username of uid 1000 (i.e. pi or osmc)
InstallGroup=$(id -ng 1000) #group name of uid 1000 (i.e. pi or osmc)

echo $USER
if [ "$USER" != "root" ]; then
	echo 'Installation requires to run under user "root".'
  exit 1
fi

wget -N http://nzbget.net/download/nzbget-latest-bin-linux.run -O ~/nzbget-latest-bin-linux.run

if [ "$(ls -A $InstallPath)" ]; then
  echo "There is an already existing installation of nzbget. Uninstall it?"
  echo "Yes(Y) Abort(A)"
  read answer
  if [ "$answer" != "Y" ]; then
    echo "Installation aborted"
    exit 1
  fi
  
  service nzbget stop
  
  rm -rf $InstallPath
  #rm /etc/init.d/nzbget #will be overwritten
  sed -i '\~@reboot ${InstallPath}/nzbget -D~d' /var/spool/cron/crontabs/$InstallUser
fi

sh ~/nzbget-latest-bin-linux.run --destdir $InstallPath
rm ~/nzbget-latest-bin-linux.run

sed -i "/DaemonUsername=/c\DaemonUsername=$InstallUser" ${InstallPath}/nzbget.conf
#sed -i "/UMask=/c\UMask=0022" ${InstallPath}/nzbget.conf #0002

# set authorized IPs
# caution with 127.0.0.1 or localhost in combination with Apache2 proxy
sed -i "/AutorizedIP=/c\AutorizedIP=" ${InstallPath}/nzbget.conf

#log infos only in log file
sed -i "/InfoTarget=/c\InfoTarget=Log" ${InstallPath}/nzbget.conf

#start daemon
${InstallPath}/nzbget -D

#register daemon to start on boot time

cat <<EOF > /etc/init.d/nzbget
#!/bin/sh
### BEGIN INIT INFO
# Provides:          nzbget
# Required-Start:    \$local_fs \$network \$remote_fs
# Required-Stop:     \$local_fs \$network \$remote_fs
# Should-Start:      \$NetworkManager
# Should-Stop:       \$NetworkManager
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts instance of NZBGet
# Description:       starts instance of NZBGet using start-stop-daemon
### END INIT INFO
# Source init functions
. /lib/lsb/init-functions
# Start/stop the NZBget daemon.
#
case "\$1" in
start)   echo -n "Start services: NZBget"
${InstallPath}/nzbget -D
;;
stop)   echo -n "Stop services: NZBget"
${InstallPath}/nzbget -Q
;;
restart)
\$0 stop
\$0 start
;;
*)   echo "Usage: \$0 start|stop|restart"
exit 1
;;
esac
exit 0
EOF

chmod +x /etc/init.d/nzbget
/usr/sbin/update-rc.d nzbget defaults
service nzbget start
#systemctl daemon-reload

# Add an NZBGet cronjob to ensure it starts on boot
#crontab -u $InstallUser -l | { cat; echo "@reboot ${InstallPath}/nzbget -D"; } | crontab -u $InstallUser -

#create download folders and update permissions
DlPath=${InstallPath}/downloads
mkdir -p ${DlPath}/{intermediate,queue,nzb,tmp}
chown -R $InstallUser:$InstallGroup $InstallPath
chmod -R 755 ${DlPath}


