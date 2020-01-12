# Kubernetes - Projected Volume

> Use a projected Volume to mount several existing volume sources into
> the same directory.
>
> Currently, **secret, configMap, downwardAPI, and serviceAccountToken**
> volumes can be projected.

## Configure a projected volume for a pod

This example pod has two file named username, password in directory projected-volume.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: userPass
type: Opaque
data:
  username: ajskaq
  password: kasow

---
apiVersion: v1
kind: Pod
metadata:
  name: test-projected-volume
spec:
  containers:
    - name: test-projected-volume
      image: busybox
      args:
        - sleep
        - "86400"
      volumeMounts:
        - name: all-in-one
          mountPath: "/projected-volume"
          readOnly: true
  volumes:
    - name: all-in-one
      projected:
        sources:
          - secret:
              name: userPass
```
