-- Step 2: One row per inpatient stay with state, death date, 30-day readmission flag, and cost per readmission. See sql/README.md for notes.

CREATE TABLE `cloud-services-example.readmissions.stays_final` AS
WITH stays AS (
  SELECT
    person_id,
    visit_occurrence_id,
    MIN(condition_start_date) AS admit_date,
    MAX(condition_end_date)   AS discharge_date
  FROM `bigquery-public-data.cms_synthetic_patient_data_omop.condition_occurrence`
  WHERE condition_type_concept_id = 38000200
  GROUP BY person_id, visit_occurrence_id
),
deaths AS (
  SELECT person_id, MIN(death_date) AS death_date
  FROM `bigquery-public-data.cms_synthetic_patient_data_omop.death`
  GROUP BY person_id
),
almost_there AS (
  SELECT
    s.person_id,
    s.visit_occurrence_id,
    s.admit_date,
    s.discharge_date,
    d.death_date,
    l.state,
    LEAD(s.admit_date) OVER (PARTITION BY s.person_id ORDER BY s.admit_date, s.discharge_date) AS next_admit_date,
    DATE_DIFF(
      LEAD(s.admit_date) OVER (PARTITION BY s.person_id ORDER BY s.admit_date, s.discharge_date),
      s.discharge_date, DAY
    ) AS days_to_next_admit
  FROM stays s
  LEFT JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.person` p
    ON s.person_id = p.person_id
  LEFT JOIN `bigquery-public-data.cms_synthetic_patient_data_omop.location` l
    ON p.location_id = l.location_id
  LEFT JOIN deaths d
    ON s.person_id = d.person_id
),
final AS (
SELECT
  *,
  CASE WHEN days_to_next_admit BETWEEN 2 AND 30
        AND (death_date IS NULL OR death_date >= next_admit_date) THEN 1 ELSE 0 END AS readmit_30,
  CASE WHEN days_to_next_admit BETWEEN 2 AND 30
        AND (death_date IS NULL OR death_date >= next_admit_date) THEN 13300 ELSE 0 END AS cost_per_readmit_usd,
  CASE WHEN death_date <= discharge_date THEN "Remove" ELSE "Keep" END AS death_filter
FROM almost_there
)
SELECT *
FROM final
WHERE death_filter = "Keep"
  AND discharge_date <= DATE "2010-12-01";
