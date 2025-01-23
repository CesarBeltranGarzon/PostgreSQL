-- Le adicione test al final porque cree procediento para porbar y a la tabla temporal le puse test al final, pero es la funcion correcta.
-- Esto para ejecutar procedimiento parte por parte, ya que si lo ejecuto completo me hace INSERTS

-- 0. Tabla temporal a consultar
SELECT * FROM sl.temp_variable_data_test
--DROP TABLE sl.temp_variable_data_test
-- SELECT * FROM sl.account_integrations where integration_name = 'Humana_SudoHPAS_2025'

-- 1. Carga Tabla temporal
CREATE OR REPLACE FUNCTION sl.app_int_variable_data_refresh_test(p_int_variable_data jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER COST 10
AS $function$

BEGIN  


CREATE TABLE sl.temp_variable_data_test
    --ON COMMIT DROP
    AS
    SELECT
        ai.integration_id
      , p.integration_name
      , p.option_name
      , p.option_value
      , p.option_value_text
      , p.attribute_key
      , p.attribute_value
    FROM(
        SELECT
            y.integration_name
          , y.account_id    -- cesarb
          , y.option_name
          , y.option_value
          , y.option_value_text
          , z.attribute_key
          , z.attribute_value
        FROM (
            SELECT
                --Divide initial JSON object based on the amount of
                --internal objects it has
                JSONB_ARRAY_ELEMENTS(p.json_data) AS variable_data_per_integration
              , p.json_data
            FROM (
                SELECT
                    p_int_variable_data AS json_data
            ) AS p
        ) AS w
        JOIN LATERAL(
            --Use JSONB_EACH to extract variable data from
            --the internal JSON ARRAY
            SELECT
                p.key   AS json_key
              , p.value AS json_values
            FROM
                JSONB_EACH(w.variable_data_per_integration) AS p
        ) AS x
        ON TRUE
        JOIN LATERAL (
            --Map static data from the JSON received as input
            --static data--> integration_name, option_value,
            --option_value_text
            SELECT
                p.option_name
              , p.option_value
              , p.option_value_text
              , p.integration_name
              , p.account_id         -- cesarb
            FROM (
                --Extracts static data from the JSON array indexes
                SELECT
                    JSONB_EXTRACT_PATH_TEXT(w.variable_data_per_integration, 'option_name')       AS option_name
                  , JSONB_EXTRACT_PATH_TEXT(w.variable_data_per_integration, 'option_value')      AS option_value
                  , JSONB_EXTRACT_PATH_TEXT(w.variable_data_per_integration, 'option_value_text') AS option_value_text
                  , JSONB_EXTRACT_PATH_TEXT(w.variable_data_per_integration, 'integration_name')  AS integration_name
                  , JSONB_EXTRACT_PATH_TEXT(w.variable_data_per_integration, 'account_id')        AS account_id  -- Cesarb
            ) AS p
        )AS y
        ON TRUE
        JOIN LATERAL(
            --Map into columns (attribute_key | attribute_value)
            --the data extracted from the internal object at
            --JSON input
            SELECT DISTINCT
                p ->> 'attribute_key'   AS attribute_key
              , p ->> 'attribute_value' AS attribute_value
            FROM
                JSONB_ARRAY_ELEMENTS(
                    x.json_values
            ) AS p
        )AS z
        ON TRUE
        WHERE
            --Group data based on static data for each node
            w.variable_data_per_integration ->>'option_value' = y.option_value
            --Extract variable data from the object "attributes" for each
            --static item grouped previously
        AND x.json_key                                        = 'attributes'
    ) AS p
    JOIN (
        SELECT
            xai.integration_id
          , xai.integration_name
          , xai.account_id  -- cesarb
        FROM
            sl.account_integrations xai
    ) AS ai
    ON (p.account_id::BPCHAR     = ai.account_id::BPCHAR  -- cesarb
    AND p.integration_name::TEXT = ai.integration_name::TEXT)
    JOIN (
        SELECT
            xio.integration_id
          , xio.option_name
        FROM
            sl.int_options xio
    ) AS io
    ON io.integration_id::BPCHAR = ai.integration_id::BPCHAR
    AND io.option_name::TEXT     = p.option_name::TEXT;

END;
$function$
;


-- 2.Ejecutar cargue tabla temporal

SELECT * FROM sl.app_int_variable_data_refresh_test(
'[
  {
    "account_id": "AC15100025754944",
    "integration_name": "Humana_SudoHPAS_2025",
    "option_name": "plans",
    "option_value": "H0028-007-000-2025",
    "option_value_text": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)",
    "attributes": [
      {
        "attribute_key": "XrayPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "XrayCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "WorldwideEmerg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionConOrEyegLimit",
        "attribute_value": "1 pair(s) per year"
      },
      {
        "attribute_key": "VisionConOrEyegPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionConOrEyegCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VisionFitting",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionAnExamLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "VisionAnExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionAnExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VirtVisitMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitUrgPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitUrgCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitSpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitSpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VirtVisitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "Travel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "TransportVendor",
        "attribute_value": "SafeRide Health"
      },
      {
        "attribute_key": "TransportLimit",
        "attribute_value": "50"
      },
      {
        "attribute_key": "TransportTrips",
        "attribute_value": "48 trip(s) per year"
      },
      {
        "attribute_key": "TransportCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "TransportCode",
        "attribute_value": "TRN049"
      },
      {
        "attribute_key": "SpecMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "SpecReferral",
        "attribute_value": "No referral"
      },
      {
        "attribute_key": "SpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "PCPPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PCPCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "Preventative",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresVBID",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresDrugDeduct",
        "attribute_value": "590"
      },
      {
        "attribute_key": "PresDrugStanTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugStanTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugRetTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugRetTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Premium",
        "attribute_value": "50.6"
      },
      {
        "attribute_key": "PlanDeduct",
        "attribute_value": "257"
      },
      {
        "attribute_key": "PartBValue",
        "attribute_value": "5"
      },
      {
        "attribute_key": "OutpatPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "OutpatCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "MealBenefit",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "MOOP",
        "attribute_value": "9350"
      },
      {
        "attribute_key": "LabworkPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "LabworkCost",
        "attribute_value": "30"
      },
      {
        "attribute_key": "InsulinCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "InpatientPeriod",
        "attribute_value": "per admission"
      },
      {
        "attribute_key": "InpatientPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "InpatientCost",
        "attribute_value": "2185"
      },
      {
        "attribute_key": "IncentiveProg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Immunizations",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCUnspent",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCFreq",
        "attribute_value": "per month"
      },
      {
        "attribute_key": "HHOCValue",
        "attribute_value": "155"
      },
      {
        "attribute_key": "HearAidLimit",
        "attribute_value": "1 per ear per year"
      },
      {
        "attribute_key": "HearAidCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearFitLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearFitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearFitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearingLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearAnnualLimit",
        "attribute_value": "per ear per year"
      },
      {
        "attribute_key": "HearingAnnual",
        "attribute_value": "2000"
      },
      {
        "attribute_key": "FitnessCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "EmergCoverage",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentXray",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentSurgery",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRootCanal",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRecement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentPeriodont",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentFillingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentFillingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentExtract",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentExamLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentEmPain",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureRel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureAdj",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDenture",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDeepClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCrown",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCode",
        "attribute_value": "DEN142"
      },
      {
        "attribute_key": "DentCleanLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentalAnnualLimit",
        "attribute_value": "per year"
      },
      {
        "attribute_key": "DentalAnnual",
        "attribute_value": "5000"
      },
      {
        "attribute_key": "CareManagement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "AdvImagPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "AdvImagCost",
        "attribute_value": "300"
      },
      {
        "attribute_key": "SNPPopulation",
        "attribute_value": "Medicare Non Zero Cost-sharing"
      },
      {
        "attribute_key": "SNP",
        "attribute_value": "Dual-Eligible"
      },
      {
        "attribute_key": "ProdType",
        "attribute_value": "HMO"
      },
      {
        "attribute_key": "Name",
        "attribute_value": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)"
      },
      {
        "attribute_key": "Campaign_Tag",
        "attribute_value": "All Plans excl CP PDP ISNP"
      },
      {
        "attribute_key": "PlanID",
        "attribute_value": "H0028-007-000-2025"
      },
      {
        "attribute_key": "GeoName",
        "attribute_value": "Omaha"
      },
      {
        "attribute_key": "State",
        "attribute_value": "NE"
      },
      {
        "attribute_key": "Year",
        "attribute_value": "2025"
      }
    ]
  },
  {
    "account_id": "AC15100025754944",    
    "integration_name": "Humana_SudoHPAS_2025",
    "option_name": "plans",
    "option_value": "H0028-007-000-2025",
    "option_value_text": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)",
    "attributes": [
      {
        "attribute_key": "XrayPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "XrayCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "WorldwideEmerg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionConOrEyegLimit",
        "attribute_value": "1 pair(s) per year"
      },
      {
        "attribute_key": "VisionConOrEyegPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionConOrEyegCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VisionFitting",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionAnExamLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "VisionAnExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionAnExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VirtVisitMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitUrgPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitUrgCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitSpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitSpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VirtVisitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "Travel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "TransportVendor",
        "attribute_value": "SafeRide Health"
      },
      {
        "attribute_key": "TransportLimit",
        "attribute_value": "50"
      },
      {
        "attribute_key": "TransportTrips",
        "attribute_value": "48 trip(s) per year"
      },
      {
        "attribute_key": "TransportCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "TransportCode",
        "attribute_value": "TRN049"
      },
      {
        "attribute_key": "SpecMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "SpecReferral",
        "attribute_value": "No referral"
      },
      {
        "attribute_key": "SpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "PCPPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PCPCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "Preventative",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresVBID",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresDrugDeduct",
        "attribute_value": "590"
      },
      {
        "attribute_key": "PresDrugStanTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugStanTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugRetTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugRetTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Premium",
        "attribute_value": "50.6"
      },
      {
        "attribute_key": "PlanDeduct",
        "attribute_value": "257"
      },
      {
        "attribute_key": "PartBValue",
        "attribute_value": "5"
      },
      {
        "attribute_key": "OutpatPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "OutpatCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "MealBenefit",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "MOOP",
        "attribute_value": "9350"
      },
      {
        "attribute_key": "LabworkPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "LabworkCost",
        "attribute_value": "30"
      },
      {
        "attribute_key": "InsulinCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "InpatientPeriod",
        "attribute_value": "per admission"
      },
      {
        "attribute_key": "InpatientPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "InpatientCost",
        "attribute_value": "2185"
      },
      {
        "attribute_key": "IncentiveProg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Immunizations",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCUnspent",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCFreq",
        "attribute_value": "per month"
      },
      {
        "attribute_key": "HHOCValue",
        "attribute_value": "155"
      },
      {
        "attribute_key": "HearAidLimit",
        "attribute_value": "1 per ear per year"
      },
      {
        "attribute_key": "HearAidCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearFitLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearFitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearFitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearingLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearAnnualLimit",
        "attribute_value": "per ear per year"
      },
      {
        "attribute_key": "HearingAnnual",
        "attribute_value": "2000"
      },
      {
        "attribute_key": "FitnessCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "EmergCoverage",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentXray",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentSurgery",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRootCanal",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRecement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentPeriodont",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentFillingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentFillingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentExtract",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentExamLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentEmPain",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureRel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureAdj",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDenture",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDeepClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCrown",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCode",
        "attribute_value": "DEN142"
      },
      {
        "attribute_key": "DentCleanLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentalAnnualLimit",
        "attribute_value": "per year"
      },
      {
        "attribute_key": "DentalAnnual",
        "attribute_value": "5000"
      },
      {
        "attribute_key": "CareManagement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "AdvImagPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "AdvImagCost",
        "attribute_value": "300"
      },
      {
        "attribute_key": "SNPPopulation",
        "attribute_value": "Medicare Non Zero Cost-sharing"
      },
      {
        "attribute_key": "SNP",
        "attribute_value": "Dual-Eligible"
      },
      {
        "attribute_key": "ProdType",
        "attribute_value": "HMO"
      },
      {
        "attribute_key": "Name",
        "attribute_value": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)"
      },
      {
        "attribute_key": "Campaign_Tag",
        "attribute_value": "Cross Sell excl CP"
      },
      {
        "attribute_key": "PlanID",
        "attribute_value": "H0028-007-000-2025"
      },
      {
        "attribute_key": "GeoName",
        "attribute_value": "Omaha"
      },
      {
        "attribute_key": "State",
        "attribute_value": "NE"
      },
      {
        "attribute_key": "Year",
        "attribute_value": "2025"
      }
    ]
  },
  {
    "account_id": "AC15100025754944",
    "integration_name": "Humana_SudoHPAS_2025",
    "option_name": "plans",
    "option_value": "H0028-007-000-2025",
    "option_value_text": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)",
    "attributes": [
      {
        "attribute_key": "XrayPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "XrayCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "WorldwideEmerg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionConOrEyegLimit",
        "attribute_value": "1 pair(s) per year"
      },
      {
        "attribute_key": "VisionConOrEyegPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionConOrEyegCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VisionFitting",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionAnExamLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "VisionAnExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionAnExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VirtVisitMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitUrgPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitUrgCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitSpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitSpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VirtVisitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "Travel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "TransportVendor",
        "attribute_value": "SafeRide Health"
      },
      {
        "attribute_key": "TransportLimit",
        "attribute_value": "50"
      },
      {
        "attribute_key": "TransportTrips",
        "attribute_value": "48 trip(s) per year"
      },
      {
        "attribute_key": "TransportCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "TransportCode",
        "attribute_value": "TRN049"
      },
      {
        "attribute_key": "SpecMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "SpecReferral",
        "attribute_value": "No referral"
      },
      {
        "attribute_key": "SpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "PCPPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PCPCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "Preventative",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresVBID",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresDrugDeduct",
        "attribute_value": "590"
      },
      {
        "attribute_key": "PresDrugStanTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugStanTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugRetTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugRetTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Premium",
        "attribute_value": "50.6"
      },
      {
        "attribute_key": "PlanDeduct",
        "attribute_value": "257"
      },
      {
        "attribute_key": "PartBValue",
        "attribute_value": "5"
      },
      {
        "attribute_key": "OutpatPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "OutpatCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "MealBenefit",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "MOOP",
        "attribute_value": "9350"
      },
      {
        "attribute_key": "LabworkPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "LabworkCost",
        "attribute_value": "30"
      },
      {
        "attribute_key": "InsulinCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "InpatientPeriod",
        "attribute_value": "per admission"
      },
      {
        "attribute_key": "InpatientPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "InpatientCost",
        "attribute_value": "2185"
      },
      {
        "attribute_key": "IncentiveProg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Immunizations",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCUnspent",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCFreq",
        "attribute_value": "per month"
      },
      {
        "attribute_key": "HHOCValue",
        "attribute_value": "155"
      },
      {
        "attribute_key": "HearAidLimit",
        "attribute_value": "1 per ear per year"
      },
      {
        "attribute_key": "HearAidCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearFitLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearFitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearFitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearingLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearAnnualLimit",
        "attribute_value": "per ear per year"
      },
      {
        "attribute_key": "HearingAnnual",
        "attribute_value": "2000"
      },
      {
        "attribute_key": "FitnessCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "EmergCoverage",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentXray",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentSurgery",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRootCanal",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRecement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentPeriodont",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentFillingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentFillingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentExtract",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentExamLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentEmPain",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureRel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureAdj",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDenture",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDeepClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCrown",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCode",
        "attribute_value": "DEN142"
      },
      {
        "attribute_key": "DentCleanLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentalAnnualLimit",
        "attribute_value": "per year"
      },
      {
        "attribute_key": "DentalAnnual",
        "attribute_value": "5000"
      },
      {
        "attribute_key": "CareManagement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "AdvImagPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "AdvImagCost",
        "attribute_value": "300"
      },
      {
        "attribute_key": "SNPPopulation",
        "attribute_value": "Medicare Non Zero Cost-sharing"
      },
      {
        "attribute_key": "SNP",
        "attribute_value": "Dual-Eligible"
      },
      {
        "attribute_key": "ProdType",
        "attribute_value": "HMO"
      },
      {
        "attribute_key": "Name",
        "attribute_value": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)"
      },
      {
        "attribute_key": "Campaign_Tag",
        "attribute_value": "CSNP DSNP excl CP"
      },
      {
        "attribute_key": "PlanID",
        "attribute_value": "H0028-007-000-2025"
      },
      {
        "attribute_key": "GeoName",
        "attribute_value": "Omaha"
      },
      {
        "attribute_key": "State",
        "attribute_value": "NE"
      },
      {
        "attribute_key": "Year",
        "attribute_value": "2025"
      }
    ]
  },
  {
    "account_id": "AC15100025754944",
    "integration_name": "Humana_SudoHPAS_2025",
    "option_name": "plans",
    "option_value": "H0028-007-000-2025",
    "option_value_text": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)",
    "attributes": [
      {
        "attribute_key": "XrayPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "XrayCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "WorldwideEmerg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionConOrEyegLimit",
        "attribute_value": "1 pair(s) per year"
      },
      {
        "attribute_key": "VisionConOrEyegPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionConOrEyegCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VisionFitting",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionAnExamLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "VisionAnExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionAnExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VirtVisitMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitUrgPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitUrgCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitSpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitSpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VirtVisitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "Travel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "TransportVendor",
        "attribute_value": "SafeRide Health"
      },
      {
        "attribute_key": "TransportLimit",
        "attribute_value": "50"
      },
      {
        "attribute_key": "TransportTrips",
        "attribute_value": "48 trip(s) per year"
      },
      {
        "attribute_key": "TransportCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "TransportCode",
        "attribute_value": "TRN049"
      },
      {
        "attribute_key": "SpecMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "SpecReferral",
        "attribute_value": "No referral"
      },
      {
        "attribute_key": "SpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "PCPPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PCPCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "Preventative",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresVBID",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresDrugDeduct",
        "attribute_value": "590"
      },
      {
        "attribute_key": "PresDrugStanTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugStanTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugRetTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugRetTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Premium",
        "attribute_value": "50.6"
      },
      {
        "attribute_key": "PlanDeduct",
        "attribute_value": "257"
      },
      {
        "attribute_key": "PartBValue",
        "attribute_value": "5"
      },
      {
        "attribute_key": "OutpatPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "OutpatCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "MealBenefit",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "MOOP",
        "attribute_value": "9350"
      },
      {
        "attribute_key": "LabworkPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "LabworkCost",
        "attribute_value": "30"
      },
      {
        "attribute_key": "InsulinCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "InpatientPeriod",
        "attribute_value": "per admission"
      },
      {
        "attribute_key": "InpatientPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "InpatientCost",
        "attribute_value": "2185"
      },
      {
        "attribute_key": "IncentiveProg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Immunizations",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCUnspent",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCFreq",
        "attribute_value": "per month"
      },
      {
        "attribute_key": "HHOCValue",
        "attribute_value": "155"
      },
      {
        "attribute_key": "HearAidLimit",
        "attribute_value": "1 per ear per year"
      },
      {
        "attribute_key": "HearAidCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearFitLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearFitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearFitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearingLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearAnnualLimit",
        "attribute_value": "per ear per year"
      },
      {
        "attribute_key": "HearingAnnual",
        "attribute_value": "2000"
      },
      {
        "attribute_key": "FitnessCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "EmergCoverage",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentXray",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentSurgery",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRootCanal",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRecement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentPeriodont",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentFillingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentFillingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentExtract",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentExamLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentEmPain",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureRel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureAdj",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDenture",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDeepClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCrown",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCode",
        "attribute_value": "DEN142"
      },
      {
        "attribute_key": "DentCleanLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentalAnnualLimit",
        "attribute_value": "per year"
      },
      {
        "attribute_key": "DentalAnnual",
        "attribute_value": "5000"
      },
      {
        "attribute_key": "CareManagement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "AdvImagPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "AdvImagCost",
        "attribute_value": "300"
      },
      {
        "attribute_key": "SNPPopulation",
        "attribute_value": "Medicare Non Zero Cost-sharing"
      },
      {
        "attribute_key": "SNP",
        "attribute_value": "Dual-Eligible"
      },
      {
        "attribute_key": "ProdType",
        "attribute_value": "HMO"
      },
      {
        "attribute_key": "Name",
        "attribute_value": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)"
      },
      {
        "attribute_key": "Campaign_Tag",
        "attribute_value": "DSNP excl CP"
      },
      {
        "attribute_key": "PlanID",
        "attribute_value": "H0028-007-000-2025"
      },
      {
        "attribute_key": "GeoName",
        "attribute_value": "Omaha"
      },
      {
        "attribute_key": "State",
        "attribute_value": "NE"
      },
      {
        "attribute_key": "Year",
        "attribute_value": "2025"
      }
    ]
  },
  {
    "account_id": "AC15100025754944",
    "integration_name": "Humana_SudoHPAS_2025",
    "option_name": "plans",
    "option_value": "H0028-007-000-2025",
    "option_value_text": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)",
    "attributes": [
      {
        "attribute_key": "XrayPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "XrayCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "WorldwideEmerg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionConOrEyegLimit",
        "attribute_value": "1 pair(s) per year"
      },
      {
        "attribute_key": "VisionConOrEyegPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionConOrEyegCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VisionFitting",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionAnExamLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "VisionAnExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionAnExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VirtVisitMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitUrgPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitUrgCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitSpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitSpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VirtVisitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "Travel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "TransportVendor",
        "attribute_value": "SafeRide Health"
      },
      {
        "attribute_key": "TransportLimit",
        "attribute_value": "50"
      },
      {
        "attribute_key": "TransportTrips",
        "attribute_value": "48 trip(s) per year"
      },
      {
        "attribute_key": "TransportCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "TransportCode",
        "attribute_value": "TRN049"
      },
      {
        "attribute_key": "SpecMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "SpecReferral",
        "attribute_value": "No referral"
      },
      {
        "attribute_key": "SpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "PCPPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PCPCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "Preventative",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresVBID",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresDrugDeduct",
        "attribute_value": "590"
      },
      {
        "attribute_key": "PresDrugStanTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugStanTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugRetTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugRetTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Premium",
        "attribute_value": "50.6"
      },
      {
        "attribute_key": "PlanDeduct",
        "attribute_value": "257"
      },
      {
        "attribute_key": "PartBValue",
        "attribute_value": "5"
      },
      {
        "attribute_key": "OutpatPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "OutpatCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "MealBenefit",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "MOOP",
        "attribute_value": "9350"
      },
      {
        "attribute_key": "LabworkPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "LabworkCost",
        "attribute_value": "30"
      },
      {
        "attribute_key": "InsulinCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "InpatientPeriod",
        "attribute_value": "per admission"
      },
      {
        "attribute_key": "InpatientPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "InpatientCost",
        "attribute_value": "2185"
      },
      {
        "attribute_key": "IncentiveProg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Immunizations",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCUnspent",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCFreq",
        "attribute_value": "per month"
      },
      {
        "attribute_key": "HHOCValue",
        "attribute_value": "155"
      },
      {
        "attribute_key": "HearAidLimit",
        "attribute_value": "1 per ear per year"
      },
      {
        "attribute_key": "HearAidCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearFitLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearFitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearFitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearingLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearAnnualLimit",
        "attribute_value": "per ear per year"
      },
      {
        "attribute_key": "HearingAnnual",
        "attribute_value": "2000"
      },
      {
        "attribute_key": "FitnessCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "EmergCoverage",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentXray",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentSurgery",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRootCanal",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRecement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentPeriodont",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentFillingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentFillingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentExtract",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentExamLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentEmPain",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureRel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureAdj",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDenture",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDeepClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCrown",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCode",
        "attribute_value": "DEN142"
      },
      {
        "attribute_key": "DentCleanLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentalAnnualLimit",
        "attribute_value": "per year"
      },
      {
        "attribute_key": "DentalAnnual",
        "attribute_value": "5000"
      },
      {
        "attribute_key": "CareManagement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "AdvImagPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "AdvImagCost",
        "attribute_value": "300"
      },
      {
        "attribute_key": "SNPPopulation",
        "attribute_value": "Medicare Non Zero Cost-sharing"
      },
      {
        "attribute_key": "SNP",
        "attribute_value": "Dual-Eligible"
      },
      {
        "attribute_key": "ProdType",
        "attribute_value": "HMO"
      },
      {
        "attribute_key": "Name",
        "attribute_value": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)"
      },
      {
        "attribute_key": "Campaign_Tag",
        "attribute_value": "Fitness excl CP"
      },
      {
        "attribute_key": "PlanID",
        "attribute_value": "H0028-007-000-2025"
      },
      {
        "attribute_key": "GeoName",
        "attribute_value": "Omaha"
      },
      {
        "attribute_key": "State",
        "attribute_value": "NE"
      },
      {
        "attribute_key": "Year",
        "attribute_value": "2025"
      }
    ]
  },
  {
    "account_id": "AC15100025754944",
    "integration_name": "Humana_SudoHPAS_2025",
    "option_name": "plans",
    "option_value": "H0028-007-000-2025",
    "option_value_text": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)",
    "attributes": [
      {
        "attribute_key": "XrayPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "XrayCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "WorldwideEmerg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionConOrEyegLimit",
        "attribute_value": "1 pair(s) per year"
      },
      {
        "attribute_key": "VisionConOrEyegPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionConOrEyegCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VisionFitting",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionAnExamLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "VisionAnExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionAnExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VirtVisitMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitUrgPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitUrgCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitSpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitSpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VirtVisitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "Travel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "TransportVendor",
        "attribute_value": "SafeRide Health"
      },
      {
        "attribute_key": "TransportLimit",
        "attribute_value": "50"
      },
      {
        "attribute_key": "TransportTrips",
        "attribute_value": "48 trip(s) per year"
      },
      {
        "attribute_key": "TransportCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "TransportCode",
        "attribute_value": "TRN049"
      },
      {
        "attribute_key": "SpecMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "SpecReferral",
        "attribute_value": "No referral"
      },
      {
        "attribute_key": "SpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "PCPPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PCPCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "Preventative",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresVBID",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresDrugDeduct",
        "attribute_value": "590"
      },
      {
        "attribute_key": "PresDrugStanTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugStanTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugRetTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugRetTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Premium",
        "attribute_value": "50.6"
      },
      {
        "attribute_key": "PlanDeduct",
        "attribute_value": "257"
      },
      {
        "attribute_key": "PartBValue",
        "attribute_value": "5"
      },
      {
        "attribute_key": "OutpatPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "OutpatCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "MealBenefit",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "MOOP",
        "attribute_value": "9350"
      },
      {
        "attribute_key": "LabworkPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "LabworkCost",
        "attribute_value": "30"
      },
      {
        "attribute_key": "InsulinCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "InpatientPeriod",
        "attribute_value": "per admission"
      },
      {
        "attribute_key": "InpatientPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "InpatientCost",
        "attribute_value": "2185"
      },
      {
        "attribute_key": "IncentiveProg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Immunizations",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCUnspent",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCFreq",
        "attribute_value": "per month"
      },
      {
        "attribute_key": "HHOCValue",
        "attribute_value": "155"
      },
      {
        "attribute_key": "HearAidLimit",
        "attribute_value": "1 per ear per year"
      },
      {
        "attribute_key": "HearAidCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearFitLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearFitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearFitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearingLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearAnnualLimit",
        "attribute_value": "per ear per year"
      },
      {
        "attribute_key": "HearingAnnual",
        "attribute_value": "2000"
      },
      {
        "attribute_key": "FitnessCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "EmergCoverage",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentXray",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentSurgery",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRootCanal",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRecement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentPeriodont",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentFillingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentFillingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentExtract",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentExamLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentEmPain",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureRel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureAdj",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDenture",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDeepClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCrown",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCode",
        "attribute_value": "DEN142"
      },
      {
        "attribute_key": "DentCleanLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentalAnnualLimit",
        "attribute_value": "per year"
      },
      {
        "attribute_key": "DentalAnnual",
        "attribute_value": "5000"
      },
      {
        "attribute_key": "CareManagement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "AdvImagPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "AdvImagCost",
        "attribute_value": "300"
      },
      {
        "attribute_key": "SNPPopulation",
        "attribute_value": "Medicare Non Zero Cost-sharing"
      },
      {
        "attribute_key": "SNP",
        "attribute_value": "Dual-Eligible"
      },
      {
        "attribute_key": "ProdType",
        "attribute_value": "HMO"
      },
      {
        "attribute_key": "Name",
        "attribute_value": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)"
      },
      {
        "attribute_key": "Campaign_Tag",
        "attribute_value": "Flex Healthy Options OTC excl CP"
      },
      {
        "attribute_key": "PlanID",
        "attribute_value": "H0028-007-000-2025"
      },
      {
        "attribute_key": "GeoName",
        "attribute_value": "Omaha"
      },
      {
        "attribute_key": "State",
        "attribute_value": "NE"
      },
      {
        "attribute_key": "Year",
        "attribute_value": "2025"
      }
    ]
  },
  {
    "account_id": "AC15100025754944",
    "integration_name": "Humana_SudoHPAS_2025",
    "option_name": "plans",
    "option_value": "H0028-007-000-2025",
    "option_value_text": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)",
    "attributes": [
      {
        "attribute_key": "XrayPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "XrayCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "WorldwideEmerg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionConOrEyegLimit",
        "attribute_value": "1 pair(s) per year"
      },
      {
        "attribute_key": "VisionConOrEyegPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionConOrEyegCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VisionFitting",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionAnExamLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "VisionAnExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionAnExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VirtVisitMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitUrgPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitUrgCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitSpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitSpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VirtVisitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "Travel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "TransportVendor",
        "attribute_value": "SafeRide Health"
      },
      {
        "attribute_key": "TransportLimit",
        "attribute_value": "50"
      },
      {
        "attribute_key": "TransportTrips",
        "attribute_value": "48 trip(s) per year"
      },
      {
        "attribute_key": "TransportCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "TransportCode",
        "attribute_value": "TRN049"
      },
      {
        "attribute_key": "SpecMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "SpecReferral",
        "attribute_value": "No referral"
      },
      {
        "attribute_key": "SpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "PCPPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PCPCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "Preventative",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresVBID",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresDrugDeduct",
        "attribute_value": "590"
      },
      {
        "attribute_key": "PresDrugStanTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugStanTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugRetTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugRetTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Premium",
        "attribute_value": "50.6"
      },
      {
        "attribute_key": "PlanDeduct",
        "attribute_value": "257"
      },
      {
        "attribute_key": "PartBValue",
        "attribute_value": "5"
      },
      {
        "attribute_key": "OutpatPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "OutpatCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "MealBenefit",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "MOOP",
        "attribute_value": "9350"
      },
      {
        "attribute_key": "LabworkPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "LabworkCost",
        "attribute_value": "30"
      },
      {
        "attribute_key": "InsulinCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "InpatientPeriod",
        "attribute_value": "per admission"
      },
      {
        "attribute_key": "InpatientPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "InpatientCost",
        "attribute_value": "2185"
      },
      {
        "attribute_key": "IncentiveProg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Immunizations",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCUnspent",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCFreq",
        "attribute_value": "per month"
      },
      {
        "attribute_key": "HHOCValue",
        "attribute_value": "155"
      },
      {
        "attribute_key": "HearAidLimit",
        "attribute_value": "1 per ear per year"
      },
      {
        "attribute_key": "HearAidCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearFitLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearFitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearFitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearingLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearAnnualLimit",
        "attribute_value": "per ear per year"
      },
      {
        "attribute_key": "HearingAnnual",
        "attribute_value": "2000"
      },
      {
        "attribute_key": "FitnessCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "EmergCoverage",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentXray",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentSurgery",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRootCanal",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRecement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentPeriodont",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentFillingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentFillingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentExtract",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentExamLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentEmPain",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureRel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureAdj",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDenture",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDeepClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCrown",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCode",
        "attribute_value": "DEN142"
      },
      {
        "attribute_key": "DentCleanLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentalAnnualLimit",
        "attribute_value": "per year"
      },
      {
        "attribute_key": "DentalAnnual",
        "attribute_value": "5000"
      },
      {
        "attribute_key": "CareManagement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "AdvImagPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "AdvImagCost",
        "attribute_value": "300"
      },
      {
        "attribute_key": "SNPPopulation",
        "attribute_value": "Medicare Non Zero Cost-sharing"
      },
      {
        "attribute_key": "SNP",
        "attribute_value": "Dual-Eligible"
      },
      {
        "attribute_key": "ProdType",
        "attribute_value": "HMO"
      },
      {
        "attribute_key": "Name",
        "attribute_value": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)"
      },
      {
        "attribute_key": "Campaign_Tag",
        "attribute_value": "Healthy Options excl CP"
      },
      {
        "attribute_key": "PlanID",
        "attribute_value": "H0028-007-000-2025"
      },
      {
        "attribute_key": "GeoName",
        "attribute_value": "Omaha"
      },
      {
        "attribute_key": "State",
        "attribute_value": "NE"
      },
      {
        "attribute_key": "Year",
        "attribute_value": "2025"
      }
    ]
  },
  {
    "account_id": "AC15100025754944",
    "integration_name": "Humana_SudoHPAS_2025",
    "option_name": "plans",
    "option_value": "H0028-007-000-2025",
    "option_value_text": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)",
    "attributes": [
      {
        "attribute_key": "XrayPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "XrayCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "WorldwideEmerg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionConOrEyegLimit",
        "attribute_value": "1 pair(s) per year"
      },
      {
        "attribute_key": "VisionConOrEyegPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionConOrEyegCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VisionFitting",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionAnExamLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "VisionAnExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionAnExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VirtVisitMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitUrgPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitUrgCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitSpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitSpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VirtVisitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "Travel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "TransportVendor",
        "attribute_value": "SafeRide Health"
      },
      {
        "attribute_key": "TransportLimit",
        "attribute_value": "50"
      },
      {
        "attribute_key": "TransportTrips",
        "attribute_value": "48 trip(s) per year"
      },
      {
        "attribute_key": "TransportCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "TransportCode",
        "attribute_value": "TRN049"
      },
      {
        "attribute_key": "SpecMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "SpecReferral",
        "attribute_value": "No referral"
      },
      {
        "attribute_key": "SpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "PCPPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PCPCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "Preventative",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresVBID",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresDrugDeduct",
        "attribute_value": "590"
      },
      {
        "attribute_key": "PresDrugStanTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugStanTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugRetTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugRetTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Premium",
        "attribute_value": "50.6"
      },
      {
        "attribute_key": "PlanDeduct",
        "attribute_value": "257"
      },
      {
        "attribute_key": "PartBValue",
        "attribute_value": "5"
      },
      {
        "attribute_key": "OutpatPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "OutpatCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "MealBenefit",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "MOOP",
        "attribute_value": "9350"
      },
      {
        "attribute_key": "LabworkPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "LabworkCost",
        "attribute_value": "30"
      },
      {
        "attribute_key": "InsulinCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "InpatientPeriod",
        "attribute_value": "per admission"
      },
      {
        "attribute_key": "InpatientPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "InpatientCost",
        "attribute_value": "2185"
      },
      {
        "attribute_key": "IncentiveProg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Immunizations",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCUnspent",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCFreq",
        "attribute_value": "per month"
      },
      {
        "attribute_key": "HHOCValue",
        "attribute_value": "155"
      },
      {
        "attribute_key": "HearAidLimit",
        "attribute_value": "1 per ear per year"
      },
      {
        "attribute_key": "HearAidCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearFitLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearFitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearFitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearingLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearAnnualLimit",
        "attribute_value": "per ear per year"
      },
      {
        "attribute_key": "HearingAnnual",
        "attribute_value": "2000"
      },
      {
        "attribute_key": "FitnessCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "EmergCoverage",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentXray",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentSurgery",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRootCanal",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRecement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentPeriodont",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentFillingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentFillingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentExtract",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentExamLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentEmPain",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureRel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureAdj",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDenture",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDeepClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCrown",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCode",
        "attribute_value": "DEN142"
      },
      {
        "attribute_key": "DentCleanLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentalAnnualLimit",
        "attribute_value": "per year"
      },
      {
        "attribute_key": "DentalAnnual",
        "attribute_value": "5000"
      },
      {
        "attribute_key": "CareManagement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "AdvImagPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "AdvImagCost",
        "attribute_value": "300"
      },
      {
        "attribute_key": "SNPPopulation",
        "attribute_value": "Medicare Non Zero Cost-sharing"
      },
      {
        "attribute_key": "SNP",
        "attribute_value": "Dual-Eligible"
      },
      {
        "attribute_key": "ProdType",
        "attribute_value": "HMO"
      },
      {
        "attribute_key": "Name",
        "attribute_value": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)"
      },
      {
        "attribute_key": "Campaign_Tag",
        "attribute_value": "MRC Audit"
      },
      {
        "attribute_key": "PlanID",
        "attribute_value": "H0028-007-000-2025"
      },
      {
        "attribute_key": "GeoName",
        "attribute_value": "Omaha"
      },
      {
        "attribute_key": "State",
        "attribute_value": "NE"
      },
      {
        "attribute_key": "Year",
        "attribute_value": "2025"
      }
    ]
  },
  {
    "account_id": "AC15100025754944",
    "integration_name": "Humana_SudoHPAS_2025",
    "option_name": "plans",
    "option_value": "H0028-007-000-2025",
    "option_value_text": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)",
    "attributes": [
      {
        "attribute_key": "XrayPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "XrayCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "WorldwideEmerg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionConOrEyegLimit",
        "attribute_value": "1 pair(s) per year"
      },
      {
        "attribute_key": "VisionConOrEyegPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionConOrEyegCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VisionFitting",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionAnExamLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "VisionAnExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionAnExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VirtVisitMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitUrgPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitUrgCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitSpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitSpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VirtVisitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "Travel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "TransportVendor",
        "attribute_value": "SafeRide Health"
      },
      {
        "attribute_key": "TransportLimit",
        "attribute_value": "50"
      },
      {
        "attribute_key": "TransportTrips",
        "attribute_value": "48 trip(s) per year"
      },
      {
        "attribute_key": "TransportCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "TransportCode",
        "attribute_value": "TRN049"
      },
      {
        "attribute_key": "SpecMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "SpecReferral",
        "attribute_value": "No referral"
      },
      {
        "attribute_key": "SpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "PCPPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PCPCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "Preventative",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresVBID",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresDrugDeduct",
        "attribute_value": "590"
      },
      {
        "attribute_key": "PresDrugStanTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugStanTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugRetTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugRetTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Premium",
        "attribute_value": "50.6"
      },
      {
        "attribute_key": "PlanDeduct",
        "attribute_value": "257"
      },
      {
        "attribute_key": "PartBValue",
        "attribute_value": "5"
      },
      {
        "attribute_key": "OutpatPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "OutpatCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "MealBenefit",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "MOOP",
        "attribute_value": "9350"
      },
      {
        "attribute_key": "LabworkPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "LabworkCost",
        "attribute_value": "30"
      },
      {
        "attribute_key": "InsulinCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "InpatientPeriod",
        "attribute_value": "per admission"
      },
      {
        "attribute_key": "InpatientPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "InpatientCost",
        "attribute_value": "2185"
      },
      {
        "attribute_key": "IncentiveProg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Immunizations",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCUnspent",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCFreq",
        "attribute_value": "per month"
      },
      {
        "attribute_key": "HHOCValue",
        "attribute_value": "155"
      },
      {
        "attribute_key": "HearAidLimit",
        "attribute_value": "1 per ear per year"
      },
      {
        "attribute_key": "HearAidCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearFitLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearFitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearFitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearingLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearAnnualLimit",
        "attribute_value": "per ear per year"
      },
      {
        "attribute_key": "HearingAnnual",
        "attribute_value": "2000"
      },
      {
        "attribute_key": "FitnessCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "EmergCoverage",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentXray",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentSurgery",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRootCanal",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRecement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentPeriodont",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentFillingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentFillingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentExtract",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentExamLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentEmPain",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureRel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureAdj",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDenture",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDeepClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCrown",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCode",
        "attribute_value": "DEN142"
      },
      {
        "attribute_key": "DentCleanLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentalAnnualLimit",
        "attribute_value": "per year"
      },
      {
        "attribute_key": "DentalAnnual",
        "attribute_value": "5000"
      },
      {
        "attribute_key": "CareManagement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "AdvImagPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "AdvImagCost",
        "attribute_value": "300"
      },
      {
        "attribute_key": "SNPPopulation",
        "attribute_value": "Medicare Non Zero Cost-sharing"
      },
      {
        "attribute_key": "SNP",
        "attribute_value": "Dual-Eligible"
      },
      {
        "attribute_key": "ProdType",
        "attribute_value": "HMO"
      },
      {
        "attribute_key": "Name",
        "attribute_value": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)"
      },
      {
        "attribute_key": "Campaign_Tag",
        "attribute_value": "Part B Giveback excl CP PDP"
      },
      {
        "attribute_key": "PlanID",
        "attribute_value": "H0028-007-000-2025"
      },
      {
        "attribute_key": "GeoName",
        "attribute_value": "Omaha"
      },
      {
        "attribute_key": "State",
        "attribute_value": "NE"
      },
      {
        "attribute_key": "Year",
        "attribute_value": "2025"
      }
    ]
  },
  {
    "account_id": "AC15100025754944",
    "integration_name": "Humana_SudoHPAS_2025",
    "option_name": "plans",
    "option_value": "H0028-007-000-2025",
    "option_value_text": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)",
    "attributes": [
      {
        "attribute_key": "XrayPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "XrayCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "WorldwideEmerg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionConOrEyegLimit",
        "attribute_value": "1 pair(s) per year"
      },
      {
        "attribute_key": "VisionConOrEyegPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionConOrEyegCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VisionFitting",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "VisionAnExamLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "VisionAnExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VisionAnExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "VirtVisitMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitUrgPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitUrgCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitSpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "VirtVisitSpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "VirtVisitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "VirtVisitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "Travel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "TransportVendor",
        "attribute_value": "SafeRide Health"
      },
      {
        "attribute_key": "TransportLimit",
        "attribute_value": "50"
      },
      {
        "attribute_key": "TransportTrips",
        "attribute_value": "48 trip(s) per year"
      },
      {
        "attribute_key": "TransportCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "TransportCode",
        "attribute_value": "TRN049"
      },
      {
        "attribute_key": "SpecMentPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecMentCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "SpecReferral",
        "attribute_value": "No referral"
      },
      {
        "attribute_key": "SpecPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "SpecCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "PCPPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PCPCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "Preventative",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresVBID",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "PresDrugDeduct",
        "attribute_value": "590"
      },
      {
        "attribute_key": "PresDrugStanTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugStanTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugRetTier1Paym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "PresDrugRetTier1Cost",
        "attribute_value": "100"
      },
      {
        "attribute_key": "PresDrugCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Premium",
        "attribute_value": "50.6"
      },
      {
        "attribute_key": "PlanDeduct",
        "attribute_value": "257"
      },
      {
        "attribute_key": "PartBValue",
        "attribute_value": "5"
      },
      {
        "attribute_key": "OutpatPaym",
        "attribute_value": "coinsurance"
      },
      {
        "attribute_key": "OutpatCost",
        "attribute_value": "20"
      },
      {
        "attribute_key": "MealBenefit",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "MOOP",
        "attribute_value": "9350"
      },
      {
        "attribute_key": "LabworkPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "LabworkCost",
        "attribute_value": "30"
      },
      {
        "attribute_key": "InsulinCov",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "InpatientPeriod",
        "attribute_value": "per admission"
      },
      {
        "attribute_key": "InpatientPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "InpatientCost",
        "attribute_value": "2185"
      },
      {
        "attribute_key": "IncentiveProg",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "Immunizations",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCUnspent",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "HHOCFreq",
        "attribute_value": "per month"
      },
      {
        "attribute_key": "HHOCValue",
        "attribute_value": "155"
      },
      {
        "attribute_key": "HearAidLimit",
        "attribute_value": "1 per ear per year"
      },
      {
        "attribute_key": "HearAidCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearFitLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearFitPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearFitCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearingLimit",
        "attribute_value": "1 per year"
      },
      {
        "attribute_key": "HearingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "HearingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "HearAnnualLimit",
        "attribute_value": "per ear per year"
      },
      {
        "attribute_key": "HearingAnnual",
        "attribute_value": "2000"
      },
      {
        "attribute_key": "FitnessCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "EmergCoverage",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentXray",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentSurgery",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRootCanal",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentRecement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentPeriodont",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentFillingPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentFillingCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentExtract",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentExamLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentExamPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "DentExamCost",
        "attribute_value": "0"
      },
      {
        "attribute_key": "DentEmPain",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureRel",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDentureAdj",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDenture",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentDeepClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCrown",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentCode",
        "attribute_value": "DEN142"
      },
      {
        "attribute_key": "DentCleanLimit",
        "attribute_value": "2 per year"
      },
      {
        "attribute_key": "DentClean",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "DentalAnnualLimit",
        "attribute_value": "per year"
      },
      {
        "attribute_key": "DentalAnnual",
        "attribute_value": "5000"
      },
      {
        "attribute_key": "CareManagement",
        "attribute_value": "Yes"
      },
      {
        "attribute_key": "AdvImagPaym",
        "attribute_value": "copayment"
      },
      {
        "attribute_key": "AdvImagCost",
        "attribute_value": "300"
      },
      {
        "attribute_key": "SNPPopulation",
        "attribute_value": "Medicare Non Zero Cost-sharing"
      },
      {
        "attribute_key": "SNP",
        "attribute_value": "Dual-Eligible"
      },
      {
        "attribute_key": "ProdType",
        "attribute_value": "HMO"
      },
      {
        "attribute_key": "Name",
        "attribute_value": "Humana Gold Plus SNP-DE H0028-007 (HMO D-SNP)"
      },
      {
        "attribute_key": "Campaign_Tag",
        "attribute_value": "Provider Benefit"
      },
      {
        "attribute_key": "PlanID",
        "attribute_value": "H0028-007-000-2025"
      },
      {
        "attribute_key": "GeoName",
        "attribute_value": "Omaha"
      },
      {
        "attribute_key": "State",
        "attribute_value": "NE"
      },
      {
        "attribute_key": "Year",
        "attribute_value": "2025"
      }
    ]
  }
]'
)

