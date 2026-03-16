#!/bin/bash

/etc/init.d/nordvpn start
sleep 5

# Suppress the analytics prompt
nordvpn set analytics off

# Login if not already authenticated
if nordvpn account 2>&1 | grep -q "not logged in"; then
    nordvpn login --token "$NORDVPN_TOKEN"
fi

nordvpn connect
nordvpn set meshnet on
nordvpn meshnet set nickname "homelab-container"

# Keep container alive
tail -f /dev/null
