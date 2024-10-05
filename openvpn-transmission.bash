#!/bin/bash


start() {
	if [ ! -f /usr/bin/whois ] || [ ! -f /usr/bin/transmission-daemon ] || [ ! -f /usr/sbin/openvpn ]; then
		clear
		echo && echo -e '\e[91m' "*************	MISSING DEPENDENCIES *************" && echo
		echo && echo && echo -e '\e[95m'"Starting install dependencies..." && echo && echo -e '\e[0m' && sleep 1
		sudo apt update && sudo apt upgrade -y && sudo apt install whois openvpn transmission-daemon transmission-common -y
		systemctl disable openvpn && systemctl disable transmission-daemon
	fi

	[ -x openvpn ] || systemctl stop openvpn
	[ -x transmission-daemon ] || systemctl stop transmission-daemon
	killall openvpn >> /dev/null 2>&1
	sleep 2
	killall -9 openvpn >> /dev/null 2>&1

	CLIENT=`ls /etc/openvpn/client | shuf -n 1`
	openvpn --config /etc/openvpn/client/$CLIENT >> /dev/null 2>&1 &

	clear
	echo && echo -e '\e[91m'"Starting OpenVPN and transmission-daemon"
	echo -e '\e[33m'"Connecting with $CLIENT"
	echo -e '\e[0m'"Please wait 30 seconds..." && echo
	sleep 26

	systemctl start transmission-daemon
	sleep 3
	CHECKTUN=`ip -o -f inet addr show | awk '/scope global/' | grep tun0 | awk '{print $2}'`

	$0 status &

	while [[ $CHECKTUN = tun0 ]]; do
		sleep 7
		CHECKTUN=`ip -o -f inet addr show | awk '/scope global/' | grep tun0 | awk '{print $2}'`
		sleep 8
	done

	systemctl stop transmission-daemon
}

stop() {
	[ -x openvpn ] || systemctl stop openvpn
	[ -x transmission-daemon ] || systemctl stop transmission-daemon
	killall openvpn >> /dev/null 2>&1
	sleep 2
	killall -9 openvpn >> /dev/null 2>&1
}

status() {
	clear
	PRESS="             ***** Press ENTER to continue *****"
	EXTIP=$(curl -s icanhazip.com)
	COUNTRY=$(whois $EXTIP | grep -m 1 country: | awk '{print $2}')
	CHECKTUN=`ip -o -f inet addr show | awk '/scope global/' | grep tun0 | awk '{print $2}'`
	if [[ $CHECKTUN = tun0 ]]; then
		echo && echo -e '\e[32m'"You are connected with OpenVPN: your IP is $EXTIP $COUNTRY"
		echo "$PRESS" && echo -e '\e[0m'
	else
		echo && echo -e '\e[91m'"You are NOT connected with OpenVPN: your IP is $EXTIP $COUNTRY"
		[ -x transmission-daemon ] || systemctl stop transmission-daemon
		echo "$PRESS" && echo -e '\e[0m'
	fi
}

help() {
	clear
	echo && echo "Welcome to the OpenVPN and transmission-daemon initialization script."
	echo && echo
	echo "To ensure optimal performance, please follow these steps:"
	echo "1) Place all OpenVPN configuration files (.ovpn and .conf) in the /etc/openvpn/client directory."
	echo "2) Verify that the path to the user-pass file is specified after 'auth-user-pass' in the configuration file."
	echo "3) Set appropriate permissions for the user-pass file: chmod 600 /PATH_OF/user-pass"
	echo "4) Make the script executable: chmod +x openvpn-transmission"
	echo "5) Run the script: $0 start"
	echo && echo "The script will randomly select a server from all available .ovpn and .conf files each time it runs."
	echo "If OpenVPN crashes or the server becomes unavailable, the script will stop the transmission-daemon service."
	echo && echo "Usage: $0 {start|stop|status|help}"
	echo && echo
}


case "$1" in
	start)
	start &
	;;
stop)
	stop
	;;
	status)
	status &
	;;
help)
	help
	;;
	*)
	echo "Usage: $0 {start|stop|status|help}"
esac

exit 0
