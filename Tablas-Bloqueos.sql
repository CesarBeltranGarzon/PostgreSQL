SELECT  
            det.request_id
          , det.integration_id
          -- Calculate the group number within each integration_id
          , FLOOR((ROW_NUMBER() OVER ( PARTITION BY det.integration_id
                                       ORDER BY det.request_id
                                     ) - 1
                  ) / :p_batch_size
                 ) + 1 AS group_number
        FROM 
            sl.option_values_att_batch_details det
        WHERE
            det.batch_id IS NULL
