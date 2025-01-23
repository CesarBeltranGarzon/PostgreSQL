DO $$
DECLARE

    v_integration_id  TEXT   := 'IN24110001643810';
    v_option_name     TEXT   := 'states';

BEGIN       

    WITH cte_data_id AS (
        SELECT 
            ovf.option_value_id 
        FROM (
            SELECT 
                iov.integration_id
              , iov.option_value_id 
              , iov.option_value 
              , iov.option_value_text 
              , iov.option_name
              , iov.value_version 
              , iov.value_minor_version
              , MAX(iov.value_version) 
                    OVER (PARTITION BY iov.integration_id
                                     , iov.option_name) AS max_value_version
              , MAX(iov.value_minor_version) 
                    OVER (PARTITION BY iov.integration_id
                                     , iov.value_version
                                     , iov.option_name
                                     , iov.option_value) AS max_value_minor_version
            FROM 
                sl.int_option_values iov
            WHERE 
                iov.integration_id::BPCHAR = v_integration_id::BPCHAR
            AND iov.option_name::TEXT      = v_option_name::TEXT
        ) AS ovf
        WHERE 
            ovf.value_version::INT       = ovf.max_value_version::INT
        AND ovf.value_minor_version::INT = ovf.max_value_minor_version::INT
    )
    , cte_delete_attributes AS (
        DELETE 
        FROM 
            sl.int_opt_val_attributes ova
        WHERE 
            NOT EXISTS (
                SELECT 
                    1 
                FROM 
                    cte_data_id ovi
                WHERE 
                    ova.option_value_id::BPCHAR = ovi.option_value_id::BPCHAR
        )
    RETURNING ova.option_value_id
    )
    DELETE 
    FROM 
        sl.int_option_values iov
    WHERE 
        NOT EXISTS (
            SELECT 
                1 
            FROM 
                cte_data_id cdi
            WHERE 
                iov.option_value_id::BPCHAR = cdi.option_value_id::BPCHAR
    );     

END $$;