-- 3. consulto tabla temporal del paso 0 para ver que se haya cargado bien

--3. Datos permitidos
-- If is FALSE raise an Exception: OU ARE USING NON VALID ATTRIBUTES OR REQUIRED ATTRIBUTES ARE MISSING
WITH cte_variable_data AS (
        SELECT
            p.integration_name
          , p.option_name
          , p.option_value
          , p.option_value_text
          , p.attribute_key
          , p.attribute_value
          , p.integration_id
        FROM
            sl.temp_variable_data_test AS p -- Temp table
    ) 
    , cte_required_attribute_preferences AS (
        SELECT DISTINCT
            xap.integration_id
          , xap.option_name
          , xap.attribute_key
          , xap.is_required
        FROM
            sl.int_attribute_preferences xap
        JOIN LATERAL(
            SELECT
                xvd.attribute_key
              , xvd.integration_id
              , xvd.option_name
            FROM
                cte_variable_data xvd
        ) AS cvd ON TRUE
        WHERE xap.integration_id::BPCHAR = cvd.integration_id::BPCHAR 
        AND xap.option_name::BPCHAR      = cvd.option_name::BPCHAR
        AND xap.is_required              IS TRUE
    )
    , cte_variable_data_attribute_preferences AS (
        SELECT
            ap.attribute_key
        FROM(
            SELECT
                cvd.integration_name
              , cvd.option_value
              , cvd.option_value_text
              , cvd.attribute_key
              , cvd.attribute_value
              , cvd.integration_id
              , cvd.option_name
            FROM 
                cte_variable_data cvd
        ) AS x
        LEFT JOIN (
            SELECT
                xap.integration_id
              , xap.option_name
              , xap.attribute_key
              , xap.is_required
            FROM
                sl.int_attribute_preferences xap
        ) AS ap
        ON x.integration_id::BPCHAR = ap.integration_id::BPCHAR
        AND x.option_name::BPCHAR   = ap.option_name::BPCHAR
        AND x.attribute_key::TEXT   = ap.attribute_key::TEXT
    )
    , cte_attributes_check AS (
        SELECT  EXISTS(
            SELECT
                1    
            FROM
                cte_variable_data_attribute_preferences cap
            WHERE
                cap.attribute_key IS NULL
        ) AS has_non_registered_attributes
    )
    , cte_required_attributes_check AS (
        SELECT EXISTS(
            SELECT
                1
            FROM
                cte_required_attribute_preferences cra
            LEFT JOIN (
                SELECT
                    xvd.attribute_key
                  , xvd.integration_id
                  , xvd.option_name
                FROM
                    cte_variable_data xvd
            ) AS cvd
            ON cra.integration_id::BPCHAR  = cvd.integration_id::BPCHAR
               AND cra.option_name::BPCHAR = cvd.option_name::BPCHAR
               AND cra.attribute_key::TEXT = cvd.attribute_key::TEXT
            WHERE
               cvd.attribute_key IS NULL
        )AS has_missing_required_attributes
    )
    SELECT 
        (BOOL_OR(x.check_result) = FALSE)
    /*INTO
        v_is_variable_data_valid*/
    FROM (
        SELECT 
            has_non_registered_attributes AS check_result
        FROM 
            cte_attributes_check 
        
        UNION ALL

        SELECT 
            has_missing_required_attributes AS check_result
        FROM 
            cte_required_attributes_check
    ) AS x;

