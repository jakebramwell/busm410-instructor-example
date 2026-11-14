# SQL Notes

What each query does, in the order the queries were run.

- Data: `bigquery-public-data.cms_synthetic_patient_data_omop`
- To run these yourself, replace `cloud-services-example` (my Google Cloud project ID) with yours.

## Step 1: Find which rows are hospital stays

**Query:** [`01_claim_type_lookup.sql`](01_claim_type_lookup.sql)
**Data scanned:** about 2.4 GB

**Why:** The `condition_occurrence` table mixes hospital diagnoses (*inpatient*) with doctor's-office diagnoses (*outpatient*), and the documentation didn't say which code marks the hospital ones.

**Result:**

| condition_type_concept_id | concept_name |
|---|---|
| 38000200 | Inpatient header - 1st position |
| 38000230 | Outpatient header - 1st position |

**Decision:** Every later query keeps only hospital rows: `condition_type_concept_id = 38000200`.

## Step 2: Build one row per hospital stay

**Query:** [`02_inpatient_stays.sql`](02_inpatient_stays.sql)
**Data scanned:** about 11 GB. Saves the table `readmissions.stays_final`.

**Why:** To calculate a readmission rate, we need one row per hospital stay, with its dates, the patient's home state, and whether a readmission followed.

**How the query works, piece by piece:**

- `stays`: groups diagnosis rows into stays, one row per patient (`person_id`) and stay (`visit_occurrence_id`).
- `deaths`: one death date per patient.
- `almost_there`: adds the patient's home state, and uses `LEAD()` to look ahead to the patient's next stay and count the days until it.
- `final`: adds the readmission flag (`readmit_30`), the cost, and the death filter.

**Rules and choices:**

