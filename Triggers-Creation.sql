DROP TRIGGER IF EXISTS sl.trg_int_widget_attributes_before ON sl.int_widget_attributes;

DROP FUNCTION IF EXISTS sl.trg_int_widget_attributes_before (
);

CREATE OR REPLACE FUNCTION sl.trg_int_widget_attributes_before (
)

RETURNS trigger AS
$body$
--------------------------------------------------------------------------------
-- Function:   trg_int_widget_attributes_before
--
-- Type:       Trigger function
--
-- Author:     Julian Hernandez
--
-- Desc:       Forces the attribute_reference_id column to be populated when a
--             record with WIDGET_ID as attribute_key_source is inserted.
--
-- Owner:      sluser
--
--------------------------------------------------------------------------------
-- Date        Initials    Sprint      Task        Desc
--------------------------------------------------------------------------------
-- 2024-10-23  jhernandez  39.1      B-36387       - Initial cut
--------------------------------------------------------------------------------
BEGIN

    IF (NEW.attribute_key_source = 'WIDGET_ID'
    AND NEW.attribute_reference_id IS NULL)
    THEN
        RAISE EXCEPTION 'THE ATTRIBUTE REFERENCE ID CANNOT BE NULL WHEN THE
            ATTRIBUTE KEY SOURCE IS [%].'
            , NEW.attribute_key_source;
    END IF;

    RETURN NEW;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY DEFINER
COST 100;

ALTER FUNCTION sl.trg_int_widget_attributes_before (
) OWNER to sluser;

DO
$$
BEGIN
    --Create the trigger if it doesn't exist
    IF NOT EXISTS(SELECT *
                  FROM   information_schema.triggers
                  WHERE  event_object_table = 'int_widget_attributes'
                  AND    trigger_name       = 'trg_int_widget_attributes_before')
    THEN
        CREATE TRIGGER sl.trg_int_widget_attributes_before
            BEFORE INSERT OR UPDATE
            ON sl.int_widget_attributes
            FOR EACH ROW
            EXECUTE PROCEDURE sl.trg_int_widget_attributes_before();
    END IF;

END;
$$;