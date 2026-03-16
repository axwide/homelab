#!/bin/bash

/etc/init.d/nordvpn start
sleep 5

# Suppress the analytics prompt
nordvpn set analytics off

# Login if not already authenticated
if nordvpn account 2>&1 | grep -q "not logged in"; then
    nordvpn login --token "$NORDVPN_TOKEN"
fi

nordvpn connect --group p2p
nordvpn set meshnet on
nordvpn meshnet set nickname "homelab-container"
nordvpn set firewall on

# Allow inbound traffic coming from over the LAN through the firewall
nordvpn set lan-discovery on

# Monitor nordvpnd and restart if it crashes
while true; do
    sleep 10
    if ! nordvpn status &>/dev/null; then
        echo "nordvpnd died, restarting..."
        /etc/init.d/nordvpn restart
        sleep 5
        nordvpn connect || true
    fi
done
