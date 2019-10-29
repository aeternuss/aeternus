# Jumpserver

## Architecture

- [web proxy (nginx with lua)](https://github.com/aeternuss/jms_nginx)
- [core component (jumpserver core)](https://github.com/aeternuss/jms_core)
- [coco component (jumpserver terminal)](https://www.github.com/wojiushixiaobai/coco)
- [guacamole component (client-less remote desktop gateway)](https://www.github.com/wojiushixiaobai/docker-guacamole)
- MySQL
- Redis

## Configuration

### Sudo Permissions

```bash
ALL,!/bin/bash,!/bin/tcsh,!/bin/su,!/usr/bin/passwd,!/usr/bin/passwd root,!/bin/vim /etc/sudoers,!/usr/bin/vim /etc/sudoers,!/usr/sbin/visudo,!/usr/bin/sudo -i,!/bin/bi /etc/ssh/*,!/bin/chmod 777 /etc/*,!/bin/chmod 777 *,!/bin/chmod 777,!/bin/chmod -R 777 *,!/bin/rm /*,!/bin/rm /,!/bin/rm -rf /,!/bin/rm -rf /*,!/bin/rm /etc,!/bin/rm -r /etc,!/bin/rm -rf /etc,!/bin/rm /etc/*,!/bin/rm -r /etc/*,!/bin/rm -rf /etc/*,!/bin/rm /root,!/bin/rm -r /root,!/bin/rm -rf /root,!/bin/rm /root/*,!/bin/rm -r /root/*,!/bin/rm -rf /root/*,!/bin/rm /bin,!/bin/rm -r /bin,!/bin/rm -rf /bin,!/bin/rm /bin/*,!/bin/rm -r /bin/*,!/bin/rm -rf /bin/*
```
