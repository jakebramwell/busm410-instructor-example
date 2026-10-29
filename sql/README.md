# Reproduce the Readmission Comparison

The workflow has two starting points. **To check the published story**, use the saved counts; no Google account or cloud query is needed. **To rebuild from public records**, use the BigQuery steps below.

## Check the published story

Run `python3 scripts/reproduce.py` from the repository folder, or inspect **Pivot Table 1** in the [analysis workbook](https://docs.google.com/spreadsheets/d/1-k3lznH6OZNAZwy39aBjoEVW0L6m0MZH7Ud-2KlPrN8/edit?gid=1737753067#gid=1737753067).

| Calculation | Inputs | Result |
|---|---|---|
| State/DC population rate | 120,503 / 1,313,758 | 9.1724% |
| Pooled reference rate | 19,412 / 225,105 | 8.6235% |
| Texas rate | 8,654 / 90,016 | 9.6138% |
| Texas difference | 8,654 − 90,016 × (19,412 / 225,105) | 891.44 events |
| Illustrative cost equivalent | Unrounded difference × $13,300 | $11,856,180.17 |

Reference membership is based on **cumulative share of stays**, not number of states or share of readmissions. Start with the lowest-rate states, include whole states until the share first reaches 10%, then pool counts. Fixed row addresses in a Sheet are valid only while its order and membership stay unchanged.

## Rebuild in BigQuery

Use dataset `bigquery-public-data.cms_synthetic_patient_data_omop`. Create a destination dataset named `readmissions` in the US location. Replace `cloud-services-example` in the SQL files with your own project ID. Keep the original source table names unchanged.

| Step | File | What you get | Execution status |
|---|---|---|---|
| 1 | [Claim-type lookup](01_claim_type_lookup.sql) | Confirms which code identifies inpatient rows | Original run documented; about 2.4 GB scanned |
| 2 | [Reconstruct stays](02_inpatient_stays.sql) | Saves `readmissions.stays_final` | Original run documented; about 11 GB scanned |
| 3 | [Connected Sheets source](03_connected_sheets_source.sql) | Three columns for the state pivot | Used in the original workbook |
| 4 | [State comparison](04_state_comparison.sql) | Counts, selected reference group, rates, and differences | New; calculation logic checked locally, not executed in BigQuery |
| 5 | [Saved-stay checks](05_check_saved_stays.sql) | Diagnostic counts to inspect before modeling | New; syntax checked, not executed in BigQuery |

Run Step 5 after Step 2 and before interpreting Step 4. Step 3 is optional if using Step 4 directly. New scripts are saved for branch review under the instructor's authorization to develop this branch.

Step 2 uses `CREATE TABLE`. On a repeat run, change the destination to a new table name and update the downstream references. Do not delete or replace a previous result just to make a rerun work.

Check the estimated bytes in the BigQuery editor before each run. The historical estimates above are context, not a fresh estimate. Model training has its own pricing considerations. The full run has not been verified on a new student account. [Cost controls](https://docs.cloud.google.com/bigquery/docs/best-practices-costs) · [Current pricing](https://cloud.google.com/bigquery/pricing)

## Understand Step 5's output

`missing_stay_keys`, `missing_dates`, `negative_durations`, `invalid_readmission_flags`, `insufficient_follow_up_by_project_rule`, `death_on_or_before_claim_end`, `flags_inconsistent_with_rule`, and `duplicate_stay_keys` should be zero. Investigate any nonzero result before building a model.

`saved_stays`, `state_54_stays`, and `missing_home_state` describe population size or exclusions; they are not automatically errors. The original saved-table count was 1,322,931, while the state pivot contains 1,313,758. Reconcile those 9,173 excluded stays. The meaning of code `54` is still unconfirmed; Step 4 explicitly includes the 50 state abbreviations plus DC instead of guessing that code's meaning.

Passing these checks does not prove the outcome definition is clinically valid. In particular, the current next-stay rule needs a sensitivity check for overlapping or adjacent claims followed by another stay inside 30 days.

## Definitions used in this project

| Field or rule | Meaning |
|---|---|
| One stay | Inpatient diagnosis rows grouped by `(person_id, visit_occurrence_id)` |
| Inpatient code | `condition_type_concept_id = 38000200`, from Step 1's recorded lookup |
| `admit_date` | Minimum claim-start date, used as an admission proxy |
| `discharge_date` | Maximum claim-end date, used as a discharge proxy |
| Home state | `person.location_id` linked to `location.state` |
| `readmit_30` | The immediately next stay starts 2–30 days later and is not after recorded death |
| Eligible index stay | Recorded death is not on/before claim end; claim end is no later than 2010-12-01 |
| Cost assumption | $13,300 per flagged readmission, otherwise zero; not a recorded payment |

The 2-day minimum is a project assumption intended to reduce possible split-claim/transfer counts; it does not establish that those events have been resolved. A later death alone does not exclude a stay. A qualifying readmission before that death can still count.

## Sources and evidence

- [CMS User Manual](https://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/SynPUFs/Downloads/SynPUF_DUG.pdf), also [saved locally](../Other/metadata.pdf). Printed pp. 1–2 and 16 cover inferential limitations; pp. 14–15 cover synthesis and dates; p. 15 covers provider identifiers.
- [Weissman et al., 1999](https://pubmed.ncbi.nlm.nih.gov/10461579/): the project adapts the patient-pool idea to stays and does not implement the paper's small-sample ranking adjustment.
- [HCUP Statistical Brief #172, Table 1](https://www.ncbi.nlm.nih.gov/books/NBK206781/table/sb172.t1/): the rounded 2011 Medicare age-65+ hospital-cost totals behind $13,300. These are not marginal savings or payments.
- [Current diagram source](../Other/readmission_erd.dbml). The [earlier PDF](../Other/ERD_problem.pdf) still contains a superseded cost relationship.

The CMS manual describes original files. The later OMOP conversion's exact date mapping and missing inpatient-cost mapping were reported in audit entries 10 and 13; exact conversion-code links remain to be added.

## Workbook trail

Observed October 27, 2026, without refresh or edits. `Pivot Table 1!J2` pools `F38:F52 / C38:C52`; `G3` calculates Texas excess using the unrounded reference; `J5` multiplies it by 13,300. The date-stamped CSV in `visuals/` preserves all 51 count rows used for reproduction.

Use the pivot rather than the separate `Sheet1` table: during review that table contained a hardcoded nonzero NM excess value, formatted as dollars, while the current pivot calculated zero. The original interval calculation was not located in the inspected ranges. These workbook observations are historical, not claims about its present state.
