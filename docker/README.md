# Database install with docker 

## postgres
```
docker compose -f postgres.yml up -d
```

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


## Autostart podman as systemd serive


# Automate with systemd service

```
podman generate systemd --new --name deploy_mariadb_server_1 > mariadb.service
mkdir -p ~/.config/systemd/user/
cp mariadb.service ~/.config/systemd/user/

systemctl --user daemon-reload
systemctl --user enable mariadb.service
systemctl --user start mariadb.service
systemctl --user status mariadb.service 
```

## Mysql


