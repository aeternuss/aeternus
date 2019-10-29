# Elasticsearch

## Configuration

Elasticsearch has three configuration files:

- **elasticsearch.yml** for configuring Elasticsearch
- **jvm.options** for configuring Elasticsearch JVM settings
- **log4j2.properties** for configuring Elasticsearch logging

## Secure Settings

Some settings are sensitive, and relying on filesystem permissions to protect their values is not sufficient.

For this use case, Elasticsearch provides a keystore and
the **elasticsearch-keystore** tool to manage the settings in the keystore.

## Configuring logging levels

There are four ways to configuring logging levels:

1.  Via the command-line: -E <name of logging hierarchy>:<level>
2.  Via elasticsearch.yml: <name of logging hierarchy>:<level>
3.  Via cluster settings:
    ```
    PUT /_cluster/settings
    {
      "transient": {
        "<name of logging hierarchy>": "<level>"
      }
    }
    ```
4.  Via the log4j2.properties:
    ```
    logger.<unique_identifier>.name = <name of logging hierarchy>
    logger.<unique_identifier>.level = <level>
    ```

## Important Elasticsearch configuration

- path.logs
- path.data
- cluster.name
- node.name
- network.host

### Important discovery and cluster formation settings

- discovery.seed\_hosts
- cluster.initial\_master\_nodes

```yaml
discovery.seed_hosts:
  - 192.168.1.10:9300
  - 192.168.1.11
  - seeds.mydomain.com
cluster.initial_master_nodes:
  - master-node-a
  - master-node-b
  - master-node-c
```

### Setting the heap size

Elasticsearch will assign the entire heap specified in jvm.options via the:

- -Xms (minimum heap size)
- -Xmx (maximum heap size)

### JVM heap dump path

- -XX:HeapDumpPath=<path>

By default, Elasticsearch configures the JVM to dump the heap on out of
memory exceptions to:

- /var/lib/elasticsearch for the RPM and Debian package distributions
- the data directory under the root of the Elasticsearch installation
  for the tar and zip archive distributions)

### Temp directory

- $ES_TMPDIR

On some Linux distributions a system utility will clean files and
directories from /tmp if they have not been recently accessed.

This can lead to the private temporary directory being removed while
Elasticsearch is running if features that require the temporary
directory are not used for a long time.

This causes problems if a feature that requires the temporary
directory is subsequently used.

### JVM fatal error logs

- -XX:ErrorFile=&lt;path&gt;

By default, Elasticsearch configures the JVM to write fatal error logs to:

- /var/log/elasticsearch for the RPM and Debian package distributions
- the logs directory under the root of the Elasticsearch installation
  for the tar and zip archive distributions).

## Important System Configuration

The following settings must be considered before going to production:

- Disable swapping
- Increase file descriptors
- Ensure sufficient virtual memory
- Ensure sufficient threads
- JVM DNS cache settings
- Temporary directory not mounted with noexec

### Configuring system settings

- ulimit
- /etc/security/limits.conf
- Sysconfig file
- Systemd Configuration

### Disable swapping

There are three approaches to disabling swapping:

1.  Disable all swap files: (swapoff -a) and (/etc/fstab)
2.  Configure swappiness: sysctl value **vm.swappiness** is set to 1
3.  Enable bootstrap.memory\_lock: adding this line to the
    config/elasticsearch.yml file `bootstrap.memory_lock: true`

### File Descriptors

For the .zip and .tar.gz packages,

- set ulimit -n 65535 as root before starting Elasticsearch,
- or set nofile to 65535 in /etc/security/limits.conf

### Virtual memory

- vm.max_map_count

Elasticsearch uses a mmapfs directory by default to store its indices.

update the vm.max_map_count setting to 262144 in /etc/sysctl.conf

### Number of threads

- nproc

Make sure that the number of threads that the Elasticsearch user can
create is at least 4096.

### DNS cache settings

Elasticsearch cache positive lookups for sixty seconds, and to cache
negative lookups for ten seconds.

In the JVM options:
- es.networkaddress.cache.ttl
- es.networkaddress.cache.negative.ttl

### JNA temporary directory not mounted with noexec

Elasticsearch uses the Java Native Access (JNA) library for executing
some platform-dependent native code.

On Linux, the native code backing this library is extracted at runtime
from the JNA archive.

By default, this code is extracted to the Elasticsearch temporary
directory which defaults to a sub-directory of /tmp

This location can be controlled with the JVM flag:

- -Djna.tmpdir=<path>

## Bootstrap Checks

- Heap size check(JVM options: -Xms = -Xmx)
- File descriptor check (ulimit: `* - nofile < 65536`)
- Memory lock check (bootstrap.memory_lock=enabled and ulimit: `* - memlock unlimited`)
- Maximum number of threads check (ulimit: `* - nproc > 4096`)
- Max file size check (ulimit: `* - fsize unlimited`)
- Maximum size virtual memory check (ulimit: `* - as unlimited`)
- Maximum map count check (sysctl: `vm.max_map_count > 262144`)
- Client JVM check
- Use serial collector check
- Use serial collector check
- OnError and OnOutOfMemoryError checks
- Early-access check
- G1GC check
- All permission check
- Discovery configuration check

## Discovery and cluster formation

The discovery and cluster formation module is responsible for
discovering nodes, electing a master, forming a cluster, and publishing
the cluster state each time it changes.

### Discovery

Discovery is the process by which the cluster formation module finds
other nodes with which to form a cluster.

This process starts with a list of seed addresses from one or more seed
`hosts providers`, together with the addresses of any master-eligible
nodes that were in the last-known cluster.

