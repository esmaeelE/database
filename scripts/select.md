# SELECT

## select and sort word counts

```
 SELECT COUNT(word), word FROM database.table ORDER BY COUNT(word) DESC LIMIT 10;
```

Using **SELECT** keyword
    - to pick up what coloumn we want
**FROM** keyword 
    - to specify which table to search

This is complete query.

Now we can filter output

ordering output coloumn by number of occorance with **ORDER BY COUNT(word)**
sort them in Desending by **DESC**
and show only first 10 rows by **LIMIT 10**
ending semicoloumn denoted query finshed like C-like Programming languages.

