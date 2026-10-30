# sql

Queries for the 30-day readmission analysis, in the order they were run: what each does, what it found, and what we decided.

Dataset: `bigquery-public-data.cms_synthetic_patient_data_omop`

## Step 1: Find the inpatient claim type

**Query:** [`01_claim_type_lookup.sql`](01_claim_type_lookup.sql)
**Estimated data scanned:** about 2.4 GB

**Why:** `condition_occurrence` mixes inpatient and outpatient diagnoses. We need the ID that marks inpatient rows.

**Result:**

| condition_type_concept_id | concept_name |
|---|---|
| 38000200 | Inpatient header - 1st position |
| 38000230 | Outpatient header - 1st position |

**Decision:** Filter all later queries with `condition_type_concept_id = 38000200`.

## Step 2: Build the final stays table

**Query:** [`02_inpatient_stays.sql`](02_inpatient_stays.sql)
**Estimated data scanned:** about 11 GB, run once. Saves `cloud-services-example.readmissions.stays_final` (location: US, matching the public dataset) for Connected Sheets.

**Why:** A readmission rate needs one row per inpatient stay, with admit and discharge dates, home state, and a readmission flag.

**How it's built:**
- `stays`: one row per `(person_id, visit_occurrence_id)`, so each stay counts once.
- `deaths`: one death date per patient, so the join can't duplicate stays.
- `almost_there`: adds home state (`person.location_id` → `location.state`) and uses `LEAD()` to find each patient's next admit date and the days until it.
- `final`: adds the readmission flag, cost, and death filter.

**Key notes:**
- The dataset has no discharge date. `condition_end_date` stands in for it: the OMOP conversion (OHDSI ETL-CMS) filled it from the claim end date (`CLM_THRU_DT`). `condition_start_date` is the claim start date (`CLM_FROM_DT`).
- State is the patient's home state. Provider and care site IDs are random (CMS manual, p. 15), so they're left out.
- Stays are ordered by admit date; `visit_occurrence_id` is only a label.
- `readmit_30 = 1` when the next stay starts 2 to 30 days after claim end. The 2-day minimum is our own assumption, meant to avoid counting one stay billed as two claims; it still needs checking. A patient can have several flagged stays. This is a simplified version of CMS's all-cause readmission measure.
- A next stay dated after the patient's death never counts.
- Stays with a death on or before claim end are removed. A later death keeps the stay, and a readmission before that death still counts.
- Stays ending after 2010-12-01 are removed, because data ends 2010-12-31 and they lack 30 days of follow-up. They still count as readmissions for earlier stays, since `LEAD()` runs first.
- `cost_per_readmit_usd` is $13,300, from HCUP's 2011 Medicare figures ($24.0 billion / 1.8 million readmissions, hospital costs). The dataset's `cost` table has no hospital stay costs. Source: [HCUP Statistical Brief #172](https://www.hcup-us.ahrq.gov/reports/statbriefs/sb172-Conditions-Readmissions-Payer.pdf).
- `LIMIT` and `ORDER BY` were dropped for the saved table: `LIMIT` doesn't lower cost, and saved tables keep no row order.

**Result:** 1,322,931 inpatient stays saved to `stays_final`.

## Step 3: Pivot the stays table in Connected Sheets

**Query:** [`03_connected_sheets_source.sql`](03_connected_sheets_source.sql)
**Estimated data scanned:** a few MB per refresh (reads the saved table)

**Why:** State rates, the benchmark, and cost were calculated in [Connected Sheets](https://docs.google.com/spreadsheets/d/1-k3lznH6OZNAZwy39aBjoEVW0L6m0MZH7Ud-2KlPrN8/edit?gid=1737753067#gid=1737753067), Pivot Table 1, with state in rows:
- 30-day readmission rate: `AVERAGE` of `readmit_30`
- Stays: `COUNTA` of `readmit_30`
- Share of stays: `COUNTA` of `readmit_30`, shown as % of column total
- The row labeled "54" (9,173 stays) is excluded. Its meaning still needs confirming.

**Result:**
- 50 states plus DC: 1,313,758 stays and 120,503 readmissions, or 9.17%. That's the saved table's 1,322,931 stays minus the 9,173 in row "54." (The earlier 9.16% included row "54.") State rates range from 7.15% (UT) to 9.82% (MS).
- Benchmark: 19,412 / 225,105 = 8.62%. Rank states from lowest rate and add whole states until they cover at least 10% of stays. The first 14 cover 9.32%; adding California makes 15 states and 17.13%. This adapts Achievable Benchmarks of Care ([Weissman et al., 1999](https://pubmed.ncbi.nlm.nih.gov/10461579/)) without its small-group adjustment.
- Texas: 9.61% on 90,016 stays. All recorded readmissions cost about $115.1 million. The 891 above the benchmark cost about $11.9 million at the same rate. Preventability and savings need further study.

**Decision:** Use the 8.62% benchmark and investigate the Texas gap in this dataset.

**Problem statement:** See [`charter.md`](../charter.md).

**Workbook calculations:** `J2 = SUM(F38:F52)/SUM(C38:C52)` pools the benchmark states. `G3 = MAX(0,(B3-$J$2)*C3)` gives Texas's readmissions above the benchmark; `J5 = G3*13300` prices them. Keep full precision. If the pivot order changes, recheck which states make up the first 10%.

**Still to check:** the confidence-interval calculation, and overlapping or back-to-back claims in the next-stay rule.
