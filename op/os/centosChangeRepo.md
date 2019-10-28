# CentOS - Change Repo

CentOS Base
===========

``` {.sourceCode .bash}
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
```

EPEL
====

``` {.sourceCode .bash}
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
```

Docker-ce
=========

``` {.sourceCode .bash}
yum install -y yum-utils device-mapper-persistent-data lvm2
swapoff -a && sed -i '/ swap / s/^/#/' /etc/fstab
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

Kubernetes
==========

``` {.sourceCode .bash}
cat <<EOF > /etc/yum.repos.d/kubernets.repo
[kubernets]
name=Kubernets
baseurl=https://mirrors.aliyun.com/kubernets/yum/repos/kubernets-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernets/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernets/yum/doc/rpm-package-key.gpg
EOF

setenforce 0
```

Update
======

``` {.sourceCode .bash}
yum clean all && yum makecache
```

Reference
=========

-   [阿里云镜像中心](https://opsx.alibaba.com/mirror)
