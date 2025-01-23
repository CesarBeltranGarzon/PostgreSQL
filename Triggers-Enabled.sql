--O(Habilitado) D(Deshabilitado)
SELECT t.tgname AS trigger_name,
       t.tgenabled AS trigger_status,
       c.relname AS table_name
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
WHERE t.tgname = 'trg_int_widget_attributes_before';


ALTER TABLE sl.int_widget_attributes DISABLE TRIGGER trg_int_widget_attributes_before;

DROP TRIGGER trg_int_widget_attributes_before ON sl.int_widget_attributes;