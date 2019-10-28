# Kubernetes

| Kubernetes is a portable, extensible, open-source platform for
| managing containerized workloads and services,
| that facilitates both declarative configuration and automation.

Components
==========

Master
------

-   kube-apiserver
-   etcd
-   kube-scheduler
-   kube-controller-manager

    > -   Node Controller
    > -   Replication Controller
    > -   Endpoints Controller
    > -   Service Account & Token Controller

-   cloud-controller-manager

Node
----

-   kubelet
-   kube-proxy
-   Container Runtime

Kubernetes Objects
==================

Kubernetes Objects are persistent entities in the Kubernetes system.

Kubernetes uses these entities to represent the state of your cluster.

Specifically, they can describe:

-   What containerized applications are running (and on which nodes)
-   The resources available to those applications
-   The policies around how those applications behave, such as restart
    policies, upgrades, and fault-tolerance

Labels and Selector
-------------------

Labels are intended to be used to specify identifying attributes of
objects that are meaningful and relevant to users, but do not directly
imply semantics to the core system.

-   Equality-based requirement

    `=, !=`

-   Set-based requirement

    `in, notin, exists`

``` {.sourceCode .yaml}
selector:
  matchLabels:
    component: redis
  matchExpressions:
    - { key: tier, operator: In, values: [cache] }
    - { key: environment, operator: NouIn, values: [dev] }
```

Field selectors
---------------

Field selectors let you select Kubernetes resources based on the value
of one or more resource fields.

`kubectl get pods --field-selector status.phase=Running`

Recommended Labels
------------------

Shared labels and annotations share a common prefix: app.kubernetes.io.

Labels without a prefix are private to users.

Kubernetes Architecture
=======================

Nodes
-----

A node is a worker machine in Kubernetes, each node contains the
services necessary to run pods and is managed by the master components.

The services on a node include the:

-   container runtime
-   kubelet
-   kube-proxy

Master-Node communication
-------------------------

### Cluster to Master

All communication paths from the cluster to the master terminate at the
apiserver (none of the other master components are designed to expose
remote services).

### Master to Cluster

There are two primary communication paths from the master (apiserver) to
the cluster.

-   The first is from the apiserver to the kubelet process which runs on
    each node in the cluster.
-   The second is from the apiserver to any node, pod, or service
    through the apiserver’s proxy functionality.

Containers
==========

Container Lifecycle Hooks
-------------------------

There are two hooks that are exposed to Containers:

PostStart

:   This hook executes immediately after a container is created.

PreStop

:   This hook is called immediately before a container is terminated due
    to an API request or management event such as liveness probe
    failure, preemption, resource contention and others.

Workloads
=========
