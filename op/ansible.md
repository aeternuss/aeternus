# Ansible

Ansible is an IT automation tool.

It can configure systems, deploy software, and orchestrate more advanced IT tasks
such as continuous deployments or zero downtime rolling updates.

---

## Architecture

```text
production                # inventory file for production servers
staging                   # inventory file for staging environment

group_vars/
  group1.yml              # here we assign variables to particular groups
  group2.yml
host_vars/
  hostname1.yml           # here we assign variables to particular systems
  hostname2.yml

library/                  # if any custom modules, put them here (optional)
module_utils/             # if any custom module_utils to support modules, put them here (optional)
filter_plugins/           # if any custom filter plugins, put them here (optional)

site.yml                  # master playbook
webservers.yml            # playbook for webserver tier
dbservers.yml             # playbook for dbserver tier

roles/
  common/                 # this hierarchy represents a "role"
    tasks/                #
      main.yml            #  <-- tasks file can include smaller files if warranted
    handlers/             #
      main.yml            #  <-- handlers file
    templates/            #  <-- files for use with the template resource
      ntp.conf.j2         #  <------- templates end in .j2
    files/                #
      bar.txt             #  <-- files for use with the copy resource
      foo.sh              #  <-- script files for use with the script resource
    vars/                 #
      main.yml            #  <-- variables associated with this role
    defaults/             #
      main.yml            #  <-- default lower priority variables for this role
    meta/                 #
      main.yml            #  <-- role dependencies
    library/              # roles can also include custom modules
    module_utils/         # roles can also include custom module_utils
    lookup_plugins/       # or other types of plugins, like lookup in this case

  webtier/                # same kind of structure as "common" was above, done for the webtier role
  monitoring/             # ""
  fooapp/                 # ""
```

```text
inventories/
  production/
    hosts              # inventory file for production servers
    group_vars/
      group1.yml       # here we assign variables to particular groups
      group2.yml
    host_vars/
      hostname1.yml    # here we assign variables to particular systems
      hostname2.yml

  staging/
    hosts              # inventory file for staging environment
    group_vars/
      group1.yml       # here we assign variables to particular groups
      group2.yml
    host_vars/
      stagehost1.yml   # here we assign variables to particular systems
      stagehost2.yml

library/
module_utils/
filter_plugins/

site.yml
webservers.yml
dbservers.yml

roles/
    common/
    webtier/
    monitoring/
    fooapp/
```

---

## Understand Core Components of Ansible

Before we get started with Ansible, it's important that you get acquainted with some basic terminologies
so that you don't get lost or confused as we move forward.

`inverntory, playbook, modules, palys, roles, variables, facts, configuration files`

### Inventory

An inventory is a text file that contains a list of servers or nodes that you are managing and configuring.

An inverntory file can contain: `hosts, groups, vars`.

```yaml
all:
  vars:
    var_a: value_a
    var_b: value_b
  hosts:
    host_a:
      ansible_connection: ssh
      ansible_host: hostname
      ansible_user: username
      var_c: value_c
    host_b:
   children:
     group_a:
       vars:
       hosts:
       children:
     group_b:
```

### Playbook

A playbook is set of configuration managemnt scripts that define
how tasks are to be executedon remote hosts or a group of host machines.

For example:

```yaml
---
- name: This installs and starts Apache webserver
  hosts: webservers

  tasks:
    - name: Install Apache Webserver
      yum: name=httpd state=latest

    - name: check httpd status
      service: name=httpd state=started
```

### Modules

Modules are discrete units of code used in playbooks for executing commands on remote hosts or servers.

The basic format of a module is `key: value`.

```yaml
- name: Install apache packages
  yum: name=httpd state=present
```

### Plays

An ansible play is a script or an instruction that defines the task to be carriedout on a server.

A collection of plays constitue a playbook.

### Variables

Variables are used when instructions vary from one system to another.

There are 3 main types of variabes:

- Playbook variables
- Inventory variables
- Special variables

