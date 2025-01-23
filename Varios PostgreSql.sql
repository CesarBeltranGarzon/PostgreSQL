-- Ver comentarios en columnas de una tabla
SELECT 
    a.attname AS column_name,
    d.description AS comment
FROM 
    pg_catalog.pg_attribute a
JOIN 
    pg_catalog.pg_description d ON d.objoid = a.attrelid AND d.objsubid = a.attnum
WHERE 
    a.attrelid = 'int_option_values'::regclass
    AND a.attnum > 0
    AND NOT a.attisdropped;

   end;
   
-- Ver si tabla existe
SELECT * 
FROM information_schema.tables 
WHERE LOWER(table_name) LIKE LOWER('%int_option_values%');

SELECT * 
FROM pg_catalog.pg_tables 
WHERE LOWER(tablename) LIKE LOWER('%int_option_values%');