# Oxidized

Oxidized is a network device configuration backup tool.

## Running with Docker

An example of docker-compose.yml.

```yaml
oxidized:
  image: oxidized/oxidized:latest
  restart: always
  ports:
    - 8888:8888/tcp
  environment:
    CONFIG_RELOAD_INTERVAL: 600
  volumes:
    - /etc/oxidized:/root/.config/oxidized
```

## Configuration

### Layout

- OXIDIZED_HOME

  Default home dir is /root/.config/oxidized, You can set the env
  variable OXIDIZED_HOME to change its home directory.

- ${OXIDIZED_HOME}/config

  Oxidized configuration is in YAML format.

- ${OXIDIZED_HOME}/router.db

  csv source

### Source

Oxidized supports CSV, SQLite, MySQL and HTTP as source backends.

- The CSV backend reads nodes from a rancid compatible
  ${OXIDIZED_HOME}/router.db file.
- The SQLite and MySQL backends will fire queries against a database
  and map certain fields to model items.
- The HTTP backend will fire queries against a http/https url.

### Example

### config

```yaml
username: <default_username>
password: <defualt_password>
model: <default_model>
interval: 3600 #interval in seconds
log: ~/.config/oxidized/log
debug: false
threads: 30
timeout: 20
retries: 3
prompt: !ruby/regexp /^([\w.@-]+[#>]\s?)$/
crash:
  directory: ~/.config/oxidized/crashes
  hostnames: false
vars:
  enable: <default_enablePassword>
groups: {}
rest: 0.0.0.0:8888
pid: /var/run/oxidized.pid
input:
  default: ssh, telnet
  debug: false
  ssh:
    secure: false
output:
  default: git
  git:
      user: <username>
      email: <email>
      repo: "~/.config/oxidized/oxidized.git"
source:
  default: csv
  csv:
    file: ~/.config/oxidized/router.db
    delimiter: !ruby/regexp /:/
    map:
      name: 0
      model: 1
      username: 2
      password: 3
    vars_map:
      enable: 4
model_map:
  cisco: ios
  juniper: junos
```

### router.db

```
# no enable
<name>:<model>:<username>:<password>
# enable
<name>:<model>:<username>:<password>:<enablePassword>
```

### Advanced Group Configuration

For group specific credentials

```yaml
groups:
  mikrotik:
    username: <username>
    password: <password>
  ubiquiti:
    username: <username>
    password: <password>
```

and add group mapping

```yaml
map:
  model: 0
  name: 1
  group: 2
```

For model specific credentials

You can add 'username: nil' if the device only expects a Password at prompt.

```yaml
models:
  junos:
    username: <username>
    password: <password>
  ironware:
    username: <username>
    password: <password>
    vars:
      enable: <enablePassword>
  cisco:
    username: nil
    password: <password>
```