- **Dates:** The data has no true admission or discharge dates. The original CMS files had them (`CLM_ADMSN_DT` and `NCH_BENE_DSCHRG_DT` in metadata.pdf), but they were dropped when the data was converted into the format we query in BigQuery. We use the start and end dates on the hospital's bill instead (`condition_start_date` and `condition_end_date`).
- **Readmission:** `readmit_30 = 1` when the patient's next stay starts 1 to 30 days after this one ends. A patient can have more than one.
- **Duplicate bills:** Some stays were billed as several overlapping bills, so the "next stay" seemed to start before or on the day the current one ended (35,255 before, 5,985 on the same day). That's impossible for two real stays, so the last line of the query removes these rows. We first tried ignoring all gaps under 2 days, but a chart of gap lengths showed these made-up dates can't tell duplicate bills from real readmissions, so we only remove the impossible ones.
- **Last stays are kept:** A patient's final stay has no next stay, so its gap is blank. It stays in, because it still counts toward the total number of stays.
- **Deaths:** Stays where the patient died before the stay ended are removed, and a "readmission" after a patient's death never counts.
- **End of the data:** The data ends Dec 31, 2010. Stays ending after Dec 1, 2010 are removed, because there aren't 30 days left to see whether the patient came back.
- **Cost:** $13,300 per readmission, from 2011 Medicare figures ($24.0 billion ÷ 1.8 million readmissions; [HCUP Statistical Brief #172](https://www.hcup-us.ahrq.gov/reports/statbriefs/sb172-Conditions-Readmissions-Payer.pdf)). The dataset's own `cost` table has no hospital-stay costs.
- **Not used:** Provider and hospital IDs are random in this data (CMS manual, p. 15).

**Result:** 1,281,691 hospital stays (after removing 41,240 duplicate-bill rows).

## Step 3: Calculate state rates in Google Sheets

**Query:** [`03_connected_sheets_source.sql`](03_connected_sheets_source.sql)
**Data scanned:** a few MB per refresh

**Why:** State rates, the benchmark, and costs were calculated in a [Google Sheet connected to BigQuery](https://docs.google.com/spreadsheets/d/1XnLg82ePxkSuYE-KfKobFYNcuVbInf0kQ4ceUpW6lQA/edit?gid=738753992#gid=738753992), in Pivot Table 1, with one row per state:

- Readmission rate: `AVERAGE` of `readmit_30` (the share of stays marked 1)
- Number of stays: `COUNTA` of `readmit_30`
- The row labeled "54" (8,964 stays) is left out. It isn't a state, and what it means still needs checking.

**Result (Nov 12):**

- All 50 states plus DC: 1,272,727 stays and 126,321 readmissions, or 9.93%. State rates range from 7.75% (Utah) to 10.59% (Mississippi).
- Benchmark: 9.18%. [findings.md](../findings.md) explains how it was set.
- Texas: 10.40% (9,055 readmissions out of 87,088 stays), about 1,057 readmissions above the benchmark, costing about $14.1 million.

**Sheet formulas:**

- Benchmark = the benchmark states' total readmissions ÷ their total stays
- Extra readmissions = (Texas rate − benchmark) × Texas stays
- Cost = extra readmissions × 13,300
- Margin of error for the gap = `1.96 × SQRT(TX_rate × (1 − TX_rate) / TX_stays + benchmark × (1 − benchmark) / benchmark_stays)`
- Result: gap of 1.21 points, 95% confidence interval 0.96 to 1.47 points

**Decision:** Use the 9.18% benchmark and focus on Texas.

**Note:** The Oct 30 snapshot in [Other/](../Other/state_pivot_2026-10-30.csv) was made before the Nov 12 duplicate-bill fix.

## Step 4: Build the table the model learns from

**Query:** [`04_analysis_table.sql`](04_analysis_table.sql)
**Data scanned:** about 365 MB before the condition count was added; recheck in the editor

**Why:** A model needs one row per stay with two things: the answer it should learn to predict (`readmit_30`) and *features*, the facts it uses to predict it. Features must be things known when the patient leaves the hospital. `stays_final` has the answer but no features, and some of its columns (like `days_to_next_admit`) give the answer away, so the model gets this new table instead.

**The features, and how the SQL builds each one:**

| Feature | What it means | How the SQL builds it |
|---|---|---|
| `los` | Length of stay, in days | Discharge date minus admit date (`DATE_DIFF`) |
| `age` | Age at admission (approximate; the data has only birth year) | Admit year minus `person.year_of_birth` |
| `sex` | MALE or FEMALE | `person.gender_concept_id` joined to the `concept` table for the name |
| `prior_stays` | How many hospital stays the patient had before this one (0 on a first stay) | `COUNT(*)` over the patient's stays in date order, counting only the ones before this row |
| `days_since_last_stay` | Days between this admission and the patient's last discharge (blank on a first stay) | `LAG()` looks back one row to the previous stay's discharge date (the opposite of `LEAD()` in step 2) |
| `stay_in_last_6mo` | Was the patient in the hospital in the 180 days before this admission? Always TRUE or FALSE; a first stay is FALSE | `days_since_last_stay <= 180`, wrapped in `IFNULL(..., FALSE)` because a blank compared with a number gives a blank, not FALSE |
| `conditions_last_year` | How many different diagnoses the patient had in the year before admission; a simple measure of how sick they are | Counts distinct `condition_concept_id` codes dated 1 to 365 days before admission; 0 if none |
| `is_training` | TRUE for about 80% of patients: the ones the model learns from. The other 20% test it. | `FARM_FINGERPRINT(person_id)` turns each patient ID into a fixed number; keeping 8 of 10 final digits gives 80%. All of a patient's stays land on the same side, and every rerun gives the same split. |

The table also keeps `person_id`, `visit_occurrence_id`, the stay dates, and `state`. These are not features.

**Result:** 1,281,691 rows, the same as `stays_final`, so no stays were duplicated.

## Step 5: Train the model

**Query:** [`05_train_model.sql`](05_train_model.sql)

**Why:** A *logistic regression* learns from past stays and gives each stay a probability of readmission. The plan is in [model/model_card.md](../model/model_card.md).

**Choices in the query:**

- Learns only from training patients (`WHERE is_training`), so the test patients stay unseen.
- Uses six features: `age`, `sex`, `los`, `prior_stays`, `stay_in_last_6mo`, `conditions_last_year`. State is left out on purpose so it can be used for the Texas check later.
- Uses `stay_in_last_6mo` instead of `days_since_last_stay`. BigQuery fills blank numbers with the average, which would wrongly give first-time patients an "average" gap. The TRUE/FALSE version has no blanks.
- `enable_global_explain = TRUE` lets us rank the features afterward.
- `calculate_p_values = TRUE` checks whether each feature's effect is real or could be zero.
- `category_encoding_method = 'DUMMY_ENCODING'` is required for p-values. It makes FEMALE the starting point, so the MALE result reads as "difference from female."

## Step 6: Test the model

**Query:** [`06_evaluate_model.sql`](06_evaluate_model.sql) (six queries; run them one at a time). The fourth saves the table `readmissions.test_scores`.

**Why:** To find out whether the model is any good, what drives it, and whether it beats the simple rule. Every query uses only the test patients.

| Query | What it answers | Result |
|---|---|---|
| `ML.EVALUATE` | Is the model any good? | Score (`roc_auc`) of 0.548: weak, barely better than a coin flip (0.5). Its 90% accuracy is misleading, because always guessing "no readmission" also scores 90%. |
| `ML.GLOBAL_EXPLAIN` | Which features mattered most? | Prior stays, by far. Age mattered least. |
| `ML.ADVANCED_WEIGHTS` | Does each feature raise or lower risk, and by how much? | `EXP(weight)` turns each weight into a change in the odds: +12.6% per prior stay; men 8.3% lower than women. Age had no real effect. |
| `test_scores` + model and rule queries | Who should a care team call? | Of every 100 patients called: about 10 come back if chosen at random, 13 from the model's top 10%, and 13 from the rule's list. A tie. |

**How the model-vs-rule comparison works:**

1. `ML.PREDICT` gives every test stay a risk score. `NTILE(10)` lines the stays up from highest score to lowest and cuts the line into 10 equal groups. Both are saved in `test_scores`, with one row per test stay.
2. The model query shows the share of each group that actually came back. Group 1 is the model's top 10%.
3. The rule query shows the share of the rule's list that came back, and how many stays the rule flags.

To see it as a chart, point a Connected Sheets pivot at `test_scores`: `risk_group` as rows, `AVERAGE` of `readmit_30` as values, then a column chart. If the bars step down from group 1 to group 10, the model ranks patients well; if they're nearly flat, it doesn't. `test_scores` also keeps `state` for the Texas check later.

**Decision:** Use the simple rule. See [model/model_card.md](../model/model_card.md).
