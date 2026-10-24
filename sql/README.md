# sql

Queries for the 30-day readmission analysis, in the order they were run. Each step lists what it does, what it found, and what was decided because of it.

Dataset: `bigquery-public-data.cms_synthetic_patient_data_omop`

## Step 1: Find the inpatient claim type

**Query:** [`01_claim_type_lookup.sql`](01_claim_type_lookup.sql)
**Cost:** about 2.4 GB

**Why:** `condition_occurrence` mixes inpatient and outpatient diagnoses. We need the ID that marks inpatient rows.

**Result:**

| condition_type_concept_id | concept_name |
|---|---|
| 38000200 | Inpatient header - 1st position |
| 38000230 | Outpatient header - 1st position |

**Decision:** Filter all later queries with `condition_type_concept_id = 38000200`.

## Step 2: Build the final stays table

**Query:** [`02_inpatient_stays.sql`](02_inpatient_stays.sql)
**Cost:** about 11 GB, run once. Saves the result as `cloud-services-example.readmissions.stays_final` (dataset location: US, to match the public dataset) for Connected Sheets.

**Why:** A readmission rate needs one row per inpatient stay with an admit date, a discharge date, the patient's state, and a readmission flag.

**How it's built:**
- `stays`: groups inpatient diagnosis rows (filter from Step 1) into one row per `visit_occurrence_id`.
- `deaths`: one death date per patient, so the join can't duplicate stays.
- `almost_there`: adds home state (`person.location_id` → `location.state`) and uses `LEAD()` to find each patient's next admit date and days until it.
- `final`: adds the readmission flag, cost, and death filter.

**Key notes:**
- No discharge date exists in this dataset. `condition_end_date` is the best proxy: the OMOP conversion (OHDSI ETL-CMS) filled it from the claim end date (`CLM_THRU_DT`), not the CMS discharge date (`NCH_BENE_DSCHRG_DT`). `condition_start_date` is the claim start date (`CLM_FROM_DT`).
- State is the patient's home state, not where they were treated. Provider and care site IDs were not used: CMS says they're random (manual, p. 15).
- `visit_occurrence_id` values are labels, not a sequence. Stays are ordered by admit date.
- `readmit_30 = 1` when the next admission starts 2 to 30 days after discharge. The 2-day minimum keeps one long stay billed as two claims from counting. Multiple readmissions per patient count.
- An admission dated after the patient's death is impossible (a side effect of CMS's synthetic date shifting), so it never counts as a readmission.
- Stays where the patient died during the stay are removed (matches CMS's readmission measure). Patients who died within 30 days after discharge stay in and count as not readmitted.
- Stays discharged after 2010-12-01 are removed because data ends 2010-12-31 and they don't have a full 30 days of follow-up. They can still count as readmissions for earlier stays, since `LEAD()` runs before the filter.
- `cost_per_readmit_usd` = $13,300 per readmission: HCUP 2011 Medicare figure ($24.0 billion / 1.8 million 30-day readmissions, hospital costs). No cost data for hospital stays exists in this dataset's `cost` table. 2011 is one year after the data ends. Source: [HCUP Statistical Brief #172](https://www.hcup-us.ahrq.gov/reports/statbriefs/sb172-Conditions-Readmissions-Payer.pdf).
- `LIMIT` and `ORDER BY` were removed for the saved table: `LIMIT` doesn't lower cost, and saved tables don't keep row order.

**Result:** Pending.
