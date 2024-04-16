#!/bin/bash


start() {
	if [ ! -f /usr/bin/whois ] || [ ! -f /usr/bin/transmission-daemon ] || [ ! -f /usr/bin/wg-quick ]; then
		clear
		echo && echo -e '\e[91m' "*************	MISSING DEPENDENCIES *************" && echo
		echo && echo && echo -e '\e[95m'"Starting install dependencies..." && echo && echo -e '\e[0m' && sleep 1
		sudo apt update && sudo apt upgrade -y && sudo apt install whois wireguard-tools transmission-daemon transmission-common -y
		systemctl disable wg-quick@wg0 && systemctl disable transmission-daemon
	fi

	[ -x openvpn ] || systemctl stop wg-quick@wg0
	[ -x transmission-daemon ] || systemctl stop transmission-daemon
	killall wg-quick@wg0 >> /dev/null 2>&1
	sleep 2
	killall -9 wg-quick@wg0 >> /dev/null 2>&1

	CLIENT=`cat /etc/wireguard/wg0.conf | grep Endpoint | awk '{print $3}'`
	systemctl start wg-quick@wg0 >> /dev/null 2>&1

	clear
	echo && echo -e '\e[91m'"Starting Wireguard and transmission-daemon"
	echo -e '\e[33m'"Connecting with $CLIENT"
	echo -e '\e[0m'"Please wait 30 seconds..." && echo
	sleep 26

	systemctl start transmission-daemon
	sleep 3
	CHECKWG=`ip -o -f inet addr show | awk '/scope global/' | grep wg0 | awk '{print $2}'`

	$0 status &

	while [[ $CHECKWG = wg0 ]]; do
		sleep 7
		CHECKWG=`ip -o -f inet addr show | awk '/scope global/' | grep wg0 | awk '{print $2}'`
		sleep 8
	done

	systemctl stop transmission-daemon
}

stop() {
	[ -x wg-quick ] || systemctl stop wg-quick@wg0
	[ -x transmission-daemon ] || systemctl stop transmission-daemon
	killall wg-quick@wg0 >> /dev/null 2>&1
	sleep 2
	killall -9 wg-quick@wg0 >> /dev/null 2>&1
}

status() {
	clear
	PRESS="             ***** Press ENTER to continue *****"
	EXTIP=$(curl -s icanhazip.com)
	COUNTRY=$(whois $EXTIP | grep -m 1 country: | awk '{print $2}')
	CHECKWG=`ip -o -f inet addr show | awk '/scope global/' | grep wg0 | awk '{print $2}'`
	if [[ $CHECKWG = wg0 ]]; then
		echo && echo -e '\e[32m'"You are connected with Wireguard: your IP is $EXTIP $COUNTRY"
		echo "$PRESS" && echo -e '\e[0m'
	else
		echo && echo -e '\e[91m'"You are NOT connected with Wireguard: your IP is $EXTIP $COUNTRY"
		[ -x transmission-daemon ] || systemctl stop transmission-daemon
		echo "$PRESS" && echo -e '\e[0m'
	fi
}

help() {
	clear
	echo && echo "This script starts Wireguard and transmission-daemon."
	echo && echo "In order to work properly you need:"
	echo "1) Put configuration file of Wireguard (.conf) in /etc/wireguard"
	echo "2) chmod +x wireguard-transmission"
	echo "3) $0 start"
	echo  && echo "If Wireguard crashes or server is not available, script stops transmission-daemon service."
	echo "You can check status with: $0 status"
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
