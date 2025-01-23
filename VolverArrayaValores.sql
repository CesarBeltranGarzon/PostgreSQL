SELECT
        ARRAY_AGG(DISTINCT iov.option_value) AS option_values
    FROM 
        sl.int_option_values AS iov
    WHERE
        iov.integration_id  = 'IN24030000000007'
    AND iov.option_name     = 'states'
    
--
    
SELECT
        STRING_AGG(DISTINCT iov.option_value, ',') AS option_values
    FROM 
        sl.int_option_values AS iov
    WHERE
        iov.integration_id  = 'IN24030000000007'
    AND iov.option_name     = 'states'

--
    
SELECT ARRAY(
        SELECT DISTINCT 
            iov.option_value
        FROM 
            sl.int_option_values AS iov
        WHERE
            iov.integration_id  = 'IN24030000000007'
        AND iov.option_name     = 'states'
    );
    
end;