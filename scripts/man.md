# task


## Create new db
```
DROP DATABASE IF EXISTS zdb;
CREATE DATABASE zdb;
```


## Create new user, all access to zdb databe and only select to other dbs.

```
CREATE USER 'zuser'@'%' IDENTIFIED by '!@#nalkfinalkHkkmsknn;ifdovn!@#' ;
GRANT ALL ON zdb.* to 'zuser'@'%' ;
GRANT SELECT ON *.* to 'zuser'@'%' ;
```
Check
```
show grants for 'zuser'@'%' ;
+-------------------------------------------------------------------------------------------------------+
| Grants for zuser@%                                                                                    |
+-------------------------------------------------------------------------------------------------------+
| GRANT SELECT ON *.* TO `zuser`@`%` IDENTIFIED BY PASSWORD '*0B98BBE578A4BAD562CCFF8D25CFA33CC637F16F' |
| GRANT ALL PRIVILEGES ON `zdb`.* TO `zuser`@`%`                                                        |
+-------------------------------------------------------------------------------------------------------+

```

show all cli history, better solution
```
sed "s/\\\040/ /g" < .mysql_history
```
