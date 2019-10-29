# CentOS - Cleanup Old Kernels

The best way to do this is to install the yum utilities package and then
use a command to delete all but 2 kernels.

```bash
yum install yum-utils -y
package-cleanup --oldkernels --count=2
```