-- 4. Load data into table int_option_values
   WITH cte_variable_data AS (
        SELECT DISTINCT
            p.integration_id
          , p.option_name
          , p.option_value
          , p.option_value_text
          , COALESCE(iov.value_version, 0) AS value_version
        FROM
            temp_variable_data_test AS p
        LEFT JOIN (
            SELECT
                DISTINCT
                xov.integration_id
              , xov.option_name
              , xov.value_version
            FROM
                sl.int_option_values xov
        ) AS iov
        ON p.integration_id::BPCHAR = iov.integration_id::BPCHAR
        AND p.option_name::TEXT     = iov.option_name::TEXT
    )
    /*INSERT INTO sl.int_option_values (
        integration_id
      , option_value_id
      , option_value
      , option_value_text
      , value_version
      , value_minor_version
      , version_ts
      , option_name)*/
    SELECT
        x.integration_id
      --, sl.app_gen_entity_key('int_option_values')
      , y.option_value
      , y.option_value_text
      , COALESCE(
            x.max_version
          , 0
        ) + 1 AS new_value_version
      , 0     AS value_minor_version
      , NOW() AS version_ts
      , x.option_name
    FROM(
        --Getting the last version registered for the
        --option values to calculate the new
        --version value
        SELECT
            z.integration_id
          , z.option_name
          , z.max_version
        FROM(
            SELECT
                p.integration_id
              , p.option_name
              , p.value_version             AS current_value_version
              , MAX(p.value_version) OVER() AS max_version
            FROM
                cte_variable_data p
            GROUP BY
                p.integration_id
              , p.option_name
              , p.value_version
        ) AS z
         GROUP BY
            z.integration_id
          , z.option_name
          , z.max_version
        HAVING MAX(z.current_value_version) = z.max_version
    ) AS x
    JOIN (
        SELECT
            cte.integration_id
          , cte.option_name
          , cte.option_value
          , cte.option_value_text
          , cte.value_version
        FROM
            cte_variable_data cte
    ) AS y
    ON x.integration_id::BPCHAR = y.integration_id::BPCHAR
    AND x.option_name::TEXT     = y.option_name::TEXT
    AND x.max_version::INT      = y.value_version::INT;
   
