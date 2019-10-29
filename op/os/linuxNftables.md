# Linux - Nftables

nftables is the new packet classification framework that replaces the
existing {ip,ip6,arp,eb}\_tables infrastructure.

## Netfilter Hooks

![image](/image/linuxNftables-01.png)

### Ingress hook

Since Linux kernel 4.2, Netfilter also comes with an ingress hook that
you can use from nftables.

You can use this new ingress hook to filter traffic from Layer 2.

![image](/image/linuxNftables-02.png)

## Basic Concepts

> tables
>>   chains
>>>    rules

table
> refers to a container of chains with no specific semantics. 

chain
> within a table refers to a container of rules.

rule
> refers to an action to be configured within a chain. 

### Tables

family
> refers to a one of the following table types: *ip, arp, ip6, bridge, inet, netdev*

### Chains

type
> refers to the kind of chain to be created. Possible types are:

 -   filter: Supported by arp, bridge, ip, ip6 and inet table families.
 -   route: Mark packets (like mangle for the output hook, for other hooks use the type filter instead), supported by ip and ip6.
 -   nat: In order to perform Network Address Translation, supported by ip and ip6.

hook
> refers to an specific stage of the packet while it's being processed
> through the kernel. More info in Netfilter hooks.

- The hooks for ip, ip6 and inet families are: prerouting, input, forward, output, postrouting.
- The hooks for arp family are: input, output.
- The bridge family handles ethernet packets traversing bridge devices.
- The hook for netdev is: ingress.

priority
> refers to a number used to order the chains or to set them between some Netfilter operations.

policy
> is the default verdict statement to control the flow in the chain.
> Possible values are: *accept, drop, queue, continue, return*.

### Rules

handle
> is an internal number that identifies a certain rule.

position
> is an internal number that is used to insert a rule before a certain handle.

matches
> are clues used to access to certain packet information and create filters according to them.

statement
> is the action performed when the packet match the rule.

## Examples

```bash
flush ruleset

table firewall {
  chain incoming {
    type filter hook input priority 0; policy drop;

    # established/related connections
    ct state established,related accept

    # loopback interface
    iifname lo accept

    # icmp
    icmp type echo-request accept

    # open tcp ports: sshd (22), httpd (80)
    tcp dport {ssh, http} accept
  }
}

table ip6 firewall {
  chain incoming {
    type filter hook input priority 0; policy drop;

    # established/related connections
    ct state established,related accept

    # invalid connections
    ct state invalid drop

    # loopback interface
    iifname lo accept

    # icmp
    # routers may also want: mld-listener-query, nd-router-solicit
    icmpv6 type {echo-request,nd-neighbor-solicit} accept

    # open tcp ports: sshd (22), httpd (80)
    tcp dport {ssh, http} accept
  }
}
```

## Reference

- [nftables wiki](https://wiki.nftables.org)
