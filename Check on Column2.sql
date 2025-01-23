DO $$
BEGIN

    ALTER TABLE IF EXISTS sl.int_suggestion_rule_conditions
        ALTER COLUMN attribute_value DROP NOT NULL;

    ALTER TABLE IF EXISTS sl.zlog_int_suggestion_rule_conditions
        ALTER COLUMN attribute_value DROP NOT NULL;

    IF NOT EXISTS (
        SELECT
            1
        FROM
            information_schema.constraint_column_usage p
        WHERE
            p.table_name::TEXT      = 'int_suggestion_rule_conditions'::TEXT
        AND p.constraint_name::TEXT = 'ck_attribute_value_operator_values'::TEXT)
    THEN
        ALTER TABLE IF EXISTS sl.int_suggestion_rule_conditions
            ADD CONSTRAINT ck_attribute_value_operator_values
            CHECK (
                (attribute_value IS NULL AND operator = 'nn')
             OR (attribute_value IS NOT NULL AND operator != 'nn')
            );
    END IF;
END $$;

--SELECT * FROM sl.int_suggestion_rule_conditions
-- ALTER TABLE sl.int_suggestion_rule_conditions DROP CONSTRAINT ck_attribute_value_operator_values;
