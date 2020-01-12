# CentOS - Disable IPv6

## Disable IPv6 in kernel module (requires reboot)

1. Edit /etc/default/grub and add ipv6.disable=1 in line GRUB_CMDLINE_LINUX, e.g.:

   ```bash
   # cat /etc/default/grub
   GRUB_TIMEOUT=5
   GRUB_DEFAULT=saved
   GRUB_DISABLE_SUBMENU=true
   GRUB_TERMINAL_OUTPUT="console"
   GRUB_CMDLINE_LINUX="ipv6.disable=1 crashkernel=auto rhgb quiet"
   GRUB_DISABLE_RECOVERY="true"
   ```

2. Regenerate a GRUB configuration file and overwrite existing one:

   ```bash
   # grub2-mkconfig -o /boot/grub2/grub.cfg
   ```

3. Restart system and verify no line “inet6” in “ip addr show” command output.

   ```bash
   # shutdown -r now

   # ip addr show | grep net6
   ```

## Disable IPv6 using sysctl settings (no reboot required)

1. Append below lines in /etc/sysctl.conf:

   ```bash
   net.ipv6.conf.all.disable_ipv6 = 1
   net.ipv6.conf.default.disable_ipv6 = 1
   ```

2. To make the settings affective, execute:

   ```bash
   # sysctl -p
   ```
