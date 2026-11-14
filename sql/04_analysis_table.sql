-- Step 4: Analysis table for the model: one row per stay with the label and features known at discharge. See sql/README.md for notes.

CREATE OR REPLACE TABLE `cloud-services-example.readmissions.analysis_table` AS
WITH prior_conditions AS (
  SELECT
    s.person_id,
    s.visit_occurrence_id,
    COUNT(DISTINCT co.condition_concept_id) AS conditions_last_year
  FROM `cloud-services-example.readmissions.stays_final` s
  JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.condition_occurrence` co
    ON co.person_id = s.person_id
   AND co.condition_start_date BETWEEN DATE_SUB(s.admit_date, INTERVAL 365 DAY)
                                   AND DATE_SUB(s.admit_date, INTERVAL 1 DAY)
  GROUP BY s.person_id, s.visit_occurrence_id
),
base AS (
  SELECT
    s.person_id,
    s.visit_occurrence_id,
    s.admit_date,
    s.discharge_date,
    s.state,
    DATE_DIFF(s.discharge_date, s.admit_date, DAY) AS los,
    EXTRACT(YEAR FROM s.admit_date) - p.year_of_birth AS age,
    c.concept_name AS sex,
    COUNT(*) OVER (
      PARTITION BY s.person_id
      ORDER BY s.admit_date, s.discharge_date
      ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
    ) AS prior_stays,
    DATE_DIFF(
      s.admit_date,
      LAG(s.discharge_date) OVER (
        PARTITION BY s.person_id
        ORDER BY s.admit_date, s.discharge_date
      ),
      DAY
    ) AS days_since_last_stay,
    IFNULL(pc.conditions_last_year, 0) AS conditions_last_year,
    MOD(ABS(FARM_FINGERPRINT(CAST(s.person_id AS STRING))), 10) < 8 AS is_training,
    s.readmit_30
  FROM `cloud-services-example.readmissions.stays_final` s
  LEFT JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.person` p
    ON s.person_id = p.person_id
  LEFT JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.concept` c
    ON p.gender_concept_id = c.concept_id
  LEFT JOIN prior_conditions pc
    ON s.person_id = pc.person_id
   AND s.visit_occurrence_id = pc.visit_occurrence_id
)
SELECT
  *,
  IFNULL(days_since_last_stay <= 180, FALSE) AS stay_in_last_6mo
FROM base;
