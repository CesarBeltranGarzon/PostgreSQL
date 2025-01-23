/*
 p_account_id: AC15100025754944
 p_integration_id: IN24120006088710
 data_source_id: {"data_source_id":"DS24120006937890"}
*/

-- Adding filter by: 
  -- ingestion_status(processing, completed, error)
  -- date range
  -- uploaded file name, integration name, or ruleset name

/*
 Ejemplo de Cristian
 
SELECT * FROM sl.app_int_data_source_ingestions_get(?,?,?,?)"
array:4 [
  0 => "AC15100025754944"
  1 => "IN24120006088710"
  2 => "{"is_active":true,"query":"hola","start_date":"2024-12-02","end_date":"2024-12-05","data_source_type":null}"
  3 => "{"limit":10,"offset":0,"sort_order":"DESC","sort_column":"ingestion_status"}"
]
*/

-- 
SELECT * FROM sl.app_int_data_source_ingestions_get(
 'AC15100025754944'
,'IN24120006088710'
,'{"data_source_id":null}' --,'{"is_active":true,"query":"hola","start_date":"2024-12-02","end_date":"2024-12-05","data_source_type":null}'
,'{"limit":1000,"offset":0,"sort_order":"DESC","sort_column":"ingestion_status"}' --,'{"sort_order":"DESC"}'
)

SELECT * FROM sl.app_int_data_source_ingestions_get(
 'AC15100025754944'
,'IN24120006088710'
,'{"query":"Dev Sudo Shurtado","start_date":"2024-12-02","end_date":"2024-12-17","status":null}' --,'{"is_active":true,"query":"hola","start_date":"2024-12-02","end_date":"2024-12-05","data_source_type":null}'
,'{"limit":10,"offset":0,"sort_order":"DESC","sort_column":"ingestion_status"}' --,'{"sort_order":"DESC"}' --file_upload_ts, ingestion_status
)

SELECT * FROM sl.app_int_data_source_ingestions_get_x(
 'AC15100025754944'
,'IN24120006088710'
,'{"query":null,"start_date":null,"end_date":null}' --,'{"is_active":true,"query":"hola","start_date":"2024-12-02","end_date":"2024-12-05","data_source_type":null}'
,'{"limit":10,"offset":0,"sort_order":null,"sort_column":null}' --,'{"sort_order":"DESC"}' --file_upload_ts, ingestion_status
)

SELECT * FROM sl.int_data_source_ingestions

SELECT
        dsi.data_source_id
      , ds.label
      , dsi.option_name
      , dsi.file_name
      , (dsi.failed_rows + dsi.success_rows) AS file_total_rows
      , dsi.failed_rows
      , dsi.success_rows
      , dsi.ingestion_status
      , dsi.file_upload_ts
      , dsi.upload_errors_file
      , COUNT (*) OVER ()::INT AS total_rows
    FROM
        sl.int_data_source_ingestions dsi
    JOIN (
        SELECT
            xds.data_source_id
          , xds.integration_id
          , xds.label
        FROM
            sl.int_data_sources xds
        JOIN (
            SELECT
                ai.integration_id
            FROM
                sl.account_integrations ai
            WHERE
                ai.account_id::BPCHAR     = :p_account_id::BPCHAR
            AND ai.integration_id::BPCHAR = :p_integration_id::BPCHAR
        ) AS ais
        ON xds.integration_id = ais.integration_id
    ) AS ds
    ON dsi.data_source_id::BPCHAR = ds.data_source_id::BPCHAR
    WHERE
    -- Filter by the data_source_id field if provided in p_filter_by
    (dsi.data_source_id                    = (:p_filter_by ->> 'data_source_id')
    OR (:p_filter_by ->> 'data_source_id')  IS NULL)
    AND dsi.is_active                      IS TRUE
    ORDER BY
        CASE WHEN (:p_query_params ->> 'sort_order')::TEXT = 'DESC'::TEXT
             THEN dsi.file_upload_ts
        END DESC,
        CASE WHEN (:p_query_params ->> 'sort_order')::TEXT = 'ASC'::TEXT
             THEN dsi.file_upload_ts
        END ASC
    LIMIT
        (:p_query_params ->> 'limit')::INTEGER
    OFFSET
        (:p_query_params ->> 'offset')::INTEGER;