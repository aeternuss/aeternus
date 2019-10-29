# CentOS - Reset Root Password

The way to reset the root password on centos7 when you forgot the root
user password.

## Boot into single user mode

- In the boot grub menu select option to edit.
- Go to the kernel line and add `rd.break enforcing=0`.

## Reset password

```bash
mount -o remount,rw /sysroot
chroot /sysroot
passwd root
exit
exit

<login>

restorecon /etc/shadow
reboot
```
