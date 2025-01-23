SELECT CARDINALITY(ARRAY['a', 'b', 'c']) AS cantidad_elementos;

SELECT CARDINALITY(ARRAY['']) AS cantidad_elementos;

SELECT CARDINALITY(ARRAY[]::TEXT[]) AS cantidad_elementos;