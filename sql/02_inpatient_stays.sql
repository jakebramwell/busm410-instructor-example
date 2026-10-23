-- 02: One row per inpatient stay
--
-- Purpose: Turn inpatient diagnosis rows (one row per diagnosis code on a claim)
-- into one row per inpatient stay, the building block for the readmission rate.
--
-- Notes:
--   * Inpatient filter: condition_type_concept_id = 38000200 ("Inpatient header").
--     Found with sql/01_claim_type_lookup.sql.
--   * No discharge date in this dataset. condition_end_date is the best proxy:
--     the OMOP conversion (OHDSI ETL-CMS) filled it from the claim end date
--     (CLM_THRU_DT), not the CMS discharge date (NCH_BENE_DSCHRG_DT), which was
--     not carried over. Likewise, condition_start_date = claim start date (CLM_FROM_DT).
--   * diagnosis_count uses COUNT(DISTINCT condition_source_value) because one
--     ICD-9 code can map to more than one standard concept and create extra rows.
--   * Filter to apply later, when building the readmission rate: a readmission
--     must start at least 2 days after the prior claim ends, so one long stay
--     billed as two back-to-back claims isn't counted as a readmission.
--   * Cost: about 10-11 GB scanned. LIMIT does not reduce the cost.

SELECT
  person_id,
  visit_occurrence_id,
  MIN(condition_start_date)              AS admit_date,
  MAX(condition_end_date)                AS discharge_date,  -- proxy: claim end date
  COUNT(DISTINCT condition_source_value) AS diagnosis_count
FROM `bigquery-public-data.cms_synthetic_patient_data_omop.condition_occurrence`
WHERE condition_type_concept_id = 38000200
GROUP BY person_id, visit_occurrence_id
ORDER BY person_id, admit_date
LIMIT 50;
