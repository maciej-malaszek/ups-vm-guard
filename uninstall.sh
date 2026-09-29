#!/bin/bash
set -euo pipefail

[[ $EUID -eq 0 ]] || { 
    echo "Run as root: sudo $0" >&2; exit 1; 
}

systemctl disable --now ups-vm-guard.timer 2>/dev/null || true
systemctl stop nut-host-shutdown.timer 2>/dev/null || true

rm -f /usr/local/sbin/ups-vm-guard 
rm -f /usr/local/sbin/nut-battery-event
rm -f /etc/systemd/system/ups-vm-guard.service 
rm -f /etc/systemd/system/ups-vm-guard.timer 
rm -f /etc/systemd/system/nut-host-shutdown.service 
rm -f /etc/systemd/system/nut-host-shutdown.timer 
rm -f /etc/logrotate.d/ups-vm-guard

systemctl daemon-reload

echo "Removed binaries/units. Preserved /etc/nut/ups-vm-guard.conf and /var/log/nut/."
