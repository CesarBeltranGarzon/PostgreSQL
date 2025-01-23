select * from app_acct_integrations_data_get('AC15100025754944')



select * from app_acct_integrations_data_get('AC24030000142942')


SELECT 
    ai.account_id 
  , ai.integration_id
  , COUNT(iova.attribute_key)
FROM 
    sl.account_integrations ai 
JOIN 
    sl.int_opt_val_attributes iova 
ON (ai.integration_id = iova.integration_id)
GROUP BY  
    ai.account_id 
    , ai.integration_id