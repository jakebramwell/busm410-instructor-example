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

-- Model vs. rule: readmission rate in the model's top 10% vs. the 6-month rule's list
WITH scored AS (
  SELECT
    readmit_30,
    stay_in_last_6mo,
    (SELECT p.prob FROM UNNEST(predicted_readmit_30_probs) p WHERE p.label = 1) AS risk
  FROM ML.PREDICT(
    MODEL `cloud-services-example.readmissions.readmit_model`,
    (SELECT * FROM `cloud-services-example.readmissions.analysis_table` WHERE NOT is_training))
),
ranked AS (
  SELECT *, NTILE(10) OVER (ORDER BY risk DESC) AS decile
  FROM scored
)
SELECT
  AVG(readmit_30) AS overall_rate,
  AVG(IF(decile = 1, readmit_30, NULL)) AS model_top10_rate,
  AVG(IF(stay_in_last_6mo, readmit_30, NULL)) AS rule_rate,
  COUNTIF(stay_in_last_6mo) / COUNT(*) AS share_flagged_by_rule
FROM ranked;
