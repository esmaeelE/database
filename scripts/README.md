# About these scripts

## connect to DB without password

```
mariadb --defaults-extra-file=secret.cnf
```

## create_db_table.sh

* May cause RCE attack (Remote Code Execution) or SQL injection
* Host machine must have mariadb-client application on debian install `apt install mariadb-client`
* 

## Show all users

```
SELECT User,Host FROM mysql.user;
```

# Restore from dump file or run sql file on Database

```  
$ mariadb -u user < SQL_dump_file.sql
```

# Remove all databases

```
  $ mysql -uroot -p<password> -e "show databases" | grep -v Database | grep -v mysql| grep -v information_schema| gawk '{print "drop database `" $1 "`;select sleep(0.1);"}' | mysql -uroot -p<password>
```

## For mariadb
```
$ mariadb --defaults-extra-file=secret.cnf -e "show databases" | grep -v Database | grep -v mysql| grep -v information_schema  | awk '{print "drop database `" $1 "`;select sleep(0.1);"}' | mariadb --defaults-extra-file=secret.cnf
```

