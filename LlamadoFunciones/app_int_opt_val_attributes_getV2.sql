SELECT * 
FROM sl.app_int_opt_val_attributes_get('AC15100025754944', 'IN24120006088710', '[{"option_value":"H1019-144-000-2025", "widget_id":"WI24120006088713"}]')

select * 
from int_option_values iov 
where integration_id = 'IN24120006088710' 
and option_name = 'plans' 
and option_value = 'H1019-144-000-2025' 
order by option_value_id desc;


-- procedure's query
WITH cte_option_values_witgets AS (
        SELECT
            jb.value ->> 'option_value' AS option_value
          , jb.value ->> 'widget_id'    AS widget_id
        FROM (
            SELECT
                j.value
            FROM
                JSONB_ARRAY_ELEMENTS(:p_option_values_widgets) AS j
        ) AS jb
    )
    SELECT
        dat.option_value_id
      , dat.option_value
      , dat.option_name
      , dat.attribute_key
      , dat.attribute_value
      , dat.value_version
      , dat.version_ts
      , iw.widget_id
    FROM (
        SELECT
            ai.integration_id
        FROM
            sl.account_integrations AS ai
        WHERE
            ai.account_id::BPCHAR       = :p_account_id::BPCHAR
        AND ai.integration_id::BPCHAR   = :p_integration_id::BPCHAR
    ) AS ai
    JOIN (
        SELECT
            iw.integration_id
          , iw.option_name
          , md.option_value
          , iw.widget_id
        FROM
            sl.int_widgets AS iw
        JOIN 
            cte_option_values_witgets AS md
        ON (iw.widget_id::BPCHAR = md.widget_id::BPCHAR)
        WHERE
            iw.is_active IS TRUE
    ) AS iw
    ON (ai.integration_id::BPCHAR = iw.integration_id::BPCHAR)
    JOIN (
        SELECT 
            ov.option_value_id
          , ov.integration_id
          , ov.option_name
          , ov.option_value
          , ov.max_value_version  AS value_version
          , ov.version_ts   
          , ova.attribute_key
          , ova.attribute_value         
        FROM (
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
              , iov.version_ts
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
                    iov.integration_id::BPCHAR  = :p_integration_id::BPCHAR
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
        JOIN(
        --Based on the option_value_ids obtained above, get the attributes info
            SELECT
                xva.integration_id
              , xva.option_name
              , xva.option_value_id
              , xva.attribute_key
              , xva.attribute_value                  
            FROM
                sl.int_opt_val_attributes AS xva                  
        ) AS ova
        ON  ov.integration_id::BPCHAR              = ova.integration_id::BPCHAR
        AND ov.option_name::BPCHAR                 = ova.option_name::BPCHAR
        AND ov.option_value_id::BPCHAR             = ova.option_value_id::BPCHAR
    ) AS dat
    ON (iw.integration_id::BPCHAR   = dat.integration_id::BPCHAR
    AND iw.option_name::TEXT        = dat.option_name::TEXT
    AND iw.option_value::TEXT       = dat.option_value::TEXT)