# Kubernetes - Inject Data Into Applications

-   command
-   args
-   env & envFrom
-   Downward API
-   ConfigMap & Secret
-   PodPreset

Define a Command and Arguments for a Container
==============================================

Define a command and arguments when you create a Pod
----------------------------------------------------

When you create a Pod, you can define a command and arguments for the
containers that run in the Pod.

-   To define a command, include the **command** field in the
    configuration file.
-   To define arguments for the command, **include** the args field in
    the configuration file.

Use environment variables to define arguments
---------------------------------------------

You can define arguments by using environment variables:

``` {.sourceCode .yaml}
env:
  - name: MESSAGE
    value: "hello world"
command: ["/bin/echo"]
args: ["$(MESSAGE)"]
```

Define Environment Variables for a Container
============================================

Define an environment variable for a container
----------------------------------------------

When you create a Pod, you can set environment variables for the
containers that run in the Pod.

To set environment variables, include the **env** or **envFrom** field
in the configuration file.

Expose Pod Information to Containers Through Environment Variables
==================================================================

The Downward API
----------------

There are two ways to expose Pod and Container fields to a running
Container:

-   Environment variables
-   DownwardAPIVolumeFiles

Use Pod fields as values for environment variables
--------------------------------------------------

``` {.sourceCode .yaml}
env:
  - name: MY_NODE_NAME
    valueFrom:
      fieldRef:
        fieldPath: spec.nodeName
```

Use Container fields as values for environment variables
--------------------------------------------------------

``` {.sourceCode .yaml}
env:
  - name: MY_CPU_REQUEST
    valueFrom:
      resourceFieldRef:
        containerName: test-container
        resource: requests.cpu
```

Expose Pod Information to Containers Through Files
==================================================

A **DownwardAPIVolumeFile** can expose Pod fields and Container fields.

Store Pod fields
----------------

``` {.sourceCode .yaml}
containers:
  - volumeMounts:
      - name: podInfo
        mountPath: /etc/podInfo
        readOnly: true
volumes:
  - name: podInfo
    downwardApi:
      items:
        - path: "labels"
          fieldRef:
            fieldPath: metadata.labels
        - path: "annotations"
          fieldRef:
            fieldPath: metadata.annotations
```

The first element specifies that the value of the Pod’s metadata.labels
field should be stored in a file named labels.

The second element specifies that the value of the Pod’s annotations
field should be stored in a file named annotations.

Store Container fields
----------------------

``` {.sourceCode .yaml}
containers:
  - name: client-container
    volumeMounts:
      - name: podinfo
        mountPath: /etc/podinfo
        readOnly: false
volumes:
  - name: podinfo
    downwardAPI:
      items:
        - path: "cpu_limit"
          resourceFieldRef:
            containerName: client-container
            resource: limits.cpu
            divisor: 1m
        - path: "mem_request"
          resourceFieldRef:
            containerName: client-container
            resource: requests.memory
            divisor: 1Mi
```

The first element specifies that in the Container named
client-container, the value of the limits.cpu field in the format
specified by 1m should be stored in a file named cpu\_limit.

The divisor field is optional and has the default value of 1 which means
cores for cpu and bytes for memory.

Capabilities of the Downward API
--------------------------------

The following information is available to containers through
**environment variables** and **downwardAPI volumes**:

Information available via fieldRef:

-   metadata.name - the pod’s name
-   metadata.namespace - the pod’s namespace
-   metadata.uid - the pod’s UID
-   metadata.labels\['&lt;KEY&gt;'\] - the value of the pod’s label
    &lt;KEY&gt;
-   metadata.annotations\['&lt;KEY&gt;'\] - the value of the pod’s
    annotation &lt;KEY&gt;

Information available via resourceFieldRef:

-   A Container’s CPU limit
-   A Container’s CPU request
-   A Container’s memory limit
-   A Container’s memory request
-   A Container’s ephemeral-storage limit
-   A Container’s ephemeral-storage request

In addition, the following information is available through downwardAPI
volume fieldRef:

\* metadata.labels - all of the pod’s labels, formatted as
label-key="escaped-label-value" with one label per line \*
metadata.annotations - all of the pod’s annotations, formatted as
annotation-key="escaped-annotation-value" with one annotation per line

The following information is available through environment variables:

-   status.podIP - the pod’s IP address
-   spec.serviceAccountName - the pod’s service account name
-   spec.nodeName - the node’s name
-   status.hostIP - the node’s IP

Distribute Credentials Securely Using Secrets
=============================================

Create a Pod that has access to the secret data through a Volume
----------------------------------------------------------------

``` {.sourceCode .yaml}
apiVersion: v1
kind: Pod
metadata:
  name: secret-test-pod
spec:
  containers:
    - name: test-container
      image: nginx
      volumeMounts:
        # name must match the volume name below
        - name: secret-volume
          mountPath: /etc/secret-volume
  # The secret data is exposed to Containers in the Pod through a Volume.
  volumes:
    - name: secret-volume
      secret:
        secretName: test-secret
```

Define container environment variables using Secret data
--------------------------------------------------------

``` {.sourceCode .yaml}
apiVersion: v1
kind: Pod
metadata:
  name: env-single-secret
spec:
  containers:
    - name: envars-test-container
      image: nginx
      env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: backend-user
            key: backend-username
```

Configure all key-value pairs in a Secret as container environment variables
----------------------------------------------------------------------------

``` {.sourceCode .yaml}
apiVersion: v1
kind: Pod
metadata:
  name: envfrom-secret
spec:
  containers:
    - name: envars-test-container
      image: nginx
      envFrom:
        - secretRef:
            name: test-secret
```

Inject Information into Pods Using a PodPreset
==============================================

You can use a PodPreset object to inject information like secrets,
volume mounts, and environment variables etc into pods at creation time.

``` {.sourceCode .yaml}
apiVersion: settings.k8s.io/v1alpha1
kind: PodPreset
metadata:
  name: allow-database
spec:
  selector:
    matchLabels:
      role: frontend
  env:
    - name: DB_PORT
      value: "6379"
  envFrom:
    - configMapRef:
        name: env-config
    - secretRef:
        name: secret-config
  volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
    - name: cache-volume
      emptyDir: {}
```