In Ansible, variables are first defined using the `vars`, then followed by the variable name and the value.

```yaml
vars:
  var_name1: 'value_1'
  var_name2: 'value_2'
```

### Facts

Facts are system properties gathered by Ansible when it executes a playbook on a host system.

The properties include hostname, OS family, CPU type and CPU cores to mention a few.

```bash
ansible localhost -m setup
ansible localhost -m setup -a "filter=*ipv4"
```

### Configuration Files

Configuration file is a file that contains different parameter settings that determine how Ansible runs.

The default configuration file is: `/etc/ansible/ansible.cfg`

---

## How to install and Configure an Ansible Control Node

In this topic, we will demonstrate how you can install and configure an Ansible control node on RHEL8.

In our setup,  we are going to use 1 Ansible server and 2 remote Linux nodes.

```text
Control Node 1: RHEL 8 Server     IP: 192.168.0.108     Ansible Server
Managed Host 1: Debian 10         IP: 192.168.0.15      Webserver
Managed Host 2: CentOS 8          IP: 192.168.0.200     Database Server
```

A control node is Linux server that has Ansible installed on it and is used for managing remote hosts or nodes.
These remote systems are known as Managed Hosts or Managed Nodes.

### Step 1: Install Python 3

```bash
dnf install python3
# if multiple versions of Python exist on your server,
# you can set Python 3 as the default version
alternatives --set python /usr/bin/python3
```

### Setp 2: Setup Pip

Ansible can be installed via pip.

```bash
## run as normal user
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user

## use aliyun source
cat <<EOF >~/.pip/pip.conf
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host=mirrors.aliyun.com
EOF
```

### Step 3: Install Ansible

```bash
## run as normal user
pip install --user ansible
```

### Step 4: Shell Completion

As of Ansible 2.9 shell completion of the ansible command line utilities is available and provided
throught an optional dependency called `argcomplete`.

```bash
pip install argcomplete
# config
sudo activate-global-python-argcomplete
```

### Step 5: Creating a static Host Inventory File

The inventory file is a plain text file that resides on the controll nodes
and consists of the remote hosts's hostnames or IP addresses.

```bash
cat <<EOF >/etc/ansible/hosts
[webserver]
192.168.0.15

[database_server]
192.168.0.200
EOF
```

To list managed hosts run:

```bash
ansible all --list-hosts
```

### Step 6: Setup the Ansible Control Node to Connect with the Remote Nodes

We need to set up `passwordless SSH authentication` to the remote hosts.

On remote hosts:

- create a ansible management user 'ansible'
- set the user 'ansible' to run any command 'anywhere'(?) without password

```bash
useradd -m -s /bin/bash ansible
password ansible

cp /etc/sudoers /root/sudoers-$(date +%s)
printf "\n## Ansible management user\nansible ALL=(ALL) NOPASSWD:ALL\n" >>/etc/sudoers
```

On control node:

- generate an SSH key pair
- save the public key to the remote nodes for user 'ansible'

```bash
# generator an SSH key pair
ssh-keygen

# save the public key to the remote nodes
ssh-copy-id -i <public-key> ansible@remote-node1
ssh-copy-id -i <public-key> ansible@remote-node2
```

On remote hosts:

- edit /etc/ssh/sshd_config, disable root login and password based login
- restart sshd service

```bash
# backup
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

```config
PermitRootLogin no
ChallengeResponseAuthentication no
PasswordAuthentication no
```

Reload the ssh server:

```bash
systemctl reload ssh
```

---

## How to Configure Ansible Managed Nodes and Run ad-hoc Commands

We will demonstrate how you can configure Ansible managed nodes to run ad-hoc commands on remote hosts.

### Configure Privilege Escalation on Managed Nodes

When logged in as a regular user, you may be required to perform certain tasks
on managed nodes that require elevated privileges or root privileges.

To archieve this, you need to invoke certain directives in the playbook
to run the tasks asa privileged user on the remote hosts.

- become
- become_user
- become_method
- become_flags

```yaml
---
- name: install and start Apache webserver
  hosts: webservers

  tasks:
    - name: install httpd
      yum: name=httpd state=latest
      become: yes
      become_user: root
      become_method: sudo
      become_flags: '-s /bin/sh'
    - name: check httpd status
      service: name=httpd state=started
