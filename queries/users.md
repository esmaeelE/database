# Users

## Show all users

```
SELECT User,Host FROM mysql.user;
```

## Show users access and priviledges

```
SHOW GRANTS FOR 'user_name';
```


## Create new user with specific priviledges

>
> username: username
>
> databasename: databasename
>
> password: !@#nalkfinalkHkkmsknn;ifdovn!@#
>
> access: select, insert

```
CREATE USER 'username'@'%' IDENTIFIED by '!@#nalkfinalkHkkmsknn;ifdovn!@#' ;                                               
                                                                                                                       
GRANT SELECT, INSERT ON databasename.* to 'face'@'%' ;                                                                     
                                                                                                                       
FLUSH PRIVILEGES ;                                                                                                      
                                                                                                                       
SHOW GRANTS FOR 'username'@'%' ;                                                                                           
```




                             
