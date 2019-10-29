# Tips on Dockerfile

## Localtime

```bash
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

Alpine docker image doesn't has package **tzdata**, so need install first:

```bash
apk add --no-cache --virtual .tzdata-deps tzdata
cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
apk del --no-cache .tzdata-deps
```

## Alpine

### --no-cache

No cache when install packages:

```bash
apk upgrade --no-cache
apk add --no-cache <packages>
```

### --virtual

Group dependencies, and remove all dependencies with just one command:

```bash
apk add --no-cache --virtual .build-deps <packages>
...
apk del --no-cache .build-deps
```

## pip

### --no-cache-dir

No cache when install packages:

```bash
pip install --no-cache-dir <packages>
```

## Git

### Minimal clone

```bash
git clone --depth=1 --branch=<branch> <repo-url> <repo-dir>
rm -rf ./<repo-dir>/.git
```
