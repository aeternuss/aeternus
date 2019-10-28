# Ansible - Tips

Local Connection
================

``` {.sourceCode .yaml}
- hosts: 127.0.0.1
  connection: local
  name: ...
  ...
```

When
====

file exists
-----------

``` {.sourceCode .yaml}
- name: check file exists
  stat:
    path: /path/to/file
  register: file_exists

- name: run when file not exists
  ...
  when: not file_exists.exists
```

result changed
--------------

``` {.sourceCode .yaml}
- name: step one
  ...
  register: step_one

- name: run when step one changed
  ...
  when: step_one.changed
```

Blocks
======

Blocks allow for logical grouping of tasks and in play error handling.

``` {.sourceCode .yaml}
tasks:
- name: Install, configure, and start Apache
  block:
    - name: install httpd and memcached
      yum:
        name: "{{ item }}"
        state: present
      loop:
        - httpd
        - memcached
    - name: apply the foo config template
      template:
        src: templates/src.j2
        dest: /etc/foo.conf
    - name: start service bar and enable it
      service:
        name: bar
        state: started
        enabled: True
  when: ansible_facts['distribution'] == 'CentOS'
```

changed\_when
=============

``` {.sourceCode .yaml}
- name: tasks always no change
  ...
  changed_when: false
```
