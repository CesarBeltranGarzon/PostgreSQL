DO
$$
BEGIN

    IF NOT EXISTS (
      SELECT 
          1
      FROM
          sl.lookup_data_source_types dst
      WHERE 
          dst.data_source_type = 'SUGGESTION_RULES'
    )
    THEN
        INSERT INTO sl.lookup_data_source_types (
            data_source_type
          , is_manual_upload_allowed
          , is_remote_upload_allowed
        )
        VALUES(
            'SUGGESTION_RULES'
          , TRUE
          , FALSE
        );
    END IF;

END;
$$;