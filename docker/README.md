# Database install with docker 



## Mariadb 

Create data direcroty
```
mkdir -p data/var/mysql
```


```
$ docker-compose -f mariadb.yml up -d
or podman

$ apt install podman podman-compose
$ podman-compose -f mariadb.yml up -d 

```

For podman use `image: docker.io/mariadb:latest` in maria.yml file.

https://hub.docker.com/_/mariadb


Change `my.cnf` file and customize for yourself.


## Mysql


