# Install mariadb with nginx reverse proxy


```
apt install mariadb-server mariadb-client
apt install nginx nginx-extras
```

Permit root login
```
GRANT ALL PRIVILEGES ON *.* TO `root`@`%` IDENTIFIED BY 'password' WITH GRANT OPTION;
```

Nginx reverse proxy config `/etc/nginx/nginx.conf`
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

# Nginx loadbalancer for mariadb

...

# Another way
## Mariadb install and configuration on Debian Based machines

Install latest version of Debian/Ubuntu
# Install
```
sudo apt install mariadb-server mariadb-client
sudo mysql_secure_installation
```

# Connect
```
mariadb --defaults-extra-file=remote.cnf
```

```remote.cnf
[client]
user=admin_001
password="password"
host=1.2.3.4
port=3306
```

# Create two new user: admin, connect from remote and localhost
```
sudo mariadb
GRANT ALL ON *.* TO 'admin'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'admin'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;
FLUSH PRIVILEGES;
exit;
```

# Check users
```
SELECT User,Host FROM mysql.user;
SHOW GRANTS FOR 'admin'@'%' ;                                                                                           
```
%: means remote access user

# expose to 0.0.0.0

```/etc/mysql/mariadb.conf.d/50-server.cnf
#bind-address            = 127.0.0.1
bind-address            = 0.0.0.0
```

And at last restart mariadb service
```
sudo systemctl restart mariadb.service
```

Now we can connect from outside

