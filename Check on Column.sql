DO $$
BEGIN
    IF NOT EXISTS (
        SELECT
            *
        FROM
            information_schema.constraint_column_usage p
        WHERE
            p.table_name::TEXT      = 'int_widget_attributes'::TEXT
        AND p.constraint_name::TEXT = 'ck_attribute_reference_id_not_null'::TEXT)
    THEN
        ALTER TABLE IF EXISTS sl.int_widget_attributes
            ADD CONSTRAINT ck_attribute_reference_id_not_null
            CHECK (NOT (attribute_key_source = 'WIDGET_ID' AND attribute_reference_id IS NULL));
    END IF;
END $$;

SELECT * FROM sl.int_widget_attributes 

--ALTER TABLE sl.int_widget_attributes DROP CONSTRAINT ck_attribute_refer_id_not_null;


UPDATE sl.int_widget_attributes  SET attribute_reference_id = NULL WHERE widget_attribute_id = 'WA24100000552694'

UPDATE sl.int_widget_attributes  
   SET attribute_key_source = 'WIDGET_ID'
     , attribute_reference_id = NULL 
 WHERE widget_attribute_id = 'WA24100000552694'
 
UPDATE sl.int_widget_attributes  
   SET attribute_key_source = 'WIDGET_ID'
     , attribute_reference_id = 'WI24060000002033' 
 WHERE widget_attribute_id = 'WA24100000552694'

INSERT INTO sl.int_widget_attributes (
        widget_attribute_id
      , widget_id
      , integration_id
      , option_name
      , attribute_key
      , attribute_key_source
      --, attribute_reference_id
    ) VALUES (
        sl.app_gen_entity_key('int_widget_attributes')
      , 'WI24100000552693'
      , 'IN24100000552690'
      , 'plans'
      , 'campaign_tag'
      , 'SESSION_DATA'
      --, 'WI24060000001970'
    ); 

   INSERT INTO sl.int_widget_attributes (
        widget_attribute_id
      , widget_id
      , integration_id
      , option_name
      , attribute_key
      , attribute_key_source
      --, attribute_reference_id
    ) VALUES (
        sl.app_gen_entity_key('int_widget_attributes')
      , 'WI24100000552693'
      , 'IN24100000552690'
      , 'plans'
      , 'campaign_tag'
      , 'WIDGET_ID'
      --, 'WI24060000001970'
    ); 
   
END
 
--WA24100000552694
--TEMPLATE_DATA
--WIDGET_ID