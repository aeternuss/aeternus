# Cloud Init

Cloud-init is the industry standard multi-distribution method for cross-platform cloud instance initialization.

Cloud instances initialized from a disk image and instance data:

- Cloud matedata
- User data (optional)
- Vendor data (optional)

Cloud-init will identify the cloud it is running on during boot, read any provided metadata from the cloud and initialize the system accordingly. This may invole setting up the network and storage devices to configuring SSH access key and many other aspects of a system. Later on the cloud-init will also parse and process any optional user or vendor data that was passed to the instance.

## Boot Stages

In order to be able to provide the functionality that it does, cloud-init must be integrated into the boot in fairly controlled way. There are five stages to boot:

- Generator
- Local
- Network
- Config
- Final

### Generator

When booting under systemd, a generator will run that determines if cloud-init.target should be included in the boot goals. By default, this genertor will enable cloud-nit. It will not enable cloud-init if either:

- The file `/etc/cloud/cloud-init.disabled` exists
- The kernel command line as found in `/proc/cmdline` contains `cloud-init=disabled`

### Local

| Menu | Description |
| --- | --- |
| systemd service | cloud-init-local.service |
| runs | as soon as possible with `/` mounted read-write |
| blocks | as much of boot as possible, must block network |
| modules | none |

The purpose of the local stage is to:

- locate `local` data sources
- apply networking configuration to the system

The network configuration can come from:

- datasource: cloud provided network configuration via metadata
- fallback: cloud-init’s fallback networking consists of rendering the equivalent to “dhcp on eth0”
- none: network configuration can be disabled by writing the file `/etc/cloud/cloud.cfg` with the content: network: `{config: disabled}`

### Network

| Menu | Description |
| --- | --- |
| systemd.service | cloud-init.service |
| runs | after local stage and configured networking is up |
| blocks | as much of remaining boot as possible |
| modules | cloud_init_modules in `/etc/cloud/cloud.cfg` |

This stage requires all configured networking to be online, as it will fully process any user-data that is found.

- retrieve any `#include` or `#include-once` including http
- decomporess any compressed content
- run any part-handler found

This stage runs the `disk_setup` and `mounts` modules which may partition and format disks and configure mount points.

A part-handler will run at this stage, as will boot-hooks including cloud-config `bootcmd`.

### Config

| Menu | Description |
| ---- | --- |
| systemd service | cloud-config.service |
| runs | after network |
| blocks | nothing |
| modules | cloud_config_modules in `/etc/cloud/cloud.cfg` |

This stage runs config modules only. Modules that do not really have an effect on other stages of boot are run here.

### Final

| Menu | Description |
| ---- | --- |
| systemd service | cloud-final.service |
| runs | as final part of boot (traditional “rc.local”) |
| blocks | nothing |
| modules | cloud_final_modules in `/etc/cloud/cloud.cfg` |

This stage runs as late in boot as possible. Any scripts that a user is accustomed to running after logging into a system should run correctly here.

- package installations
- configuration management plugins
- user-scripts (including `runcmd`)

## Files

Cloud-init config is provided in two places:

/etc/cloud/cloud.cfg
/etc/cloud/cloud.cfg.d/*.cfg

Inside the /var/lib/cloud/ directory there are two important subdirectories:

- instance

  The /var/lib/cloud/instance directory is a symbolic link that points to the most recenlty used instance-id directory. This folder contains the information cloud-init received from datasources, including vendor and user data.

- data

  The /var/lib/cloud/data directory contain information related to the previous boot:

  - instance-id: id of the instance as discovered by cloud-init.
  - result.json: json file will show both the datasource used to setup the instance, and if any errors occured
  - status.json: json file shows the datasource used and a break down of all four modules if any errors occured and the start and stop times.

## User-Data Formats

User data that will be acted upon by cloud-init must be in one of the following types.

### Gzip Compressed Content

Content found to be gzip compressed will be uncompressed. The uncompressed data will then be used as if it were not compressed. This is typically useful because user-data is limited to ~16384 [1] bytes.

### Mime Multi Part Archive

This list of rules is applied to each part of this multi-part file. Using a mime-multi part file, the user can specify more than one type of data.

- text/cloud-boothook
- text/cloud-config
- text/cloud-config-archive
- text/jinja2
- text/part-handler
- text/upstart-job
- text/x-include-once-url
- text/x-include-url
- text/x-shellscript

Example:

```yaml
Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash
/bin/echo "Hello World" >> /tmp/testfile.txt

--//--
```

- User-Data Script: Begins with: `#!` or `Content-Type: text/x-shellscript` when using a MIME archive.
- Include File: Begins with: `#include` or `Content-Type: text/x-include-url` when using a MIME archive.
- Cloud Config Data: Begins with: `#cloud-config` or `Content-Type: text/cloud-config` when using a MIME archive.
- Upstart Job: Begins with: `#upstart-job` or `Content-Type: text/upstart-job` when using a MIME archive.
- Cloud Boothook: Begins with: `#cloud-boothook` or `Content-Type: text/cloud-boothook` when using a MIME archive.
- Part Handler: Begins with: `#part-handler` or `Content-Type: text/part-handler` when using a MIME archive.

## Reference

- [Cloud Init](https://cloudinit.readthedocs.io/)
