-- STAGE

--p_account_id
--p_integration_id
--p_option_values_widgets
SELECT COUNT(1) FROM ( -- 1461


SELECT * FROM sl.app_int_opt_val_attributes_get(
 'AC23010002859288'
,'IN24110023495456'
,'[
  {
    "option_value": "FL",
    "widget_id": "WI24110023495457"
  },
  {
    "option_value": "H5619-046-000-2025",
    "widget_id": "WI24110023495459"
  },
  {
    "option_value": "DentalBenefitCal",
    "widget_id": "WI24110023495462"
  },
  {
    "option_value": "DentVisHearBenefitCal",
    "widget_id": "WI24110023495464"
  }
]')


) AS dat
; -- 41s - 42 registros

-- 1.24 seg los primeros 200 reg


-- DEV
SELECT COUNT(1) FROM ( -- 1461

SELECT * FROM sl.app_int_opt_val_attributes_get_opt(
 'AC23020000153554'
,'IN24110001394914'
,'[
  {
    "option_value": "FL",
    "widget_id": "WI24110001394915"
  }
]')

) AS dat
; -- 41s - 42 registros
-- 41s - 42 registros


-- SELECT * FROM sl.account_integrations
-- SELECT * FROM sl.int_widgets WHERE integration_id = 'IN24110001394914'



'[
  {
    "option_value": "FL",
    "widget_id": "WI24110023495457"
  },
  {
    "option_value": "H5619-046-000-2025",
    "widget_id": "WI24110023495459"
  },
  {
    "option_value": "DentalBenefitCal",
    "widget_id": "WI24110023495462"
  },
  {
    "option_value": "DentVisHearBenefitCal",
    "widget_id": "WI24110023495464"
  }
]'


SELECT * FROM sl.int_options
SELECT * FROM int_option_values