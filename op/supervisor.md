# Supervisor

Suervisor is a client/server system that allows its users to control a number of processes.

## Components

- supervisord

  The service piece of supervisor is named supervisord. It is reponsible for starting child programs at its own invocation, responding to commands from clients.

- supervisorctl

  The command-line client piece fo the supervisor is named supervisorctl. It provides a shell-like interface to the features provided by supervisord.

- Web Server

  A (sparse) web user interface with functionality comparable to supervisorctl.

- XML-RPC Interface

  The same HTTP server which serves the web UI serves up an XML-RPC interface that can be used to interrogate and control supervisor and the programs it runs.

---

## Installing

Supervisor can be installed with `pip install`:

```bash
pip install supervior
```

### Creating a Configuration File

Once the Supervisor installation has completed, run `echo_supervisord_conf`.

```bash
echo_supervisord_conf > /etc/supervisord.conf
```

---

## Running

Before supervisord will do anything useful for you, you'll need to add at least one `program` section to its configuration. The `program` section will define a program that its run and managed when you invoke the supervisordcommand.

```ini
[program:foo]
command=/bin/foo
```

### Running supervisord

To start supervisord, run `$BINDIR/supervisord`. The resulting process will daemonize itself and detach from the terminal. It Keeps an operations logs a `$CWD/supervisor.log` by default.

### Running supervisorctl

To start supervisorctl, run `$BINDIR/supervisorctl`. A shell will be presented that will allow you to control the processes that are currently managed by supervisord.

```bash
supervisorctl start
supervisorctl stop
supervisorctl status
## Restarts the remote supervisord
supervisorctl reload
## Reload the daemon’s configuration files, without add/remove (no restarts)
supervisorctl reread
## Restart a process Note: restart does not reread config files. For that, see reread and update.
supervisorctl restart <name>
## Reload config and add/remove as necessary, and will restart affected programs.
supervisorctl update
## Get the PID of supervisord.
supervisorctl pid
## Get the PID of a single child process by name.
supervisorctl pid <name|all>
```

---

## Configuration File

The Supervisor configuration file is conventionally named `supervisor.conf`. It is used by both supervisord and supervisorclt.

### Environment Variables

```ini
[program:example]
command=/usr/bin/example --loglevel=%(ENV_LOGLEVEL)
```

The expression `%(ENV_LOGLEVEL)`  would be expanded to the value  of the environment variable `LOGLEVEL`.

### [supervisord] Section Setttings

The [supervisord] controls global settings related to the supervisord process.

```ini
[supervisord]
logfile = /tmp/supervisord.log
logfile_maxbytes = 50MB
logfile_backups = 10
loglevel = warn
pidfile = /tmp/supervisord.pid
nodaemon = true
minfds = 1024
minprocs = 200
umask = 022
user =  chrism
identifier = supervisor
directory = /tmp
nocleanup =true
childlogdir = /tmp
strip_ansi = false
environment = KEY1="value1",KEY2="value2"
```

### [supervisorctl] Section Settings

It contains setting for the supervisorctl interactive shell program.

```ini
[supervisorctl]
serverurl = unix://tmp/supervisor.sock
username = user
password = 123
prompot = mysupervisor
history_file = /tmp/superviorctl_history.log
```

### [program:x] Section Settings

The configuration file must contain one or more `program` sections in order for supervisord to know which programs it should start and control.

```ini
[program:cat]
command=/bin/cat
process_name = %(program_name)s
numprocs = 1
directory = /tmp
umask = 022
priority = 999
autostart = true
autorestart = unexpected
startsecs = 10
startretries = 3
exitcodes = 0
user = chrism
stdout_logfile = /tmp/%(program_name)s_%(process_num)02d_stdout.log
stdout_logfile_maxbytes = 50MB
stdout_logfile_backups = 10
stderr_logfile = /tmp/%(program_name)s_%(process_num)02d_stderr.log
stderr_logfile_maxbytes = 50MB
stderr_logfile_backups = 10
environment =  A="1",B="2"
serverurl = AUTO
```

