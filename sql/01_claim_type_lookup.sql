-- Step 1: Find the inpatient claim type. See sql/README.md for notes.

SELECT DISTINCT
  co.condition_type_concept_id,
  c.concept_name
FROM `bigquery-public-data.cms_synthetic_patient_data_omop.condition_occurrence` co
JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.concept` c
  ON c.concept_id = co.condition_type_concept_id;
