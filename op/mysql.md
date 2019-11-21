# MySQL

## Mysqld options

- --character-set-server=utf8mb4

## Mysqldump

The mysqldump client utility performs logical backups,
producing a set of SQL statements that can be executed to reproduce
the original database object definitions and table data.

### Defaults

Unless explicitly tell it not to, mysqldump is using the --opt flag.

The opt option is an alias for the following flags:

- --add-drop-table
- --add-locks
- --create-options
- --disable-keys
- --extended-insert
- --lock-tables
- --quick
- --set-charset
  
### With transactions

MyISAM tables require locking because they don't support transactions.
However, InnoDB supports transactions.

using --single-transcation flag to instead of --lock-tables flag.

```bash
mysqldump --single-transaction --skip-lock-tables db1 db2 > dbs.sql
```

### Dump the entire database

Since we'll get the internal mysql databases, which includes mysql users and privileges,
so using the --all-databases option along with the --flush-privileges options.

```bash
# all databases
mysqldump --single-transaction --skip-lock-tables --flush-privileges --all-databases > dbs.sql
```

### Replication

There are some useful flags to use when replication is in place.

- --master-data
: Write the binary log file name and position to the output

- --dump-slave
: Include CHANGE MASTER statement that lists binary log coordinates of slave's master
  
## Master - Slave

Mysql replication.

### config files for the master and the slave

Config $MASTER_HOST as master: **/etc/mysql/conf.d/master.cnf**

```ini
[mysqld]
server_id=1
log_bin=mysql-bin
binlog_format=ROW
binlog-do-db=<db1_to_repl>
binlog-do-db=<db2_to_repl>
```

Config $SLAVE_HOST as slave: **/etc/mysql/conf.d/slave.cnf**

```ini
[mysqld]
server_id=2
```

### Configuration Script

Steps:

- Create replication user on master
- Setup replication coordinates on slave
- Check replication status

```bash
#!/bin/bash

set -ex

echo "* Create replication user"

mysql --host $SLAVE_HOST -uroot -p$SLAVE_PASSWORD -AN -e 'STOP SLAVE;'
mysql --host $SLAVE_HOST -uroot -p$SLAVE_PASSWORD -AN -e 'RESET SLAVE ALL;'

mysql --host $MASTER_HOST -uroot -p$MASTER_PASSWORD -AN -e "CREATE USER '$REPLICATION_USER'@'%';"
mysql --host $MASTER_HOST -uroot -p$MASTER_PASSWORD -AN -e "GRANT REPLICATION SLAVE ON *.* to '$REPLICATION_USER'@'%' IDENTIFIED BY '$REPLICATION_PASSWORD';"
mysql --host $MASTER_HOST -uroot -p$MASTER_PASSWORD -AN -e 'FLUSH PRIVILEGES;'

echo "* Setup replication coordinates"

BINLOG_POSITION=$(eval "mysql --host $MASTER_HOST -uroot -p$MASTER_PASSWORD -AN -e 'show master status \G' | grep Position | sed -n -e 's/^.*: //p'")
BINLOG_FILE=$(eval "mysql --host $MASTER_HOST -uroot -p$MASTER_PASSWORD -AN -e 'show master status \G' | grep File | sed -n -e 's/^.*: //p'")

mysql --host $SLAVE_HOST -uroot -p$SLAVE_PASSWORD -AN -e "CHANGE MASTER TO master_host='$MASTER_HOST', master_port=3306, master_user='$REPLICATION_USER', master_password='$REPLICATION_PASSWORD', master_log_file='$BINLOG_FILE', master_log_pos=$BINLOG_POSITION;"

mysql --host $SLAVE_HOST -uroot -p $SLAVE_PASSWORD -AN -e 'START SLAVE;'

echo "* Check replication status"

mysql --host $SLAVE_HOST -uroot -p $SLAVE_PASSWORD -AN -e 'SHOW SLAVE STATUS \G'

SLAVE_IO_RUNNING=$(eval "mysql --host $SLAVE_HOST -uroot -p $SLAVE_PASSWORD -AN -e 'SHOW SLAVE STATUS \G' | grep Slave_IO_Running | sed -n -e 's/^.*: //p'")
SLAVE_SQL_RUNNING=$(eval "mysql --host $SLAVE_HOST -uroot -p $SLAVE_PASSWORD -AN -e 'SHOW SLAVE STATUS \G' | grep Slave_SQL_Running | sed -n -e 's/^.*: //p'")

if [ $SLAVE_IO_RUNNING != "Yes" || $SLAVE_SQL_RUNNING != "Yes" ]; then
    echo "[ERR] Replication status error!"
    exit -1
fi
```

### log_slave_updates option

Whether updates received by a slave server from a master server should be logged to the slave's own binary log.

Enabling `log_slave_updates` enables replication servers to be chained.

For example, you might want to set up replication servers using this arrangement:

```bash
A -> B -> C
```

Here, A serves as the master for the slave B, and B serves as the master for the slave C.

For this to work, B must be both a master and a slave.

With binary logging enabled and log_slave_updates enabled,
updates received from A are logged by B to its binary log, and can therefore be passed on to C.
