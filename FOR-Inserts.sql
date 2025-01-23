DO
$$
DECLARE
    rec RECORD;  -- Declaramos la variable de tipo RECORD
BEGIN
    -- Primer bucle: selecciona los valores de opción según la consulta
    /*FOR rec IN 
        (SELECT option_value_id 
         FROM sl.int_option_values ova 
         WHERE ova.integration_id = 'IN24110001643810' 
           AND ova.option_name = 'states')
    LOOP*/
        -- Segundo bucle: inserta 11,000 registros por cada valor de opción
        FOR i IN 1..10000 LOOP 
            INSERT INTO sl.int_opt_val_attributes(
                value_attribute_id,
                integration_id,
                option_value_id,
                attribute_key,
                attribute_value,
                option_name
            )
            VALUES(
                sl.app_gen_entity_key('int_opt_val_attributes'),  -- Generación de clave única
                'IN24100000021955',                                -- ID de integración
                'OV24110001344055',                               -- Valor de opción del primer bucle
                'tp_account_id',                                   -- Clave del atributo
                'cbeltran' || i,                                   -- Valor del atributo concatenado con el contador
                'states'                                           -- Nombre de la opción
            );
        END LOOP;  -- Fin del bucle de 11,000 inserciones
    --END LOOP;  -- Fin del bucle que recorre las filas de la consulta

END;
$$;




 SELECT 
    *--COUNT(distinct attribute_value )
FROM
    sl.int_opt_val_attributes ova
WHERE 
    ova.integration_id = 'IN24100000021955'
--and ova.option_value_id = 'OV24100000021964'
and ova.attribute_value  = 'cbeltran1'
order by 
    ova.option_value_id;