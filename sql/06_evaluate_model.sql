-- Step 6: Evaluate the model on test patients and compare it with the simple rule. See sql/README.md for notes.

-- Report card: how well the model predicts on test patients (read roc_auc)
SELECT *
FROM ML.EVALUATE(
  MODEL `cloud-services-example.readmissions.readmit_model`,
  (SELECT age, sex, los, prior_stays, stay_in_last_6mo, conditions_last_year, readmit_30
   FROM `cloud-services-example.readmissions.analysis_table`
   WHERE NOT is_training));

-- Driver ranking: which features the model relied on most
SELECT *
FROM ML.GLOBAL_EXPLAIN(MODEL `cloud-services-example.readmissions.readmit_model`);

-- Driver direction and size: each weight converted to odds, with its p-value
SELECT
  processed_input,
  category,
  ROUND(EXP(weight), 3) AS odds_ratio,
  ROUND((EXP(weight) - 1) * 100, 1) AS pct_change_in_odds,
  p_value
FROM ML.ADVANCED_WEIGHTS(MODEL `cloud-services-example.readmissions.readmit_model`)
WHERE processed_input != '__INTERCEPT__'
ORDER BY p_value;

-- Save each test stay's risk score and risk group (1 = riskiest 10%, 10 = least risky); run once
CREATE OR REPLACE TABLE `cloud-services-example.readmissions.test_scores` AS
SELECT *, NTILE(10) OVER (ORDER BY risk DESC) AS risk_group
FROM (
  SELECT
    readmit_30,
    stay_in_last_6mo,
    state,
    (SELECT p.prob FROM UNNEST(predicted_readmit_30_probs) p WHERE p.label = 1) AS risk
  FROM ML.PREDICT(
    MODEL `cloud-services-example.readmissions.readmit_model`,
    (SELECT * FROM `cloud-services-example.readmissions.analysis_table` WHERE NOT is_training))
);

-- Model: readmission rate in each risk group (group 1 = the model's top 10%)
SELECT risk_group, AVG(readmit_30) AS readmit_rate, COUNT(*) AS stays
FROM `cloud-services-example.readmissions.test_scores`
GROUP BY risk_group
ORDER BY risk_group;

-- Rule: readmission rate for everyone in the hospital in the last 6 months, and the share of stays it flags
SELECT
  AVG(IF(stay_in_last_6mo, readmit_30, NULL)) AS rule_rate,
  COUNTIF(stay_in_last_6mo) / COUNT(*) AS share_flagged_by_rule,
  AVG(readmit_30) AS overall_rate
FROM `cloud-services-example.readmissions.test_scores`;
