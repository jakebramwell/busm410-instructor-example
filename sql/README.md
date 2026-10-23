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

## Step 2: Build one row per inpatient stay

**Query:** [`02_inpatient_stays.sql`](02_inpatient_stays.sql)
**Cost:** about 10-11 GB

**Why:** Each row in `condition_occurrence` is one diagnosis. A readmission rate needs one row per stay, with an admit date and a discharge date.

**Key notes:**
- Uses the inpatient filter from Step 1.
- There is no discharge date in this dataset. `condition_end_date` is the best proxy, because the OMOP conversion (OHDSI ETL-CMS) filled it from the claim end date (`CLM_THRU_DT`), not the CMS discharge date (`NCH_BENE_DSCHRG_DT`), which was not carried over. Likewise, `condition_start_date` is the claim start date (`CLM_FROM_DT`).
- When the readmission rate is built, a readmission must start at least 2 days after the prior claim ends. This keeps one long stay billed as two claims from counting as a readmission.
- `LIMIT` does not reduce the cost; BigQuery bills for every column read across the whole table. Only the columns the problem needs are selected.

**Result:** Pending.
