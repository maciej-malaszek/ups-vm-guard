#!/bin/bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

[[ $EUID -eq 0 ]] || { 
    echo "Run as root: sudo $0" >&2
    exit 1
}
for c in systemctl upsc virsh; do 
    command -v "$c" >/dev/null || { 
        echo "ERROR: required command not found: $c" >&2
        exit 1
    }; 
done

install -d -m 0755 /usr/local/sbin /etc/nut /etc/systemd/system /etc/logrotate.d
install -d -m 0750 /var/log/nut /run/nut
install -m 0750 "$ROOT/bin/ups-vm-guard" /usr/local/sbin/ups-vm-guard
install -m 0750 "$ROOT/bin/nut-battery-event" /usr/local/sbin/nut-battery-event

for f in "$ROOT"/systemd/*.service "$ROOT"/systemd/*.timer; do 
    install -m 0644 "$f" /etc/systemd/system/
done

install -m 0644 "$ROOT/logrotate/ups-vm-guard" /etc/logrotate.d/ups-vm-guard
if [[ ! -e /etc/nut/ups-vm-guard.conf ]]; then 
    install -m 0640 "$ROOT/config/ups-vm-guard.conf.example" /etc/nut/ups-vm-guard.conf
fi

if getent group nut >/dev/null; then 
    chown root:nut /var/log/nut
fi
systemctl daemon-reload
systemctl enable --now ups-vm-guard.timer

echo "Installed. Edit /etc/nut/ups-vm-guard.conf, then configure NOTIFYCMD in /etc/ups/upsmon.conf."
