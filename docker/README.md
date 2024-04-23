# Database install with docker 



## Mariadb 

Create data direcroty
```
mkdir -p data/var/mysql
```


```
$ docker-compose -f mariadb.yml up -d 
```
https://hub.docker.com/_/mariadb


Change `my.cnf` file and customize for yourself.


## Mysql


