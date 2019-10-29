# Docker

## Configuration

- Registry
- IPv6
- Cgroup Driver
- Storage Driver
- log
- Image Download

Config file location: `/etc/docker/daemon.json`

```json
{
  "registry-mirrors": [
    "<REGISTRY1>",
    "<REGISTRY2>"
  ],

  "insecure-registries": [
    "<REGISTRY1>",
    "<REGISTRY2>"
  ],

  "ipv6": false,

  "exec-opts": [
    "native.cgroupdriver=systemd"
  ],

  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],

  "log-level": "warn",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "5"
  },

  "max-concurrent-downloads": 10
}
```
