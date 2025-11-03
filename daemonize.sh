#!/bin/bash
set -e

# check argument count
if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <username> <command> <logfile> <input>"
    echo "Example: $0 myapp_runner './some-command.sh somearg' /log/my_app/app.log /dev/null"
	# fourth arg is used for input pipes, set to /dev/null for no input
    exit 1
fi

# check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "[!] WARNING: It is recommended to run this script as root."
fi

DIRPATH=`dirname "$0"`

echo "[+] adding user '$1'"
useradd "$1" && {
	echo "[+] user created, initializing home folder"
	mkdir "/home/$1"
	chown $1:$1 "/home/$1"

} || echo "[-] user already exists"


echo "[+] initializing log"
mkdir -p "$(dirname "$3")" && touch "$3"
chown $1:$1 "$3"

echo "[+] starting daemon"
su "$1" -c "nohup \"$DIRPATH/keepalive.sh\" \"$2\" < \"$4\" >> \"$3\" 2>&1 &"
