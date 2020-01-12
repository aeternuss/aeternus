# Systemd

Systemd is a system and service manager for Linux operating systems.

## Creating and Monifying Systemd Unit Files

Systemd introduces the concept of systemd units. These units are represented by unit configuration files, and encapsulate information about system services, listening sockets, and other objects that are relevant to the init system.

A unit file contains configuration directives that describe the unit and define its behavior.

The `/etc/systemd/system/` directory is reserved for unit files created or customized by the system administrator.

Unit file names take the form: `unit_name.type_extension`

Unit files can be supplemented with a directory for additional configuration files. For exmaple, to add custom configuration options to sshd.service, create the `sshd.service.d/custom.conf` file and insert additional directives there.

### Understanding the Unit File Structure

Unit files typically consist of three sections:

- [Unit] - contains generic optiions that are not dependent on the type of the unit.
- [Unit_type] - if a unit has type-specific directives, these are grouped under a section named after the unit type
- [Install] - contains information about unit installation used by `systemctl enable` and `disable` commands.

Important [Unit] Section Options:

| Option | Description |
| --- | --- |
| Description | A meaningful description of the unit. |
| Documentation | Provides a list of URIs reference documentation |
| After | Defines the order in which units are started. |
| Requires | Configures dependencies on other units. |
| Wants | Configures weaker dependencies than `Requires`. |
| Conflicts | Configures negative dependencies, an opposite to `Requires` |

Important [Service] Section options:

| Option | Description |
| --- | --- |
| Type | Configures the unit process startup type that affects the functionality of `ExecStart` and related options. One of: simple, forking, oneshot, dbus, notify, idle |
| ExecStart | Sepcifies commands or scripts to be executed when the unit is started. `ExecStartPre` and `ExecStartPost` specify custom commands to be executed before and after `ExecStart`. |
| ExecStop | Specifies commands or scripts to be executed when the unit is stoped. |
| ExecReload | Specifies commands or scripts to be executed when the unit is reloaded. |
| Restart | With this option enabled, the service is restarted after its process exits, with the exception of a clean stop by the `systemctl` command. |
| RemainAfterExit | If set to True, the service is considered active even when all its processes exited. |

Important [Install] Section Options:

| Option | Description |
| --- | --- |
| Alias | Provides a space-separated list of additional names for the unit. |
| RequiredBy | A list of units that depend on the unit.|
| WantedBy | A list of units that weakly depend on the unit. |
| Also | Specifies a list of units to be installed or uninstalled along with the unit. |
| DefaultInstance | Limited to instantiated units, this option specifies the default instance for which the unit is enabled. |

Example postfix.service Unit File:

```ini
[Unit]
Description=Postfix Mail Transport Agent
After=syslog.target network.target
Conflicts=sendmail.service exim.service

[Service]
Type=forking
PIDFile=/var/spool/postfix/pid/master.pid
EnvironmentFile=-/etc/sysconfig/network
ExecStartPre=-/usr/libexec/postfix/aliasesdb
ExecStartPre=-/usr/libexec/postfix/chroot-update
ExecStart=/usr/sbin/postfix start
ExecReload=/usr/sbin/postfix reload
ExecStop=/usr/sbin/postfix stop

[Install]
WantedBy=multi-user.target
```

### Creating Custom Unit File

The general process of creating a custom service:

- Prepare the executable file with custom service.
- Create a unit file in the `/etc/systemd/system/` directory.
- Open the `name.service` file created in the previous step, and add the service configuration options.
- Notify systemd that a new `name.service` file exists by executing `systemctl daemon-reload`.

### Modify Existing Unit Files

Services installed on the system come with default unit files that are stored in the `/usr/lib/systemd/system/` directory. System Administrators should not modify these files directly, therefor any customization must be confined to configuration files int the `/etc/systemd/system/` directory.

Depending on the extent of the required changes, pick one of the following approaches:

- Create a directory for suppementary configuration files at `/etc/systemd/system/<unit>.d`.
- Create a copy of the original unit file `/usr/lib/systemd/system/` in `/etc/systemd/system/` and make changes there.

#### Extending the Default Unit Configuration

To extend the default unit file with additional configuration options:

- First create a configuration directory in `/etc/systemd/system/` named `/etc/systemd/system/<name>.service.d/`.
- Create configuration files in the directory made in the previous step. Note that the file name must end with the `.conf` suffix.

```ini
[Unit]
Requires=new_dependency
After=new_dependency
```

```ini
[Service]
Restart=always
RestartSec=30
```

#### Overriding the Default Unit Configuration

To make changes that will persist after updating the packages that provides the unit file:

- First copy the file to the `/etc/systemd/system/` directory.
- Open the copied file with a text editor, and make the desired changes.

#### Monitoring Overriden Units

To display an overview of overridden or modified unit files:

```bash
systemd-delta
```

### Working with Instantiated Units

It is possible to instantiate multiple units from a single template configuration file at runtime. The `@` character is used to mark the template and to associate units with it.

Instantiated units can be started from another unit file (using Requires or Wants options), or with the systemctl start command.

Instantiated service units are named: `template_name@instance_name.service`. Template unit name has the form of: `unit_name@.service`.

For example, the following Wants setting in a unit file:

```ini
Wants=getty@ttyA.service,getty@ttyB.service
```

first makes systemd search for given service units. If no such units are found, the part between "@" and the type suffix is ignored and systemd searches for the `getty@.service` file, reads the configuration from it, and starts the service.

Wildcard characters, called unit specifiers, can be used in any unit configuration file. Unit specifiers substitute certain unit parameters and are interpreted at runtime.

Important Unit Specifiers:

| Unit Specifier | meaning | Description |
| --- | --- | --- |
| %n | Full unit name | Stands for the full unit name including the type suffix. |
| %p | Prefix name | Stands for a unit name with type suffix removed. |
| %i | Instance name | Is the part of the instantiated unit name between the "@" character and the type suffix. |
| %H | Host name| Stands for the hostname of the running system at the point in time unit configuration is loaded. |
| %t | Runtime directory | Represents the runtime directory, which is either `/run` for the root user, or the value of XDG_RUNTIME_DIR variable for unprivileged users. |

Example of [Mount] unit file:

```ini
[Unit]
 Description = Mount NFS disk

[Mount]
 What = nfs.example.com:/export/scratch
 Where = /mnt/data/nfs
 Type = nfs
 Options = defaults

[Install]
 WantedBy = multi-user.target
 ```

## Reference

- [Managing Services With Systemd](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-managing_services_with_systemd)
