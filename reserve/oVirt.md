# oVirt

## Configuration

- Roles
- System Permissions
- Scheduling Policies
- Instance Types
- MAC Address Pools

## oVirt Object Hierarchy

![image](../images/ovirt-object-arch.png)

## Installing the Guest Agents and Drivers

Enable the ovirt Agent repository.

```bash
yum install https://resources.ovirt.org/pub/yum-repo/ovirt-release43.rpm
```

Install the ovirt-engine-guest-agent-common package and dependencies:

```bash
yum install ovirt-engine-guest-agent-common
```

Start and enable the service:

```bash
systemctl start ovirt-guest-agent.service
systemctl enable ovirt-guest-agent.service
```

Start and enable the qemu-ga service:

```bash
systemctl start qemu-guest-agent.service
systemctl enable qemu-guest-agent.service
```
