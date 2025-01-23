-- Query para volver JSON en tabla
-- Cambiar contenido del JSON

SELECT
            af->>'attribute_key'    AS attribute_key
          , af->>'attribute_value'  AS attribute_value
        FROM
            JSONB_ARRAY_ELEMENTS('[
            {
                "attribute_key":"state",
                "attribute_value":"Florida"
            },
            {
                "attribute_key":"state",
                "attribute_value":"Georgia"
            }
        ]') AS af