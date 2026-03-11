# Ubuntu Server Ethernet Fix — Lenovo IdeaPad 500s-13ISK

## Problem
After a fresh Ubuntu Server install, the Ethernet interface (`enp1s0`) shows `NO-CARRIER` and has no internet access, despite the cable being physically connected.

**Root cause:** The built-in `r8169` kernel driver has a known conflict with the Realtek RTL8111/8168 chip used in this laptop.

---

## Fix

### Step 1 — Reload the Ethernet driver
```bash
sudo modprobe -r r8169 && sudo modprobe r8169
```

### Step 2 — Request an IP address
```bash
sudo dhcpcd enp1s0
```

### Step 3 — Create a Netplan config so this persists on reboot
```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

Paste in the following:
```yaml
network:
  version: 2
  ethernets:
    enp1s0:
      dhcp4: true
```

Save with `Ctrl+O`, then `Ctrl+X` to exit.

### Step 4 — Apply and reboot
```bash
sudo chmod 600 /etc/netplan/00-installer-config.yaml
sudo netplan apply
sudo reboot
```

After rebooting, Ethernet should come up automatically.
