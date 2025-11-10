#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Backup the original crontab
cp /etc/crontab /etc/crontab.bak

add_cron_line() {
    local line="$1"
    if ! grep -Fxq "$line" /etc/crontab; then
        echo "$line" >> /etc/crontab
        echo "Added: $line"
    else
        echo "Skipped (already exists): $line"
    fi
}

clone_if_missing() {
    local REPO_URL="$1"
    local DIR_NAME
    DIR_NAME=$(basename "$REPO_URL")

    if [ ! -d "$DIR_NAME" ]; then
        echo "Cloning $REPO_URL..."
        git clone "$REPO_URL"
    else
        echo "Repository '$DIR_NAME' already exists."
    fi
}

clone_if_missing "https://github.com/mirror12k/deployable-invidious-package"
clone_if_missing "https://github.com/mirror12k/deployable-materialious-package"
clone_if_missing "https://github.com/mirror12k/deployable-jellyfin-package"
clone_if_missing "https://github.com/mirror12k/deployable-caddy-proxy-package"
clone_if_missing "https://github.com/mirror12k/deployable-shinobi-package"
clone_if_missing "https://github.com/mirror12k/deployable-n8n-package"

# Initialize empty envfiles for all packages
echo "Initializing envfiles..."
for package in invidious materialious jellyfin caddy shinobi n8n; do
    envfile=".envfile.$package"
    if [ ! -f "$envfile" ]; then
        touch "$envfile"
        echo "Created: $envfile"
    else
        echo "Already exists: $envfile"
    fi
done

add_cron_line "0 0	* * *	root	/sbin/reboot"
add_cron_line "@reboot root $PWD/server-start.sh"

echo "Install complete."