```

Ansible allows you to `become` another user on the managed node different from the one currently logged in.
Another directive that you can use to become another user is the `become_user`.
The `become_method` is usually set to sudo.
The `become_flags` is used at play or task level, for instance when you need to switch to a user when the shellis set to nologin.

### Command-line Options in Privilege Escalation

- --become, -b
- --become-user=<BECOME_USER>, run operations as this user (default=root)
- --ask-become-pass, -K
- --become-method <BECOME_METHOD>, privilege escalation method to use (default=sudo)

### Validate a Working Configuration using Ad-hoc Ansible Commands

Sometimes, you may want to perform quick and simple tasks on remote hosts or servers in Ansible
without necessarily having to create a playbook.
In that case, you would require to run an ad-hoc command.

```bash
ansible -m <MODULE_NAME> -a <MODULE_ARGS> [PATTERN]
```

- -m <MODULE_NAME>, module nameto execute (default=command)
- -a <MODULE_ARGS>, module arguments
- [PATTERN], host pattern

```bash
# example
ansible -m ping all
## run command
ansible -a "uptime" all
## install package
ansible -m yum -a "name=httpd state=present" servers
## create user
ansible -m user -a "name=james password=pass" servers
## transfer file
ansible -m copy -a "src=/var/log/secure dest=/tmp" servers
## change permissions and file ownership
ansible -m file -a "dest=/tmp/secure mode=600 owner=user_a group=group_a" servers
## create directory
ansible -m file -a "dest=/path/to/dir mode=755 owner=user_a group=group_a state=directory" servers
```

To view the entire list of modules with their descriptions, run the command below:

```bash
ansible-doc -l
# search module
ansible-doc -l | grep <PATTERN>
# view detailed information about a particular module
ansible-doc <MODULE_NAME>
```

### Gathering Facts about Host Systems

Facts refer to detailed information about a system.
This includes information about the IP address, system architecture, memory, and CPU to mention a few.

```bash
ansible -m setup all
```

---

## How to Use Static and Dynamic Inventories in Ansible

We will explain how to use static and dynamic inventory to defile groups of hosts in Ansible.

In Ansible, there are two types of inventory files: `Static and Dynamic`.

### Static Host Inventory File

In Ansible, a static inventory file is a plain text file that
contains a list of managed hosts declared under a host group using either hostnames or IP addresses.

```ini
[webservers]
173.82.115.165

[database_servers]
173.82.220.239

[datacenter:children]
webservers
database_servers
```

To list hosts in a inventory file:

```bash
ansible -i <INVERNTORY_FILE> --list-hosts all
```

### Dynamic Host Inventory File

A dynamic inventory is a shell script written in Python, PHP or any other programming language.

It comes in handy in cloud environments such as AWS where IP addresses change once a virtual server is stopped and started again.

To retrieve information about the hosts inside a dynamic inventory script simply run:

```bash
./script --list
```

The output should be in JSON in the format below:

A dictionary comprising of groups:

- A list of managed host per group
- A dictionary of variables

Meta dictionary:

- Hosts and hostvars

```json
{
  "webservers": {
    "hosts": [
      "webserver1.example.com",
      "webserver2.example.com"
    ],
    "vars": {}
  },
  "database_servers": {
    "hosts": [
      "mysql_db1",
      "mysql_db2"
    ],
    "vars": {}
  },
  "_meta": {
    "hostvars": {
      "mysql_db2": {},
      "webserver2.example.com": {},
      "webserver1.example.com": {},
      "mysql_db1": {}
    }
  }
}
```

---

## How to Create Ansible Plays and Playbooks

Ansible ships with standlone scripts called modules that
are used in playbooks for the execution of specialized tasks on remote nodes.

Useful Modules:

- command
- dnf
- service
- copy
- file
- lineinfile
- archive

Examples:

```yaml
---
- name: install Apache webserver
  hosts: webservers

  tasks:
    - name: Execute the Uptime command over Command module
      command: "uptime"

    - name: install httpd
      dnf: name=httpd State=latest

    - name: Start service httpd, if not started
      service: name=httpd state=started