### [include] Section Settings

Control other configuration files to be included within the configuration.

```ini
[include]
files = /path/to/file1.conf /path/to/*.conf /path/to/other??.conf
```

### [group:x] Section Settings

It is often useful to group "homogeneous" process groups together into a "heterogenenous" process group so they can be controlled as a unit from Supervisor's various controller interfaces.

```ini
[group:foo]
programs=bar,baz
priority=999
```

### [unix_http_server] Section Settings

The [unit_http_server] configuration parameters control an HTTP server that linstens on a UNIX domain socket should be inserted. If the configuration file has no [unix_http_server] section, a UNIX domain socket HTTP server will not be started.

```ini
[unix_http_server]
file = /tm/supervisor.sock
chmod = 0777
chown = nobody:nogroup
username = user
password = 123
```

### [inet_http_server] Section Settings

The [inet_http_server] configuration parameters control an HTTP server listens on a TCP socket should be inserted. If the configuration file has no [inet_http_server] section, an inet HTTP server will not be started.

```ini
[inet_http_server]
port = 127.0.0.1:9001
username = user
password = 123
```

### [rpcinterface:x] Section Settings

Adding rpcinterface:x settings in the configuration file is only useful for people who wish to extend supervisor with additional custom behavior.

### [fcgi-program:x] Section Settings

Supervisor can manage groups of FastCGI processes that all listen on the same socket.

### [eventlistener:x] Section Settings

Supervisor allows specialized homogeneous process groups (“event listener pools”) to be defined within the configuration file. These pools contain processes that are meant to receive and respond to event notifications from supervisor’s event system.

---

## Subprocesses

supervisord's primary purpose is to create and manage processes based on data in its configuration file. It dose this by creating subprocesses. Each subprocess spawned by supervisor is managed for the  entirety of its lifetime by supervisord (supervisord is the parent process of each process it creates). When a child dies, supervior is notified of its death via the SIGCHLD signal, and it performs the appropriate operation.

Programs meant to be run under supervisor should not daemonize themselves. Instead, they should run in the foreground. They should no detach from the terminal from which they are started.

```ini
[program:apache2]
command=/path/to/httpd -c "ErrorLog /dev/stdout" -DFOREGROUND
redirect_stderr=true

[program:postgres]
command=/path/to/postmaster
; we use the "fast" shutdown signal SIGINT
stopsignal=INT
redirect_stderr=true

[program:slapd]
command=/path/to/slapd -f /path/to/slapd.conf -h ldap://0.0.0.0:8888
redirect_stderr=true
```

### pidproxy Program

Some processes (like mysqld) ignore signals sent to the actual process which is spawned by supervisord. Instead, a “special” thread/process is created by these kinds of programs which is responsible for handling signals. This is problematic because supervisord can only kill a process which it creates itself. If a process created by supervisord creates its own child processes, supervisord cannot kill them.

Fortunately, these types of programs typically write a “pidfile” which contains the “special” process’ PID, and is meant to be read and used in order to kill the process. As a workaround for this case, a special pidproxy program can handle startup of these kinds of processes.

```ini
[program:mysql]
command=/path/to/pidproxy /path/to/pidfile /path/to/mysqld_safe
```

### Process States

Each process run under supervisor progresses through these states as per the following directed graph.

![Process States](../image/supervisor-subprocess-transitions.png)

---

## Logging

One of the main tasks that supervisord performs is logging. supervisord logs an activity log detailing what it’s doing as it runs. It also logs child process stdout and stderr output to other files if configured to do so.

---

## Events

Events are an advanced feature of Supervisor introduced in version 3.0. You don’t need to understand events if you simply want to use Supervisor as a mechanism to restart crashed processes or as a system to manually control process state. You do need to understand events if you want to use Supervisor as part of a process monitoring/notification framework.

---

## Reference

- [Supervisor Document](http://www.supervisord.org/)
