DO
$$
BEGIN

    IF NOT EXISTS (
        SELECT
            1
        FROM
            information_schema.constraint_column_usage p
        WHERE
            p.table_name      = 'int_widgets'
        AND p.constraint_name = 'fk_int_widget_attributes_int_widgets_widget_reference_id')
    THEN
        ALTER TABLE IF EXISTS sl.int_widget_attributes
            ADD CONSTRAINT fk_int_widget_attributes_int_widgets_widget_reference_id
            FOREIGN KEY (attribute_reference_id
                       , integration_id)
            REFERENCES sl.int_widgets(widget_id
                                    , integration_id);
    END IF;

END;
$$;
     
/*
ALTER TABLE sl.int_widget_attributes
DROP CONSTRAINT fk_int_widget_attributes_int_widgets_widget_reference_id;
*/