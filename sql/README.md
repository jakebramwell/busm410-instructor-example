# sql

Queries for the 30-day readmission analysis, in the order they were run. Each step lists what it does, what it found, and what was decided because of it.

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
**Estimated data scanned:** about 11 GB, run once. Saves the result as `cloud-services-example.readmissions.stays_final` (dataset location: US, to match the public dataset) for Connected Sheets.

**Why:** A readmission rate needs one row per inpatient stay with admission/discharge date stand-ins, the patient's home state, and a readmission flag.

**How it's built:**
- `stays`: groups inpatient diagnosis rows into one row per `(person_id, visit_occurrence_id)`. This counts one stay instead of several diagnoses from the same stay.
- `deaths`: one death date per patient, so the join can't duplicate stays.
- `almost_there`: adds home state (`person.location_id` → `location.state`) and uses `LEAD()` to find each patient's next admit date and days until it.
- `final`: adds the readmission flag, cost, and death filter.

**Key notes:**
- No discharge date exists in this dataset. `condition_end_date` is the stand-in used here: the OMOP conversion (OHDSI ETL-CMS) filled it from the claim end date (`CLM_THRU_DT`), not the CMS discharge date (`NCH_BENE_DSCHRG_DT`). `condition_start_date` is the claim start date (`CLM_FROM_DT`).
- State is the patient's home state, not where they were treated. Provider and care site IDs were not used: CMS says they're random (manual, p. 15).
- `visit_occurrence_id` values are labels, not a sequence. Stays are ordered by admit date.
- `readmit_30 = 1` when the next admission starts 2 to 30 days after discharge. The 2-day minimum is intended to reduce split-claim counts; it still needs checking. A patient can contribute more than one flagged stay. This is a project definition, not the full CMS measure.
- A next admission dated after the recorded death date does not count as a readmission.
- Stays with recorded death on or before claim end are removed. A death later in the 30-day window does not exclude the stay; a qualifying readmission before that death can still count.
- Stays discharged after 2010-12-01 are removed because data ends 2010-12-31 and they don't have a full 30 days of follow-up. They can still count as readmissions for earlier stays, since `LEAD()` runs before the filter.
- `cost_per_readmit_usd` = $13,300 per readmission: HCUP 2011 Medicare figure ($24.0 billion / 1.8 million 30-day readmissions, hospital costs). No cost data for hospital stays exists in this dataset's `cost` table. 2011 is one year after the data ends. Source: [HCUP Statistical Brief #172](https://www.hcup-us.ahrq.gov/reports/statbriefs/sb172-Conditions-Readmissions-Payer.pdf).
- `LIMIT` and `ORDER BY` were removed for the saved table: `LIMIT` doesn't lower cost, and saved tables don't keep row order.

**Result:** 1,322,931 inpatient stays saved to `stays_final`.

## Step 3: Pivot the stays table in Connected Sheets

**Query:** [`03_connected_sheets_source.sql`](03_connected_sheets_source.sql)
**Estimated data scanned:** a few MB per refresh (reads the small saved table, not the public dataset)

**Why:** The state rates, benchmark, and cost estimate were calculated in [Connected Sheets](https://docs.google.com/spreadsheets/d/1-k3lznH6OZNAZwy39aBjoEVW0L6m0MZH7Ud-2KlPrN8/edit?gid=1737753067#gid=1737753067), using Pivot Table 1.

**How:** The output of this query was connected to Google Sheets with Connected Sheets, and pivot tables were run with state in rows:
- 30-day readmission rate: `AVERAGE` of `readmit_30`
- Stays: `COUNTA` of `readmit_30`
- Share of stays: `COUNTA` of `readmit_30`, shown as % of column total
- The row labeled "54" was excluded. Its meaning still needs to be confirmed.

**Result:**
- The reviewed state pivot has 1,313,758 stays and 120,503 readmissions: 9.17%. The earlier 9.16% note used a different total; the 9,173-stay difference from the saved table needs reconciliation. State rates range from 7.15% (UT) to 9.82% (MS).
- Benchmark: 19,412 / 225,105 = 8.62%. Rank states from lowest rate and include whole states until they first cover at least 10% of stays. The first 14 cover 9.32%; adding California gives 15 and 17.13%. This adapts the ABC idea without its small-group adjustment. Source: Weissman et al., [Achievable benchmarks of care](https://pubmed.ncbi.nlm.nih.gov/10461579/).
- Texas: 9.61% on 90,016 stays. Estimated hospital costs about $115.1 million for all recorded readmissions; about 891 events above the benchmark expectation, or $11.9 million at the same cost assumption. This does not establish preventability or savings.

**Decision:** Use the adapted benchmark (8.62%) and investigate the Texas gap within this synthetic dataset.

**Problem statement:** See [`charter.md`](../charter.md).


**Workbook calculations:** `J2 = SUM(F38:F52)/SUM(C38:C52)` pools the reference. `G3 = MAX(0,(B3-$J$2)*C3)` gives the Texas difference; `J5 = G3*13300` prices it. Keep full precision. If the pivot order changes, recheck which states cover the first 10%.

**Still to check:** the confidence-interval calculation and overlapping/adjacent claims in the next-stay rule. The dated workbook observations above were reviewed on October 27, 2026; no new BigQuery runs were made during this branch review.
