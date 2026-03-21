#!/bin/bash

/etc/init.d/nordvpn start
sleep 5

# Suppress the analytics prompt
nordvpn set analytics off

# Enable kill switch and LAN discovery before any tunnel is established
nordvpn set firewall on

# Allow inbound traffic coming from over the LAN through the firewall
nordvpn set lan-discovery on

# Login if not already authenticated
if nordvpn account 2>&1 | grep -q "not logged in"; then
    nordvpn login --token "$NORDVPN_TOKEN"
fi

nordvpn connect --group p2p
nordvpn set meshnet on
nordvpn meshnet set nickname "homelab-container"

# Monitor nordvpnd and restart if it crashes
fail_count=0
max_failures=3
while true; do
    sleep 10
    if ! nordvpn status &>/dev/null; then
        fail_count=$((fail_count + 1))
        echo "nordvpnd check failed (attempt $fail_count/$max_failures), restarting..."
        if [ "$fail_count" -ge "$max_failures" ]; then
            echo "nordvpnd failed $max_failures consecutive checks, exiting"
            exit 1
        fi
        /etc/init.d/nordvpn restart
        sleep 5
        nordvpn connect || true
    else
        fail_count=0
    fi
done