### Seed hosts providers

By default the cluster formation module offers two seed hosts providers
to configure the list of seed nodes:

- settings-based
- file-based

It can be extended to support cloud environments and other forms of seed
hosts providers via **discovery plugins**.

### Bootstrapping a cluster

Starting an Elasticsearch cluster for the very first time requires the
initial set of master-eligible nodes to be explicitly defined on one or
more of the master-eligible nodes in the cluster.

The initial set of master-eligible nodes is defined in the
`cluster.initial_master_nodes` setting.

This should be set to a list containing one of the following items for
each master-eligible node:

- The node name of the node.
- The node’s hostname if node.name is not set.
- The IP address of the node’s publish address
- The IP address and port of the node’s publish address, in the form IP:PORT

It is therefore better to bootstrap using at least three master-eligible
nodes, each with a cluster.initial_master_nodes setting containing all
three nodes.

### Discovery and cluster formation settings

Discovery and cluster formation are affected by the following settings:

discovery.seed_providers

> Specifies which types of seed hosts provider to use to obtain the
> addresses of the seed nodes used to start the discovery process. By
> default, it is the settings-based seed hosts provider.

discovery.seed_hosts

> Provides a list of master-eligible nodes in the cluster. Each value
> has the format host:port or host.

cluster.initial_master_nodes

> Sets a list of the node names or transport addresses of the initial
> set of master-eligible nodes in a brand-new cluster.

## Network Settings

Commonly Used Network Settings:

- network.host
- discovery.seed_hosts
- http.port
- transport.port

Advanced network settings:

- network.bind_host
- network.publish_host

An Elasticsearch node exposes two network protocol:

TCP Transport

> Used for communication between nodes in the cluster, by the Java
> Transport client.

HTTP

> Exposes the JSON-over-HTTP interface used by all clients other than
> the Java clients.

## Node

Every node in the cluster can handle HTTP and Transport traffic by
default.
* The **transport layer** is used exclusively for communication between nodes and the Java TransportClient;
* The **HTTP layer** is used only by external REST clients.

each node serves one or more purpose:

Master-eligible node

> A node that has node.master set to true (default), which makes it
> eligible to be elected as the master node, which controls the cluster.

Data node

> A node that has node.data set to true (default). Data nodes hold
> data and perform data related operations such as CRUD, search, and aggregations.

Ingest node

> A node that has node.ingest set to true (default). Ingest nodes are
> able to apply an ingest pipeline to a document in order to transform
> and enrich the document before indexing. With a heavy ingest load,
> it makes sense to use dedicated ingest nodes and to mark the master
> and data nodes as node.ingest: false.

Coordinating node

>   Requests like search requests or bulk-indexing requests may involve
>   data held on different data nodes. A search request, for example, is
>   executed in two phases which are coordinated by the node which
>   receives the client request — the coordinating node.
>
>   In the scatter phase, the coordinating node forwards the request to
>   the data nodes which hold the data. Each data node executes the
>   request locally and returns its results to the coordinating node. In
>   the gather phase, the coordinating node reduces each data node’s
>   results into a single global resultset.
>
>   Every node is implicitly a coordinating node. This means that a node
>   that has all three node.master, node.data and node.ingest set to
>   false will only act as a coordinating node, which cannot be
>   disabled. As a result, such a node needs to have enough memory and
>   CPU in order to deal with the gather phase.

To ensure that your master node is stable and not under pressure, it is
a good idea in a bigger cluster to split the roles between dedicated
master-eligible nodes and dedicated data nodes.

### Master-eligible Node

To create a dedicated master-eligible node, set:

```yaml
node.master: true
node.data: false
node.ingest: false
cluster.remote.connect: false
```

### Data Node

To create a dedicated data node, set:

```yaml
node.master: false
node.data: true
node.ingest: false
cluster.remote.connect: false
```

### Ingest Node

To create a dedicated ingest node, set:

```yaml
node.master: false
node.data: false
node.ingest: true
cluster.remote.connect: false
```

### Coordinating only node

To create a dedicated coordinating node, set:

```yaml
node.master: false
node.data: false
node.ingest: false
cluster.remote.connect: false
```

### Changing the role of a node

Each data node maintains the following data on disk:

- the shard data for every shard allocated to that node,
- the index metadata corresponding with every shard allocated to that node, and
- the cluster-wide metadata, such as settings and index templates.

Similarly, each master-eligible node maintains the following data on disk:

- the index metadata for every index in the cluster, and
- the cluster-wide metadata, such as settings and index templates.

In order to satisfy the checks for unexpected data described above, you
must perform some extra steps to prepare a node for repurposing when
setting its node.data or node.master roles to false:

- If you want to repurpose a data node by changing node.data to false
  then you should first use an allocation filter to safely migrate all
  the shard data onto other nodes in the cluster.
- If you want to repurpose a node to have both node.master: false and
  node.data: false then it is simplest to start a brand-new node with
  an empty data path and the desired roles. You may find it safest to
  use an allocation filter to migrate the shard data elsewhere in the
  cluster first.

## Shard allocation and cluster-level routing

There are a number of settings available to control the shard allocation
process:

- **Cluster level shard allocation** lists the settings to control the
  allocation and rebalancing operations.
- **Disk-based shard allocation** explains how Elasticsearch takes
  available disk space into account, and the related settings.
- **Shard allocation awareness and Forced awarenessedit** control how
  shards can be distributed across different racks or availability zones.
- **Cluster-level shard allocation** filtering allows certain nodes or
  groups of nodes excluded from allocation so that they can be decommissioned.