```

### Variables to Retrieve the Results of Running Commands

An ansible `register` is used for capturing a task's output and save it a variable.
And use the `debug` module alongside the stdout return value.

```yaml
---
- hosts: all
  become: yes

  tasks:
    - name: Execute /boot usage on Hosts
      command: 'df -Th /'
      register: df

    - debug: var=df.stdout
```

### Use Conditionals to Control Play Execution

Sometimes, you may want to perform taskson specific nodes and not others.
The `when` conditional statement is quite easy to use and implement in a playbook.

```yaml
---
- hosts: all

  tasks:
    - name: Install Nginx on Debian
      apt: name=nginx state=present
      when: >
       (ansible_os_family == "Debian" and ansible_distribution_version == "18.04")
       or ansible_os_family == "SUSE"
```

### Conditionals in loops

Conditionals can also be used in a loop.

```yaml
---
- name: Install Software packages
  hosts: all
  vars:
    packages:
      - name: nginx
        required: True
      - name: mysql
        required: True
      - name: apache
        required: False

  tasks:
    - name: Install "{{ item.name }}" on Debian
      apt:
        name: "{{ item.name }}"
        state: present
      When: item.required == True
      loop: "{{ packages }}"
```

### Configure Error Handling

Sometimes, tasks fail when running playbooks.
Ansible will stop executing the remaining tasks on server 1
and attempt to complete the remaining tasks on the rest of the servers.

- any_errors_fatal
- ignore_errors

If you want consistency in the execution of the playbook, for example,
stop the execution of a playbook, should one of the servers fail, add the option.

```yaml
---
- name: Install Software packages
  hosts: server1, server2, server3
  any_errors_fatal: true
  tasks:
```

If you would like the playbook to ignore the errors and proceed to execute the remaining set of tasks:

```yaml
---
- name: Install Software packages
  hosts: server1, server2, server3

  tasks:
    - name: Install dependencies
      ignore_errors: True
```

### Create Playbooks to Configure Systems to a specified State

- --check
- --start-at-task
- --tags
- --skip-tags

The `check` mode or dry run option is used when running a playbook to
check if any errors will be encountered and if there are any changes
that will be made on the managed hosts.
It dose not make any changes to the remote nodes.

```bash
ansible-playbook --check <PLAYBOOK>
```

The other option we need to look at is the `--start-at-task` option.
This is used when specifying the name of the task that the playbook should begin or start at.

```yaml
---
- name: Install httpd
  hosts: all

  tasks:
    - yum: name=httpd state=Installed

    - name: Install htop
      yum: name=htop state=started
```

If you want to skip installing Apache webserver and instead install htop utilty run:

```bash
ansible-playbook --start-at-task "Install htop" <PLAYBOOK>
```

Lastly, you can tag your tasks or plays by adding the `tags` option to your playbook.

```yaml
---
- name: Install httpd
  tags: Install and start
  hosts: all

  tasks:
    - yum: name=httpd state=Installed
      tags: Install

    - service: name=httpd state=started