-- 5. Load data into table int_opt_val_attributes
   /*INSERT INTO sl.int_opt_val_attributes(
        value_attribute_id
      , integration_id
      , option_value_id
      , attribute_key
      , attribute_value
      , option_name)*/
    SELECT
       -- sl.app_gen_entity_key('int_opt_val_attributes')
       x.integration_id
      , x.option_value_id
      , x.attribute_key
      , x.attribute_value
      , x.option_name
    FROM(
        SELECT DISTINCT
            p.integration_id
          , p.option_name
          , iov.option_value_id
          , p.attribute_key
          , p.attribute_value
          , iov.value_version
        FROM
            temp_variable_data_test AS p
        JOIN (
            SELECT
                DISTINCT
                xov.integration_id
              , xov.option_name
              , xov.option_value
              , xov.option_value_id
              , xov.value_version
            FROM
                sl.int_option_values xov
        )AS iov
        ON p.integration_id::BPCHAR = iov.integration_id::BPCHAR
        AND p.option_name ::TEXT    = iov.option_name::TEXT
        AND p.option_value::TEXT    = iov.option_value::TEXT
    ) AS x
    LEFT JOIN (
        SELECT
            cte.integration_id
          , cte.option_name
          , cte.option_value_id
        FROM
            sl.int_opt_val_attributes cte
    ) AS y
    ON x.integration_id::BPCHAR   = y.integration_id::BPCHAR
    AND x.option_name::TEXT       = y.option_name::TEXT
    AND x.option_value_id::BPCHAR = y.option_value_id::BPCHAR
    WHERE
        y.option_value_id IS NULL;
   