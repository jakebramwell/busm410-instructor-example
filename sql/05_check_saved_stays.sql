-- Step 5: Check the saved analysis table before model development. See sql/README.md for interpretation.

WITH checked AS (
  SELECT
    COUNT(*) AS saved_stays,
    COUNTIF(person_id IS NULL OR visit_occurrence_id IS NULL) AS missing_stay_keys,
    COUNTIF(admit_date IS NULL OR discharge_date IS NULL) AS missing_dates,
    COUNTIF(discharge_date < admit_date) AS negative_durations,
    COUNTIF(readmit_30 IS NULL OR readmit_30 NOT IN (0, 1)) AS invalid_readmission_flags,
    COUNTIF(discharge_date > DATE '2010-12-01') AS insufficient_follow_up_by_project_rule,
    COUNTIF(death_date <= discharge_date) AS death_on_or_before_claim_end,
    COUNTIF(state = '54') AS state_54_stays,
    COUNTIF(state IS NULL) AS missing_home_state,
    COUNTIF(readmit_30 != CASE
      WHEN days_to_next_admit BETWEEN 2 AND 30
        AND (death_date IS NULL OR death_date >= next_admit_date) THEN 1
      ELSE 0
    END) AS flags_inconsistent_with_rule
  FROM `cloud-services-example.readmissions.stays_final`
),
duplicates AS (
  SELECT COUNT(*) AS duplicate_stay_keys
  FROM (
    SELECT person_id, visit_occurrence_id
    FROM `cloud-services-example.readmissions.stays_final`
    GROUP BY person_id, visit_occurrence_id
    HAVING COUNT(*) > 1
  )
)
SELECT *
FROM checked
CROSS JOIN duplicates;
