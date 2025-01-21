# nosql DB

## mongo db

[Install](https://github.com/esmaeelE/mongo)

## backup
```
./mongodump --host 172.16.5.61 -u mongoadmin -pbdung --port 27017 --out ~/data/mongo/backup/
```

## restore
```
./mongoresore --host 172.16.5.60 -u mongoadmin -pbdung --port 27017 ~/mongo/backup/
```

### Download and use these clinet: MongoDB Command Line Database Tools Download as not included in debian 12 

https://www.mongodb.com/try/download/app-services-cli

