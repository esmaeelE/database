# nosql DB

## backup
```
./mongodump --host 172.16.5.61 -u mongoadmin -pbdung --port 27017 --out ~/data/mongo/backup/
```

## restore
```
./mongoresore --host 172.16.5.60 -u mongoadmin -pbdung --port 27017 ~/mongo/backup/

```
