# MySQL

## Arguments

- --character-set-server=utf8mb4
- --explicit-defaults-for-timestamp=true
- --ignore-db-dir=lost+found

## Backup & Restore

- Verify definitions

  ```bash
  mysqldump --all-databases --no-data --routines --events > dump-defs.sql
  mysql < dump-defs.sql
  ```

- Loading data

  ```bash
  mysqldump --all-databases --no-create-info > dump-data.sql
  mysql < dump-data.sql
  ```

## Master - Slave

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
- Setup replication coordinates
- Check replication status

```bash
#!/bin/bash

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
