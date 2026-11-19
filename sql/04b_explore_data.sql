-- Step 4b: Check and explore the analysis table before training the model. See sql/README.md for notes.

-- 1. Any blanks or impossible values?
SELECT
  COUNT(*) AS stays,
  COUNTIF(readmit_30 IS NULL) AS blank_readmit,
  COUNTIF(state IS NULL) AS blank_state,
  COUNTIF(sex IS NULL) AS blank_sex,
  COUNTIF(age IS NULL) AS blank_age,
  MIN(age) AS youngest,
  MAX(age) AS oldest,
  MIN(los) AS shortest_stay,
  MAX(los) AS longest_stay,
  MIN(prior_stays) AS fewest_prior,
  MAX(prior_stays) AS most_prior,
  MAX(conditions_last_year) AS most_conditions,
  MIN(admit_date) AS first_admit,
  MAX(discharge_date) AS last_discharge
FROM `cloud-services-example.readmissions.analysis_table`;

-- 2. Is the Texas gap the same every year?
SELECT
  EXTRACT(YEAR FROM admit_date) AS year,
  COUNTIF(state = 'TX') AS texas_stays,
  ROUND(100 * AVG(IF(state = 'TX', readmit_30, NULL)), 2) AS texas_rate,
  ROUND(100 * AVG(IF(state != 'TX', readmit_30, NULL)), 2) AS everyone_else_rate
FROM `cloud-services-example.readmissions.analysis_table`
GROUP BY year
ORDER BY year;

-- 3. Readmission rate for each feature, one at a time.
--    Yes/no and text features: one row per value.
--    Number features: four equal-size buckets, lowest to highest.
WITH buckets AS (
  SELECT
    *,
    NTILE(4) OVER (ORDER BY age) AS age_bucket,
    NTILE(4) OVER (ORDER BY los) AS los_bucket,
    NTILE(4) OVER (ORDER BY prior_stays) AS prior_bucket,
    NTILE(4) OVER (ORDER BY conditions_last_year) AS cond_bucket
  FROM `cloud-services-example.readmissions.analysis_table`
)
SELECT 'stay_in_last_6mo' AS feature, CAST(stay_in_last_6mo AS STRING) AS value_range,
       COUNT(*) AS stays, ROUND(100 * AVG(readmit_30), 2) AS readmit_rate
FROM buckets GROUP BY 2
UNION ALL
SELECT 'sex', sex, COUNT(*), ROUND(100 * AVG(readmit_30), 2)
FROM buckets GROUP BY 2
UNION ALL
SELECT 'age', FORMAT('%d. %d to %d', age_bucket, MIN(age), MAX(age)), COUNT(*), ROUND(100 * AVG(readmit_30), 2)
FROM buckets GROUP BY age_bucket
UNION ALL
SELECT 'los', FORMAT('%d. %d to %d', los_bucket, MIN(los), MAX(los)), COUNT(*), ROUND(100 * AVG(readmit_30), 2)
FROM buckets GROUP BY los_bucket
UNION ALL
SELECT 'prior_stays', FORMAT('%d. %d to %d', prior_bucket, MIN(prior_stays), MAX(prior_stays)), COUNT(*), ROUND(100 * AVG(readmit_30), 2)
FROM buckets GROUP BY prior_bucket
UNION ALL
SELECT 'conditions_last_year', FORMAT('%d. %d to %d', cond_bucket, MIN(conditions_last_year), MAX(conditions_last_year)), COUNT(*), ROUND(100 * AVG(readmit_30), 2)
FROM buckets GROUP BY cond_bucket
ORDER BY feature, value_range;
