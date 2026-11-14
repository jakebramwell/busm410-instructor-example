-- Step 5: Train the logistic regression on training patients only. See sql/README.md for notes.

CREATE OR REPLACE MODEL `cloud-services-example.readmissions.readmit_model`
OPTIONS (
  model_type = 'logistic_reg',
  input_label_cols = ['readmit_30'],
  enable_global_explain = TRUE
) AS
SELECT
  readmit_30,
  age,
  sex,
  los,
  prior_stays,
  stay_in_last_6mo,
  conditions_last_year
FROM `cloud-services-example.readmissions.analysis_table`
WHERE is_training;
