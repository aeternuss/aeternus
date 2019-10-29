# Kubernetes - Configure Pods and Containers

- Extended Resources
- Security Context
- Service Accounts
- Liveness and Readiness
- postStart and preStop handlers
- Share Process Namespace
- Kompose

## Security Context

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: security-context-demo
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 2000
    fsGroup: 3000
    allowPrivilegeEscalation: false
    capabilities:
      add: [ "NET_ADMIN", "SYS_ADMIN", "SYS_TIME" ]
    privileged: true
    seLinuxOptions:
      level: "s0:c123,c456"
```

## Liveness and Readiness

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  containers:
    - name: liveness
      image: k8s.gcr.io/busybox
      args:
        - /bin/sh
        - -c
        - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
      livenessProbe:
        exec:
          command:
            - cat
            - /tmp/healthy
        initialDelaySeconds: 5
        periodSeconds: 5

        httpGet:
          path: /healthz
          port: 8080
          httpHeaders:
            - name: Custom-Header
              value: Awesome
        initialDelaySeconds: 3
        periodSeconds: 3

        tcpSocket:
          port: 8080
        initialDelaySeconds: 15
        periodSeconds: 20
```

## postStart and preStop handlers

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: lifecycle-demo
spec:
  containers:
    - name: lifecycle-demo-container
      image: nginx
      lifecycle:
        postStart:
          exec:
            command: ["/bin/sh", "-c", "echo Hello > /usr/share/message"]
        preStop:
          exec:
            command: ["/bin/sh","-c","nginx -s quit; while killall -0 nginx; do sleep 1; done"]
```
