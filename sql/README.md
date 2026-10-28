# sql

Queries for the 30-day readmission analysis, in the order they were run. Each step lists what it does, what it found, and what was decided because of it.

Dataset: `bigquery-public-data.cms_synthetic_patient_data_omop`

## Step 1: Find the inpatient claim type

**Query:** [`01_claim_type_lookup.sql`](01_claim_type_lookup.sql)
**Historical scan estimate:** about 2.4 GB

**Why:** `condition_occurrence` mixes inpatient and outpatient diagnoses. We need the ID that marks inpatient rows.

**Result:**

| condition_type_concept_id | concept_name |
|---|---|
| 38000200 | Inpatient header - 1st position |
| 38000230 | Outpatient header - 1st position |

**Decision:** Filter all later queries with `condition_type_concept_id = 38000200`.

## Step 2: Build the final stays table

**Query:** [`02_inpatient_stays.sql`](02_inpatient_stays.sql)
**Historical scan estimate:** about 11 GB, run once. Saves the result as `cloud-services-example.readmissions.stays_final` (dataset location: US, to match the public dataset) for Connected Sheets.

**Why:** A readmission rate needs one row per inpatient stay with claim-date proxies, the patient's home state, and a project-defined readmission flag.

**How it's built:**
- `stays`: groups inpatient diagnosis rows (filter from Step 1) into one row per `(person_id, visit_occurrence_id)`.
- `deaths`: one death date per patient, so the join can't duplicate stays.
- `almost_there`: adds home state (`person.location_id` → `location.state`) and uses `LEAD()` to find each patient's next admit date and days until it.
- `final`: adds the readmission flag, cost, and death filter.

**Key notes:**
- No discharge date exists in this dataset. `condition_end_date` is the proxy used here: the OMOP conversion (OHDSI ETL-CMS) filled it from the claim end date (`CLM_THRU_DT`), not the CMS discharge date (`NCH_BENE_DSCHRG_DT`). `condition_start_date` is the claim start date (`CLM_FROM_DT`).
- State is the patient's home state, not where they were treated. Provider and care site IDs were not used: CMS says they're random (manual, p. 15).
- `visit_occurrence_id` values are labels, not a sequence. Stays are ordered by admit date.
- `readmit_30 = 1` when the next admission starts 2 to 30 days after discharge. The 2-day minimum was chosen to reduce possible split-claim/transfer counts; it has not been validated as a way to identify those events. Multiple stays per patient can be flagged. This is not a validated CMS measure.
- The query does not count a next stay dated after the recorded death date. CMS documents date perturbation, but the specific cause of any inconsistent record still needs checking.
- Stays with a recorded death date on or before the claim-end-date proxy are removed. A later death alone does not exclude a stay; a qualifying readmission before that death can still count. This project rule does not establish compliance with the full CMS specification.
- Stays discharged after 2010-12-01 are removed because data ends 2010-12-31 and they don't have a full 30 days of follow-up. They can still count as readmissions for earlier stays, since `LEAD()` runs before the filter.
- `cost_per_readmit_usd` = $13,300 per readmission: HCUP 2011 Medicare figure ($24.0 billion / 1.8 million 30-day readmissions, hospital costs). No cost data for hospital stays exists in this dataset's `cost` table. 2011 is one year after the data ends. Source: [HCUP Statistical Brief #172](https://www.hcup-us.ahrq.gov/reports/statbriefs/sb172-Conditions-Readmissions-Payer.pdf).
- `LIMIT` and `ORDER BY` were removed for the saved table: `LIMIT` doesn't lower cost, and saved tables don't keep row order.

**Result:** 1,322,931 inpatient stays saved to `stays_final`.

## Step 3: Pivot the stays table in Connected Sheets

**Query:** [`03_connected_sheets_source.sql`](03_connected_sheets_source.sql)
**Historical scan estimate:** a few MB per refresh (reads the small saved table, not the public dataset)

**Why:** The state rates, benchmark, and excess cost were calculated with pivot tables in Google Sheets, not in SQL.

**How:** The output of this query was connected to Google Sheets with Connected Sheets, and pivot tables were run with state in rows:
- 30-day readmission rate: `AVERAGE` of `readmit_30`
- Stays: `COUNTA` of `readmit_30`
- Share of stays: `COUNTA` of `readmit_30`, shown as % of column total
- The row labeled "54" was excluded. Its meaning is unconfirmed; verify the mapping before treating it as a documented non-state category.

