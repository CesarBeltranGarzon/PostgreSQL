SELECT ARRAY(
        SELECT
            iw.option_name
        FROM
            sl.account_integrations AS ai
        JOIN
            sl.int_widgets AS iw
        ON (ai.integration_id = iw.integration_id)
        WHERE
            ai.account_id = 'AC15100025754944'
        AND ai.integration_id = 'IN24030000000007'
        AND iw.widget_id = 'WI24030000000009'
    )


    end;