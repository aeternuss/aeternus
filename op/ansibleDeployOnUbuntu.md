# Deploy Ansible On Ubuntu

- change repo, using aliyun mirror
- install python3, pip
- install ansible

注：以下命令在普通用户下运行

## Repo

使用 Aliyun Mirror 加速软件包下载

### /etc/apt/sources.list

```bash
sudo sed -i -e 'http://archive.ubuntu.com/' -e 'https://mirrors.aliyun.com/' /etc/apt/sources.list
```

### pypi

```bash
mkdir ~/.pip

cat > ~/.pip/pip.conf <<EOF
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host=mirrors.aliyun.com
EOF
```

## python3 & pip

安装 python3 和 pip

```bash
sudo apt install python3
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user
```

## ansible

安装 ansible

```bash
pip install --user ansible
```
