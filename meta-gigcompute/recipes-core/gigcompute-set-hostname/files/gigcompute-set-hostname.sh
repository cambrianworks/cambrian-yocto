#!/bin/sh

if [ -f /proc/device-tree/serial-number ]; then
    SERIAL=$(cat /proc/device-tree/serial-number | tr -d '\0')
else
    echo "No serial-number node"
    exit 1
fi

if [ -z "$SERIAL" ]; then
    echo "serial-number returned empty"
    exit 1
fi

SUFFIX=$(echo -n "$SERIAL" | tail -c 4)
HOSTNAME="gc-${SUFFIX}"

CURRENT_HOSTNAME=$(hostname)

if [ "$CURRENT_HOSTNAME" != "$HOSTNAME" ]; then
    echo "Hostname mismatch. Changing from '$CURRENT_HOSTNAME' to '$HOSTNAME'"
    hostname "$HOSTNAME"
    echo "$HOSTNAME" > /etc/hostname
    sed -i "s/127.0.1.1.*/127.0.1.1\t$HOSTNAME/g" /etc/hosts
    echo "Hostname updated successfully."
fi

exit 0
