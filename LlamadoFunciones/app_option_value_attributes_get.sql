SELECT * 
  FROM sl.app_option_value_attributes_get(
     'AC01010000000000'
   , 'AC15100025754944'
   , 'IN24120006088710'
   , 'WI24120006088713'
   , '[]');

 SELECT * FROM sl.app_int_opt_val_attributes_get('AC15100025754944', 'IN24120006088710', '[{"widget_id":"WI24120006088713","option_value":"H1019-144-000-2025"}]')
  
select * 
from int_option_values iov 
where integration_id = 'IN24120006088710' 
and option_name = 'plans' 
and option_value = 'H1019-144-000-2025' 
order by option_value_id desc;

-- repetido H5619-121-000-2025
--SELECT option_value, COUNT(1)
--FROM (
-- Procedures's Query
SELECT
        dat.widget_id
      , dat.option_name
      , dat.option_label
      , dat.option_value
      , dat.value_version
      , dat.value_minor_version
    FROM (
        SELECT DISTINCT
            ios.widget_id
          , ios.option_name
          , ova.option_value_text       AS option_label
          , ova.option_value
          , ova.max_value_version       AS value_version
          , ova.max_value_minor_version AS value_minor_version
          , COUNT(ova.attribute_key) 
                        OVER (PARTITION BY ova.option_value_id
                                         , ova.option_name) AS val_att_counter
          , af.json_att_counter
        FROM (
            SELECT
                af->>'attribute_key'    AS attribute_key
              , af->>'attribute_value'  AS attribute_value
              , COUNT(af->>'attribute_key') 
                    OVER()              AS json_att_counter 
            FROM
                JSONB_ARRAY_ELEMENTS(:p_attribute_filters) AS af
        ) AS af
        FULL OUTER JOIN (
            SELECT 
                ov.integration_id
              , ov.option_name
              , ov.option_value_id
              , ova.attribute_key
              , ova.attribute_value
              , ov.max_value_version
              , ov.max_value_minor_version
              , ov.option_value_text
              , ov.option_value
            FROM(
            --Getting the option_value_ids we would need to check at sl.int_opt_val_attributes
            --when is needed (when p_attribute_filters IS NOT NULL)
                SELECT  
                    iov.integration_id
                  , iov.option_name
                  , iov.option_value_id
                  , mx.max_value_version
                  , mx.max_value_minor_version
                  , iov.option_value_text
                  , iov.option_value
                FROM 
                    sl.int_option_values AS iov                 
                --Using a subquery to group the resultset for the latest max_value_version
                --and latest max_minor_version. This will be used later.
                JOIN(
                    SELECT
                        iov.integration_id
                      , iov.option_name
                      , iov.option_value
                      , MAX(iov.value_version)       AS max_value_version   
                      , MAX(iov.value_minor_version) AS max_value_minor_version  
                    FROM
                        sl.int_option_values AS iov
                    WHERE
                        iov.integration_id::BPCHAR  = :v_integration_id::BPCHAR
                    AND iov.option_name::TEXT       = :v_option_name::TEXT
                    GROUP BY 
                        iov.integration_id
                      , iov.option_name
                      , iov.option_value
                 ) AS mx
                 ON  mx.integration_id::BPCHAR       = iov.integration_id::BPCHAR
                 AND mx.option_name::TEXT            = iov.option_name::TEXT 
                 AND mx.option_value::TEXT           = iov.option_value::TEXT
                 AND mx.max_value_version::INT       = iov.value_version::INT
                 AND mx.max_value_minor_version::INT = iov.value_minor_version::INT
            ) AS ov
            LEFT JOIN(
             --Based on the option_value_ids obtained above, get the attributes info
                SELECT
                    xva.integration_id
                  , xva.option_name
                  , xva.option_value_id
                  , xva.attribute_key
                  , xva.attribute_value                  
                FROM
                  sl.int_opt_val_attributes AS xva                  
            )AS ova
            ON  ov.integration_id::BPCHAR              = ova.integration_id::BPCHAR
            AND ov.option_name::BPCHAR                 = ova.option_name::BPCHAR
            AND ov.option_value_id::BPCHAR             = ova.option_value_id::BPCHAR
            AND JSONB_ARRAY_LENGTH(:p_attribute_filters) <> 0
        ) AS ova
        ON (af.attribute_key::TEXT    = ova.attribute_key::TEXT
        AND af.attribute_value::TEXT  = ova.attribute_value::TEXT)
        JOIN (
            SELECT
                ios.integration_id
              , ios.option_name
              , iw.widget_id
            FROM
                sl.int_options AS ios
            JOIN (
                SELECT
                    xiw.widget_id
                  , xiw.integration_id
                  , xiw.option_name
                FROM
                    sl.int_widgets xiw
            ) AS iw
            ON ios.option_name::TEXT       = iw.option_name::TEXT
            AND ios.integration_id::BPCHAR = iw.integration_id::BPCHAR
            WHERE
                ios.integration_id::BPCHAR  = :v_integration_id::BPCHAR
            AND iw.widget_id::BPCHAR        = :p_widget_id::BPCHAR
        ) AS ios
        ON (ova.integration_id::BPCHAR  = ios.integration_id::BPCHAR
        AND ova.option_name::TEXT       = ios.option_name::TEXT)
        WHERE 
            JSONB_ARRAY_LENGTH(:p_attribute_filters) = 0
         OR af.attribute_key                        IS NOT NULL
    ) AS dat
    WHERE
        --Compare JSON input parameter counter 
        --(obtained acording the attributes sent in the JSON)
        --against a counter to the attributes table when an
        --option_value_id has set up the same attribute values
        --that are sent in the JSON p_attribute_filters
        (dat.json_att_counter::INT    = dat.val_att_counter::INT
         OR dat.json_att_counter      IS NULL)
--)
--GROUP BY option_value