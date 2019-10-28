# Ansible

Simple, agentless IT automation.

Inventory
=========

hosts, groups, vars:

``` {.sourceCode .yaml}
all:
  vars:
    var_a: value_a
    var_b: value_b
  hosts:
    host_a:
      ansible_host: hostname
      ansible_user: username
    host_b:
   children:
     group_a:
       vars:
       hosts:
       children:
     group_b:
```

Playbook
========

| Describe a policy you want your remote systems to enforce,
| or a set of steps in a general IT process.

``` {.sourceCode .bash}
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

``` {.sourceCode .bash}
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

Variables
=========

Defining variables in:

-   inventory
-   playbook
-   included files and roles
-   files (vars\_files)

Filters
=======

Used for transforming data inside a template expression.

Tests
=====

test:

    Variable is test_name

Lookups
=======

Access to outside data sources.

Conditionals
============

Loops
=====

Blocks
======

-   block
-   rescue
-   always

Vault
=====
