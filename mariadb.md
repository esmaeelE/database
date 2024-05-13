# Install mariadb with nginx reverse proxy


```
apt install mariadb-server mariadb-client
apt install nginx
```

Permit root login
```
GRANT ALL PRIVILEGES ON *.* TO `root`@`%` IDENTIFIED BY 'password' WITH GRANT OPTION;
```

Nginx reverse proxy config
```
stream {
        upstream db-maria {
          server 127.0.0.1:3306;
        }
        
        server {
          listen 33063;
          proxy_pass db-maria;
        }
}

```

After change config
```
sudo nginx -T
sudo systemctl restart nginx.service
```
Now nginx reverse proxy works on port **33063**.
we expose 33063 to internet.
```
$ ss -tulpen 
Netid    State     Recv-Q    Send-Q       Local Address:Port          Peer Address:Port    Process                                                             
tcp      LISTEN    0         900              127.0.0.1:3306               0.0.0.0:*        uid:102 ino:40772 sk:1 cgroup:/system.slice/mariadb.service <->    
tcp      LISTEN    0         128                0.0.0.0:22                 0.0.0.0:*        ino:14887 sk:2 cgroup:/system.slice/ssh.service <->                
tcp      LISTEN    0         511                0.0.0.0:33063              0.0.0.0:*        ino:54851 sk:9 cgroup:/system.slice/nginx.service <->              
tcp      LISTEN    0         128                   [::]:22                    [::]:*        ino:14898 sk:3 cgroup:/system.slice/ssh.service v6only:1 <->   
```

## Connect
```
mariadb -u root -p -h 185.70.187.147 --port 33063
mariadb --defaults-extra-file=secret.cnf -e "show databases;"
```

secret.cnf
```
[client]
user=root
password="password"
host=127.0.0.1
port=3306
```
