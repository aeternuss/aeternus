# Kubespary

## Requirements

- Minimum required version of Kubernetes is v1.15
- Ansible v2.7.8 and python-netaddr is installed on the machine that will run Ansible commands
- Jinja 2.9 (or newer) is required to run the Ansible Playbooks
- The target servers must have access to the Internet in order to pull docker images. Otherwise, additional configuration is required (See Offline Environment)
- The target servers are configured to allow IPv4 forwarding.
- Your ssh key must be copied to all the servers part of your inventory.
- The firewalls are not managed, you'll need to implement your own rules the way you used to. in order to avoid any issue during deployment you should disable your firewall.
- If kubespray is ran from non-root user account, correct privilege escalation method should be configured in the target servers. Then the ansible_become flag or command parameters --become or -b should be specified.

## Setup Kubernetes

```bash
git clone https://github.com/kubernetes-sigs/kubespray
```

### Firewall

On master nodes:

```bash
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload

modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
sysctl -w net.ipv4.ip_forward=1
```

On worker nodes:

```bash
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --permanent --add-port=6783/tcp
firewall-cmd  --reload

modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
sysctl -w net.ipv4.ip_forward=1
```

## Reference

- [Kubespray](https://github.com/kubernetes-sigs/kubespray)
