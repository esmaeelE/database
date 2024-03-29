# some commands

## connect to DB engine 
```
mariadb --defaults-extra-file=connection.cnf
```


### Run a sql script file: `info.sql` on Database
```
mariadb --defaults-extra-file=connection.cnf --table < info.sql
```


## Show all database
```
mariadb-show --defaults-extra-file=connection.cnf
```
## Show all tables inside a database
```
mariadb-show --defaults-extra-file=connection.cnf ${db_name}
```

## Show a table inside a database
```
mariadb-show  --defaults-extra-file=connection.cnf  ${db_name} ${table_name} ${row_in_table}
```

# Install mariadb client on debian
```
sudo apt install mariadb-client
```

Show all commands provided by client, by press tab in shell after write mariadb.
```
mariadb                       mariadbd-safe-helper          mariadb-report
mariadb-access                mariadb-dump                  mariadb-secure-installation
mariadb-admin                 mariadb-dumpslow              mariadb-service-convert
mariadb-analyze               mariadb-find-rows             mariadb-setpermission
mariadb-binlog                mariadb-fix-extensions        mariadb-show
mariadb-check                 mariadb-hotcopy               mariadb-slap
mariadbcheck                  mariadb-import                mariadb-tzinfo-to-sql
mariadb-conv                  mariadb-install-db            mariadb-upgrade
mariadb-convert-table-format  mariadb-optimize              mariadb-waitpid
mariadbd-multi                mariadb-plugin                
mariadbd-safe                 mariadb-repair                
```

### Test
```
$ mariadb --defaults-extra-file=secret.cnf 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 5478
Server version: 11.3.2-MariaDB-1:11.3.2+maria~ubu2204 mariadb.org binary distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> \s
--------------
mariadb  Ver 15.1 Distrib 10.11.6-MariaDB, for debian-linux-gnu (x86_64) using  EditLine wrapper

Connection id:		5478
Current database:	
Current user:		root@172.18.0.1
SSL:			Not in use
Current pager:		stdout
Using outfile:		''
Using delimiter:	;
Server:			MariaDB
Server version:		11.3.2-MariaDB-1:11.3.2+maria~ubu2204 mariadb.org binary distribution
Protocol version:	10
Connection:		127.0.0.1 via TCP/IP
Server characterset:	utf8mb3
Db     characterset:	utf8mb3
Client characterset:	utf8mb3
Conn.  characterset:	utf8mb3
TCP port:		3306
Uptime:			1 day 3 hours 29 min 14 sec

Threads: 90  Questions: 363555  Slow queries: 1  Opens: 14828  Open tables: 1024  Queries per second avg: 3.673
--------------


```


