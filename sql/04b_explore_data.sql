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

-- 3. Readmission rate for a yes/no feature: stay in the last 6 months.
SELECT
  stay_in_last_6mo,
  COUNT(*) AS stays,
  ROUND(100 * AVG(readmit_30), 2) AS readmit_rate
FROM `cloud-services-example.readmissions.analysis_table`
GROUP BY stay_in_last_6mo;

-- 4. Readmission rate for a number feature: length of stay, one row per number of days.
SELECT
  los AS days_in_hospital,
  COUNT(*) AS stays,
  ROUND(100 * AVG(readmit_30), 2) AS readmit_rate
FROM `cloud-services-example.readmissions.analysis_table`
GROUP BY los
ORDER BY los;
