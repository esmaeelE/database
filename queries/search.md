# Search for a specific value in coloumn

Consider wikipedia database

```
MariaDB [my_wiki]> select * from content;
+------------+--------------+---------------------------------+---------------+-----------------+
| content_id | content_size | content_sha1                    | content_model | content_address |
+------------+--------------+---------------------------------+---------------+-----------------+
|          1 |          755 | 22vz5zlxa2zctewimaum2bf1due8hkl |             1 | tt:1            |
|          2 |          779 | cw9yshdl0m6c18rxp31up2pw55wq58u |             1 | tt:2            |
+------------+--------------+---------------------------------+---------------+-----------------+
2 rows in set (0.001 sec)

MariaDB [my_wiki]> select * from content where content_size='755';
+------------+--------------+---------------------------------+---------------+-----------------+
| content_id | content_size | content_sha1                    | content_model | content_address |
+------------+--------------+---------------------------------+---------------+-----------------+
|          1 |          755 | 22vz5zlxa2zctewimaum2bf1due8hkl |             1 | tt:1            |
+------------+--------------+---------------------------------+---------------+-----------------+
1 row in set (0.001 sec)

MariaDB [my_wiki]> 
```
