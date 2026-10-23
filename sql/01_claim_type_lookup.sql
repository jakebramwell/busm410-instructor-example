-- 01: Which claim types exist in condition_occurrence?
-- Result: 38000200 = Inpatient header, 38000230 = Outpatient header
-- Use 38000200 as the inpatient filter in later queries. (~2.4 GB scanned)

SELECT DISTINCT
  co.condition_type_concept_id,
  c.concept_name
FROM `bigquery-public-data.cms_synthetic_patient_data_omop.condition_occurrence` co
JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.concept` c
  ON c.concept_id = co.condition_type_concept_id;
