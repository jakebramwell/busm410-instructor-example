-- Step 6: Test the model on the test patients. See sql/README.md for notes.

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
