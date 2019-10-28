# Cluster

Use pacemaker, corosync to create cluster.

and, add ocf:heartbeat:IPaddr2, systemd:haproxy resources.

Install packages
================

-   pacemaker
-   pcs

Setup Cluster
=============

Change password
---------------

Change hacluster password on all nodes:

``` {.sourceCode .shell}
echo 'password' | passwd --stdin hacluster
```

Setup
-----

On one node:

``` {.sourceCode .shell}
# authenticate as the hacluster user
pcs cluster auth {{ NODE1 }} {{ NODE2 }} -u hacluster -p {{ HACLUSTER_PWD }}

# setup cluster
pcs cluster setup --start --wait 10 --enable \
  --name {{ CLUSTER_NAME }} {{ NODE1 }} {{ NODE2 }}

# confiuration
pcs property set stonith-enabled=false
pcs property set no-quorum-policy=ignore
pcs resource defaults resource-stickiness=100
```

Add Resources
=============

-   ocf:heartbeat:IPaddr2
-   systemd:haproxy

``` {.sourceCode .shell}
# ocf:heartbeat:IPaddr2
pcs resource create VirtualIP ocf:heartbeat:IPaddr2 \
  ip={{ VIRTUAL_IP }} cidr_netmask=24 nic={{ INTERFACE_NAME }} \
  op monitor interval=30s

# systemd:haproxy
pcs resource create HAProxy systemd:haproxy \
  op monitor interval=30s
```

Set Constraint
--------------

Run resources on the same host, and run VirtualIP before HAProxy.

``` {.sourceCode .shell}
# run on same host
pcs constraint colocation add HAProxy with VirtualIP INFINITY

# order
pcs constraint order VirtualIP then HAProxy

# prefer host
pcs constraint location HAProxy prefers {{ NODE1 }}=50
```

Reference
=========

-   [Clusters from
    Scratch](https://clusterlabs.org/pacemaker/doc/en-US/Pacemaker/2.0/html/Clusters_from_Scratch/index.html)
