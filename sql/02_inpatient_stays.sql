-- Step 2: One row per inpatient stay. See sql/README.md for notes.

SELECT
  person_id,
  visit_occurrence_id,
  MIN(condition_start_date) AS admit_date,
  MAX(condition_end_date)   AS discharge_date
FROM `bigquery-public-data.cms_synthetic_patient_data_omop.condition_occurrence`
WHERE condition_type_concept_id = 38000200
GROUP BY person_id, visit_occurrence_id
ORDER BY person_id, admit_date
LIMIT 50;