```

```bash
ansible-playbook --tags "Install" <PLAYBOOK>
#To omit the tags use the `--skip-tags` option:
ansible-playbook --skip-tags "Install" <PLAYBOOK>
```

---

## How to Create Templates in Ansible to Create Configurations on Managed Nodes

Ansible uses `Jinja2` which is a modern templating engine for Python frameworks used to generate dynamic content or expressions.

Jinja2 uses the double curly braces `{{ ... }}` to enclose an variable that has been defined.
For comments, use `{{#  #}}` and for conditional statements use `{% %}`.

```jinja2
{{# vlans.conf.j2 #}}
vlan {{ vlan.id }}
name {{ vlan.name }}
```

```yaml
- hosts

  tasks:
    - name: Rendering VLAN configuration
      vars:
        vlan:
          id: 10
          name: LB
      template:
        src: vlans.conf.j2
        dest: vlan_configs/vlans.conf
```

### Filters

Sometimes, you may decide to substitute the value of a variable with a string that appears in a certain manner.

```jinja2
{{ ansible_hostname | uper }}
{{ ansible_os_family | lower }}
{{ movie_name | replace("Ring", "Heist") }}

{{ [2,3,4,5,6] | min }}
{{ 50 | random }}
```

### Loops

```jinja2
{% for number in [0,1,2,3,4,5,6,7,8] %}
{{ number }}
{% endfor %}
```

You can also combine the loop with `if-else` statement:

```jinja2
{% for number in [0,1,2,3,4,5,6,7,8] %}
  {% if number == 5 %}
    {{ number }}
  {% endif %}
{% endfor %}
```

---

## How to Work with Ansible Variables and Facts

A variable name includes letters, numbers, underscores or a mix of either 2 or all of them.

### Playbook Variables

To define a variable in a playbook, simply use the keyword `vars` before writing your variables with indentation.

Variable types:

- string
- list
- dicionary

```yaml
- hosts: all
  vars:
    var_string: Hello world!
    var_list:
      - Africa
      - Asia
    var_list2: [ South America, North America ]
    var_dictionary:
      source: 192.168.1.1
      port: 80
```

### Inventory variables

In inventories, you can assign a variable to a host system and later use it in a playbook.

```ini
[web_servers]
web_server_1 ansible_user=centos http_port=80
web_server_2 ansible_user=ubuntu http_port=8080

[web_servers:vars]
ftp_port=21
```

### Special Variables

Ansible provides a list of predefined variables but cannot be altered or defined by the user which is refered to as `Ansible Facts`.

When running playbooks, the first task that Ansible dose is the execution if setup task.

```bash
ansible -m setup <HOST>
```

#### Custom Facts

You can create your own custom facts.

- Create a `/etc/ansible/facts.d` directory on the managed or remote node.
- Inside this directory, create a file(s) with a `.fact` extension. This file(s) will return `JSON` data.

```bash
#!/bin/bash
## date_time.fact
DATE=`date`
echo "{\"date\" : \"${DATE}\"}"
```

```bash
chmod +x date_time.fact
```

```yaml
---
- hosts: webservers

  tasks:
    - name: Get custom facts
      debug:
        msg: The custom fact is {{ ansible_local.date_time }}
```

Append the fact filename to the `ansible_local` variable which stores all the custom facts.

---

## How to Create and Download Role on Ansible Galaxy and Use Them

In Ansible, roles are used for breaking down playbooks into resuable files that can be used across several other instances where the need arises to perform a similar task.

### Create an Ansible Role

To Create a role in Ansible:

```bash
ansible-galaxy role init <role_name>
```

The directory structure of the role:

```tree
role/
├── README.md
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml
```

Call the role in a playbook file:

```yaml
---
- hosts: servers
  include_role:
    name: role_name
  vars:
    rolevar1: value
    rolevar2: value
```

### Installing a Role from Ansible Galaxy

Roles play a crucial role in sharing code with other users in the Ansible community using the Ansible Galaxy platform.

To search a role in Ansible Galaxy:

```bash
ansible-galaxy search <role>

## to gather more information about a role
ansible-galaxy info <role>

## to list the roles installed
ansible-galaxy list
```

To install a role:

```bash
ansible-galaxy install <role>
```

The role is downloaded and extracted to the default roles directory located at `/etc/ansible/roles`.

The role can thereafter be called in a playbook:

```bash
---
- hosts: servers

  - include_role:
      name: role_name
    vars:
      rolevar1: value
      rolevar2: value
```

---

## How to Use Ansible Vault in Playbooks to Protect Sensitive Data

Ansible vault can encrypt variables, or even entire files and YAML playbooks.

### How to Create an Encrypted File in Ansible

Use the `ansible-vault` command to create an encrypted file:

```bash
## create an encrypted file
ansible-vault create <filename>

## encrypt an unencrypted file
ansible-vault encrypt <unencrypted-file>

## view an encrypted file
ansible-vault view <encrypted-file>

## edit an ecrypted file
ansible-vault edit <encrypted-file>

## decrypt an encrypted file
ansible-vault decrypt <encrypted-file>
```

### How to Change Ansible Vault Password

To change the Ansible vault password:

```bash
ansible-vault rekey <encrypted-file>
```

### How to Encrypt Specific Variables in Ansible

To encrypt certain variables:

```bash
ansible-vault encrypt_string
```

### How to Decrypt a Playbook File during Runtime

```bash
ansible-playbook --ask-vault-pass play.yml

## using a separate password file
ansible-playbook --vault-password-file <password-file> play.yml
```

## Ansible Inventory

### Connecting to hosts: behavioral inventory parameters

Host connection:

| Parameters | Description |
| --- | --- |
| ansible_connection | Connection type to the host. This can be the name of any of ansible’s connection plugins. SSH protocol types are smart, ssh or paramiko. The default is smart. Non-SSH based types are described in the next section. |
| ansible_host | The name of the host to connect to, if different from the alias you wish to give to it. |
| ansible_port | The connection port number, if not the default (22 for ssh) |
| ansible_user | The user name to use when connecting to the host |
| ansible_password | The password to use to authenticate to the host (never store this variable in plain text; always use a vault. See Variables and Vaults) |

Specific to the SSH connection:

| Parameters | Description |
| --- | --- |
| ansible_ssh_private_key_file | Private key file used by ssh. Useful if using multiple keys and you don’t want to use SSH agent. |
| ansible_ssh_common_args | This setting is always appended to the default command line for sftp, scp, and ssh. Useful to configure a ProxyCommand for a certain host (or group). |
| ansible_sftp_extra_args | This setting is always appended to the default sftp command line. |
| ansible_scp_extra_args | This setting is always appended to the default scp command line. |
| ansible_ssh_extra_args | This setting is always appended to the default ssh command line. |
| ansible_ssh_pipelining | Determines whether or not to use SSH pipelining. This can override the pipelining setting in ansible.cfg. |
| ansible_ssh_executable | This setting overrides the default behavior to use the system ssh. This can override the ssh_executable setting in ansible.cfg. |
| ansible_become | Equivalent to ansible_sudo or ansible_su, allows to force privilege escalation |
| ansible_become_method | Allows to set privilege escalation method |
| ansible_become_user | Equivalent to ansible_sudo_user or ansible_su_user, allows to set the user you become through privilege escalation |
| ansible_become_password | Equivalent to ansible_sudo_password or ansible_su_password, allows you to set the privilege escalation password (never store this variable in plain text; always use a vault. See Variables and Vaults) |
| ansible_become_exe | Equivalent to ansible_sudo_exe or ansible_su_exe, allows you to set the executable for the escalation method selected |
| ansible_become_flags | Equivalent to ansible_sudo_flags or ansible_su_flags, allows you to set the flags passed to the selected escalation method. This can be also set globally in ansible.cfg in the sudo_flags option |

Remote host environment parameters:

| Parameters | Description |
| --- | --- |
| ansible_shell_type | The shell type of the target system. You should not use this setting unless you have set the ansible_shell_executable to a non-Bourne (sh) compatible shell. By default commands are formatted using sh-style syntax. Setting this to csh or fish will cause commands executed on target systems to follow those shell’s syntax instead. |
| ansible_python_interpreter | The target host python path. This is useful for systems with more than one Python or not located at /usr/bin/python such as *BSD, or where /usr/bin/python is not a 2.X series Python. We do not use the /usr/bin/env mechanism as that requires the remote user’s path to be set right and also assumes the python executable is named python, where the executable might be named something like python2.6. |
| ansible_*_interpreter | Works for anything such as ruby or perl and works just like ansible_python_interpreter. This replaces shebang of modules which will run on that host. |
| ansible_shell_executable | This sets the shell the ansible controller will use on the target machine, overrides executable in ansible.cfg which defaults to /bin/sh. You should really only change it if is not possible to use /bin/sh (i.e. /bin/sh is not installed on the target machine or cannot be run from sudo.). |

Non-SSH connection types:

As stated in the previous section, Ansible executes playbooks over SSH but it is not limited to this connection type. With the host specific parameter ansible_connection=<connector>, the connection type can be changed. The following non-SSH based connectors are available:

local

This connector can be used to deploy the playbook to the control machine itself.

docker

This connector deploys the playbook directly into Docker containers using the local Docker client. The following parameters are processed by this connector:

| Parameters | Description |
| --- | --- |
| ansible_host | The name of the Docker container to connect to. |
| ansible_user | The user name to operate within the container. The user must exist inside the container. |
| ansible_become | If set to true the become_user will be used to operate within the container. |
| ansible_docker_extra_args | Could be a string with any additional arguments understood by Docker, which are not command specific. This parameter is mainly used to configure a remote Docker daemon to use. |

## Features

### Error Handling In Playbooks

#### Ignoring Failed Commands

Generally playbooks will stop executing any more steps on a host that has a task fail. Sometimes, though, you want to continueon.

```yaml
- name: this will not be counted as a failure
  command: /bin/false
  ignore_errors: yes
```

#### Resetting Unreachable Hosts

Connection failures set hosts as `‘UNREACHABLE’`, which will remove them from the list of active hosts for the run. To recover from these issues you can use `meta: clear_host_errors` to have all currently flagged hosts reactivated, so subsequent tasks can try to use them again.

#### Handlers and Failure

When a task fails on a host, handlers which were previously notified will not be run on that host.

You can change this behavior with the `--force-handlers` command-line option, or by including `force_handlers: True` in a play, or `force_hanlders = True` in ansible.cfg.

#### Controlling What Defines Failure

Ansible lets you define what "failure" means in each task using the `failed_when` conditional.

```yaml
- name: Fail task when both files are identical
  raw: diff foo/file1 bar/file2
  register: diff_cmd
  failed_when: diff_cmd.rc == 0 or diff_cmd.rc >= 2

- name: example of many failed_when conditions with OR
  shell: "./myBinary"
  register: ret
  failed_when: >
    ("No such file or directory" in ret.stdout) or
    (ret.stderr != '') or
    (ret.rc == 10)
```

#### Overriding The Changed Result

When a shell/command or other module runs it will typically report "changed" status based on whether it thinks it affected machine state.

```yaml
tasks:

  - shell: /usr/bin/billybass --mode="take me to the river"
    register: bass_result
    changed_when: "bass_result.rc != 2"

  # this will never report 'changed' status
  - shell: wall 'beep'
    changed_when: False

  - command: /bin/fake_command
    register: result
    ignore_errors: True
    changed_when:
      - '"ERROR" in result.stderr'
      - result.rc == 2
```

#### Aborting the play

Sometimes it's desirable to abort the entire play on failure, not just skip remaining tasks for a host.

`any_errors_fatal` can be set at the play or block level.

```yaml
- hosts: somehosts
  any_errors_fatal: true
  roles:
    - myrole

- hosts: somehosts
  tasks:
    - block:
        - include_tasks: mytasks.yml
      any_errors_fatal: true
```

#### Using blocks

Most of what you can apply to a single task (with the exception of loops) can be applied at the Blocks level.

```yaml
tasks:
- name: Handle the error
  block:
    - debug:
        msg: 'I execute normally'
    - name: i force a failure
      command: /bin/false
    - debug:
        msg: 'I never execute, due to the above task failing, :-('
  rescue:
    - debug:
        msg: 'I caught an error, can do stuff here to fix it, :-)'
```

This will ‘revert’ the failed status of the outer block task for the run and the play will continue as if it had succeeded.

### Delegation, Rolling Updates, and Local Actions

#### Rolling Update Batch Size

By defualt, Ansible will try to manage all of the machines referenced in a play in parallel. For a rolling update use case, you can define how many hosts Ansible should manage at a single time by using the `serial` keyword.

```yaml
---
- name: test play
  hosts: webservers
  serial: 2
  gather_facts: False

  tasks:
    - name: task one
      command: hostname
    - name: task two
      command: hostname
```

The `serial` keyword can also be specified as a percentage, which will be applied to the total number of hosts in a play, in order to determine the number of hosts per pass:

```yaml
---
- name: test play
  hosts: webservers
  serial: "30%"
```

As of Ansible 2.2, the batch sizes can be specified as a list, as follows:

```yaml
---
- name: test play
  hosts: webservers
  serial:
    - 1
    - 5
    - 10
```

In the above example, the first batch would contain a single host, the next would contain 5 hosts, and (if there are any hosts left), every following batch would contain 10 hosts until all available hosts are used.

It is also possible to list multiple batch sizes as percentages:

```yaml
---
- name: test play
  hosts: webservers
  serial:
    - "10%"
    - "20%"
    - "100%"
```

You can also mix and match the values:

```yaml
---
- name: test play
  hosts: webservers
  serial:
    - 1
    - 5
    - "20%"
```

#### Delegation

If you want to perform a task on one host with reference to other hosts, use the `‘delegate_to’` keyword on a task.

```yaml
- hosts: webservers
  serial: 5

  tasks:
    - name: take out of load balancer pool
      command: /usr/bin/take_out_of_pool {{ inventory_hostname }}
      delegate_to: 127.0.0.1

    - name: actual steps would go here
      yum:
        name: acme-web-stack
        state: latest

    - name: add back to load balancer pool
      command: /usr/bin/add_back_to_pool {{ inventory_hostname }}
      delegate_to: 127.0.0.1
```

There is also a shorthand syntax that you can use on a per-task basis: `‘local_action’`.

```yaml
---
# ...

  tasks:
    - name: take out of load balancer pool
      local_action: command /usr/bin/take_out_of_pool {{ inventory_hostname }}

# ...

    - name: add back to load balancer pool
      local_action: command /usr/bin/add_back_to_pool {{ inventory_hostname }}
```

#### Delegated Facts

By default, any fact gathered by a delegated task are assigned to the inventory_hostname (the current host) instead of the host which actually produced the facts (the delegated to host). The directive delegate_facts may be set to True to assign the task’s gathered facts to the delegated host instead of the current one.:

```yaml
---
- hosts: app_servers

  tasks:
    - name: gather facts from db servers
      setup:
      delegate_to: "{{item}}"
      delegate_facts: True
      loop: "{{groups['dbservers']}}"
```

#### Run Once

In some cases there may be a need to only run a task one time for a batch of hosts. This can be achieved by configuring “run_once” on a task:

```yaml
---
# ...

  tasks:

    # ...

    - command: /opt/application/upgrade_db.py
      run_once: true

    # ...
```

## Tips

### When

```yaml
- name: check file exists
  stat:
    path: /path/to/file
  register: file_exists

- name: run when file not exists
  ...
  when: not file_exists.exists
```

```yaml
- name: step one
  ...
  register: step_one

- name: run when step one changed
  ...
  when: step_one.changed
```

---

## Reference

- [Red Hat Ansible Certification Guide](https://www.tecmint.com/understand-core-components-of-ansible/)
