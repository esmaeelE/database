# About these scripts

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