**Result:**
- The original note reported 9.16%. The reviewed state pivot has 120,503 / 1,313,758 = 9.1724%, displayed as 9.17%, after excluding "54". The saved-table count is 1,322,931. Document this population difference. State rates range from 7.15% (UT) to 9.82% (MS).
- Reference: 19,412 / 225,105 = 8.6235%, displayed as 8.62%. Select the lowest-rate states until whole states first cover at least 10% of eligible stays. The first 14 cover 9.32%; adding California gives 15 and 17.13%. This raw state-ranking adaptation is ABC-inspired; it does not implement the paper's small-sample adjustment. Source: Weissman et al., [Achievable benchmarks of care: the ABCs of benchmarking](https://pubmed.ncbi.nlm.nih.gov/10461579/).
- Texas: 9.61% on 90,016 stays. Illustrative cost equivalent of all flagged readmissions about $115.1 million; difference vs. reference about 891 events, $11.9 million. These are assumed cost equivalents, not measured payments or avoidable costs.

**Decision:** Use the ABC-inspired reference rate (8.62%). Texas is the focus of this synthetic-data demonstration; this is not evidence of actual Texas care quality.

**Problem statement:** See [`charter.md`](../charter.md).

## Source documentation and project definitions

Link to full metadata; maintain only the notes specific to this analysis. Sources checked for this review on October 27, 2026:

- [CMS DE-SynPUF User Manual](https://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/SynPUFs/Downloads/SynPUF_DUG.pdf), also saved as [Other/metadata.pdf](../Other/metadata.pdf). Printed pp. 1–2 and 16 explain limits on inference; pp. 14–15 describe synthesis and dates; p. 15 covers provider IDs. These are printed page labels, not PDF page positions.
- This is the original CMS file manual, not a complete dictionary for its later OMOP conversion. Conversion-specific claims in audit entries 10 and 13 still need exact code-version links.
- [Current relationship-map source](../Other/readmission_erd.dbml). The earlier [PDF diagram](../Other/ERD_problem.pdf) still shows the superseded cost relationship. Regenerate it before treating it as current.

| Field or calculation | Meaning in this project |
|---|---|
| `person_id`, `visit_occurrence_id` | Combined key used to reconstruct one stay; check nulls and join uniqueness |
| `condition_type_concept_id = 38000200` | Inpatient claim-type filter, from Step 1's recorded lookup |
| `admit_date` / `discharge_date` | SQL aliases for minimum claim start / maximum claim end; clinical-date proxies |
| `state` | Home state via person → location; not treatment location |
| `readmit_30` | Next-stay gap of 2–30 days with death and end-of-data filters in Step 2 |
| `cost_per_readmit_usd` | $13,300 for flagged rows, otherwise zero; an assumed cost equivalent and a leaked target if used as a model input |
| Pooled reference rate | Selected states' readmissions divided by their stays; keep full precision |

## Connected Sheets calculation trail

[Workbook](https://docs.google.com/spreadsheets/d/1-k3lznH6OZNAZwy39aBjoEVW0L6m0MZH7Ud-2KlPrN8/edit?usp=sharing). Inspected read-only on October 27, 2026. The pivot reports a last refresh of October 23, 2026, 4:32 PM Hawaii time. No source queries were rerun during review.

Use **Pivot Table 1** as the current calculation sheet. The formula/values below were inspected directly; the Sheet was being edited during review, so earlier screen values are not a frozen version of these calculations.

| Location | Formula or observation |
|---|---|
| `A38:A52` | Selected states CA through UT, ranked descending in the displayed pivot; their combined counts meet the ascending-selection rule |
| `J2` | `=SUM(F38:F52)/SUM(C38:C52)`; 19,412 / 225,105 |
| `F3`, `C3` | Texas readmissions 8,654; stays 90,016 |
| `G3` | `=MAX(0,(B3-$J$2)*C3)`; about 891.44 |
| `J5` | `=G3*13300`; about $11,856,180.17 |
| `F53`, `C53` | 120,503 readmissions and 1,313,758 stays in the state-pivot population |

**Sheet1** contains a separate table. Its `G9` was a hardcoded 4.03473459939018, formatted as dollars under "Excess Readmission," whereas the current pivot gives zero for that state (NM). Treat this table as an earlier snapshot until its provenance and purpose are clarified. Do not mix its values with the current pivot.

Keep the selection sorted and stop when cumulative eligible-stay share first reaches 10%; fixed row addresses alone will not preserve that rule after an order or data change. Share of readmissions is a different selection rule, although it crosses the threshold at California in this dataset too.

Still needed: the confidence-interval formula and assumptions, chart-generation steps, confirmation of the `54` mapping, and an end-to-end run using a student's account. No additional results-export requirement is proposed.
