-- Some query to get overal information from Database

-- Database sizes
SELECT 
    table_schema 'Database Name', 
    SUM(data_length + index_length) 'Size (Bytes)', 
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) 'Size (MiB)', 
    ROUND(SUM(data_length + index_length) / 1024 / 1024 / 1024, 2) 'Size (GiB)' 
FROM information_schema.tables 
-- WHERE table_schema = 'mysql'
GROUP BY table_schema;



-- Table size, for specific database_name: mysql
SELECT
	table_name AS "Table",
	ROUND(((data_length + index_length) / 1024 / 1024), 2) AS "Size (MB)",
	ROUND(((data_length + index_length) / 1024 / 1024 / 1024), 2) AS "Size (GB)"
FROM
	information_schema.TABLES
WHERE
	table_schema = "new"
ORDER BY (data_length + index_length) DESC;  
