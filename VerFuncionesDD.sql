SELECT 
    n.nspname AS esquema,
    p.proname AS nombre_funcion,
    pg_catalog.pg_get_function_result(p.oid) AS tipo_retorno,
    pg_catalog.pg_get_function_arguments(p.oid) AS argumentos,
    l.lanname AS lenguaje,
    p.prosrc AS cuerpo_funcion
FROM 
    pg_catalog.pg_proc p
JOIN 
    pg_catalog.pg_namespace n ON n.oid = p.pronamespace
JOIN 
    pg_catalog.pg_language l ON l.oid = p.prolang
WHERE 
    n.nspname IN ('sl') -- Para excluir funciones del sistema
  AND p.proname LIKE '%opt_val_a%'
ORDER BY 
    n.nspname, p.proname;