# UPS VM Guard 1.0.0

Systemd-based battery protection for Linux hosts running NUT and libvirt.

Default policy:

- AC online: cancel pending host shutdown
- <=40%: shut down running VMs gracefully
- after 120s: force-destroy remaining VMs
- <=25%: schedule host poweroff after 30s
- AC restored below 30%: keep VMs stopped
- AC restored at/above 30%: restart only VMs saved as running before protection, and only while libvirt autostart remains enabled

## Install

```bash
sudo ./install.sh
```

Edit:

```bash
sudoedit /etc/nut/ups-vm-guard.conf
```

Find the UPS name with `upsc -l` and set `UPS_NAME`.

Configure `/etc/ups/upsmon.conf`:

```ini
NOTIFYCMD "/usr/local/sbin/nut-battery-event"
NOTIFYFLAG ONLINE SYSLOG+EXEC
NOTIFYFLAG ONBATT SYSLOG+EXEC
NOTIFYFLAG LOWBATT SYSLOG+EXEC
NOTIFYFLAG FSD SYSLOG+EXEC
NOTIFYFLAG COMMOK SYSLOG+EXEC
NOTIFYFLAG COMMBAD SYSLOG+EXEC
```

Restart the NUT monitor service after changing `upsmon.conf`.

## Configuration changes

Changing `/etc/nut/ups-vm-guard.conf` requires no `daemon-reload`; it is read on every invocation. Run immediately with:

```bash
sudo systemctl start ups-vm-guard.service
```

`daemon-reload` is only needed after changing systemd unit files.

## Monitoring

```bash
systemctl status ups-vm-guard.timer
systemctl list-timers ups-vm-guard.timer
journalctl -u ups-vm-guard.service
```

Logs are daily files under `/var/log/nut/` and are retained/compressed by logrotate.

## Safety / SELinux

The package installs no SELinux policy and does not modify SELinux. The NUT event helper only asks systemd to start the manager; the manager itself runs as the system service and performs libvirt operations. This keeps the privileged operations out of the NUT monitor process domain.

Keep NUT's normal `SHUTDOWNCMD` configured as an independent last-resort emergency mechanism.

## Uninstall

```bash
sudo ./uninstall.sh
```

Configuration and logs are deliberately preserved.
