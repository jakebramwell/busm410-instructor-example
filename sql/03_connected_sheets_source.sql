-- Step 3: Source data for the Connected Sheets pivot tables. See sql/README.md for notes.

SELECT
  state,
  readmit_30,
  cost_per_readmit_usd
FROM `cloud-services-example.readmissions.stays_final`
