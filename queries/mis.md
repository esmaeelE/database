# some commands

connect to DB engine 
```
mariadb --defaults-extra-file=connection.cnf
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

