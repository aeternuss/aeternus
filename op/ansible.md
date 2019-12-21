# Ansible

Ansible is an IT automation tool.

It can configure systems, deploy software, and orchestrate more advanced IT tasks
such as continuous deployments or zero downtime rolling updates.

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

## How to install and Configure an Ansible Control Node

In this topic, we will demonstrate how you can install and configure an Ansible control node on RHEL8.

In our setup,  we are going to use 1 Ansible server and 2 remote Linux nodes.

```text
Control Node 1: RHEL 8 Server     IP: 192.168.0.108         Ansible Server
Managed Host 1: Debian 10         IP: 192.168.0.15          Webserver
Managed Host 2: CentOS 8          IP: 192.168.0.200	    Database Server
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

### Setp 2: Install Pip

Ansible can be installed via pip.

```bash
## run as normal user
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user
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

For this to happen, you need:

- generate an SSH key pair
- save the public key to the remote nodes

```bash
# generator an SSH key pair
ssh-keygen

# save the public key to the remote nodes
ssh-copy-id -i <public-key> user@remote-node1
ssh-copy-id -i <public-key> user@remote-node2
```

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
ansible -m <MODULE_NAME> -a <MODULE_ARGS> <PATTERN>
```

- -m <MODULE_NAME>, module nameto execute (default=command)
- -a <MODULE_ARGS>, module arguments
- <PATTERN>, host pattern

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

## Reference

- [Red Hat Ansible Certification Guide](https://www.tecmint.com/understand-core-components-of-ansible/)
