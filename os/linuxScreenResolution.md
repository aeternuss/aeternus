# Linux - Screen Resolution

## Changing Screen Resolution Using vga Kernel Parameter

It will work on CentOS 7 and older Linux distributions very well.

The vga kernel boot parameter accepts a code which represents the screen resolution.

The easy way to find the codes is to use `vga=ask` boot parameter when you boot into your operating system.

First, open GRUB configuration file `/etc/default/grub`,
add `vga=0xXXX` to the end of the `GRUB_CMDLINE_LINUX`:

```bash
GRUB_CMDLINE_LINUX="... vga=0xXXX"
```

Then, update the GRUB configuration files with the following command:

```bash
grub2-mkconfig -o $(sudo readlink -f /etc/grub2.cfg)
```

## Changing Screen Resolution Using gfxpayload

On newer version of GRUB, the screen resolution is set using gfxpayload.

In the GRUB command prompt, find the supported screen resolution on your computer, run the following command:

```bash
grub> vbeinfo
```

First, add the line to GRUB configuration file `/etc/default/grub`:

```bash
GRUB_GFXMODE=<Width>x<Height>x<Depth>
GRUB_GFXPAYLOAD_LINUX=keep
```

Then, update the GRUB configuration files with the following command:

```bash
grub2-mkconfig -o $(sudo readlink -f /etc/grub2.cfg)
```
