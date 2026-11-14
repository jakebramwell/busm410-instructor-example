# AGENTS.md

My instructions to you, the AI agents I work with on this project: the BUSM 410 instructor example, a 30-day hospital readmission analysis in BigQuery.

## Files to read

| File | When |
|---|---|
| [README.md](README.md) | You need the project overview or the full file list |
| [Project-audit skill](.agents/skills/project-audit/SKILL.md) | At the start of every work session, and whenever I check or correct your work. Open it yourself; don't count on finding it automatically. |

## How to work with me

- Keep replies short and in plain words. Give the context before giving feedback. Define technical terms.
- When you write in my voice (README, charter, findings, commit messages), say what something is, not what it isn't.
- **Questions get answers, not actions.** If I ask a question (including "should we...?" or "what do you think?"), just answer. Don't create, edit, or delete any file until I clearly say to make a change (for example, "go ahead" or "make that change"). Audit log entries also need my approval first.
- Back up claims about the data with a source (document and page). Say when something is your own conclusion rather than a documented fact.
- Ask me to confirm a table or column exists before you use it. Don't assume this dataset has the standard OMOP tables.
- Use SQL and Google Sheets only; no Python.
- Reference documents go in [Other/](Other/).

## Queries

- Start simple and build one step at a time.
- Draft the query, I approve it, then save it as `sql/NN_short_name.sql`.
- Each SQL file starts with a one-line header (`-- Step N: ... See sql/README.md for notes.`). If a file holds several queries, a short `--` label above each is fine. All other notes go in [sql/README.md](sql/README.md), kept brief.
- Before I run a query, ask me for the data-scanned estimate the BigQuery editor shows, and record it in sql/README.md.
- Select only the columns you need. `LIMIT` doesn't lower cost.

## Audit records

- [Other/audit_protocol.md](Other/audit_protocol.md) is how I work with and check the agent. [Other/audit_log.md](Other/audit_log.md) has examples of me doing it.
- Follow the project-audit skill to decide what belongs in the log, write entries, and propose changes to the protocol.

## Git

- At the start of each work session, remind me to run `git pull` before we change anything.
- I run every commit, merge, and push myself. Tell me when it's a good time to commit, and give me the commands.

## Project facts

- **Data:** `bigquery-public-data.cms_synthetic_patient_data_omop`, synthetic Medicare records. The CMS guide is [Other/metadata.pdf](Other/metadata.pdf).
- **Status:** State rates and the Texas gap are done. The model is built and tested (roc_auc 0.548, weak). No recommendation yet; see To-do.
- **Hospital rows:** `condition_occurrence.condition_type_concept_id = 38000200`.
- **No `visit_occurrence` table.** Several diagnosis rows can belong to one stay, so group `condition_occurrence` by `(person_id, visit_occurrence_id)` to count each stay once.
- **No true admission or discharge dates.** The original CMS files had them (`CLM_ADMSN_DT`, `NCH_BENE_DSCHRG_DT`), but the BigQuery version dropped them. `condition_start_date` and `condition_end_date` are the bill's start and end dates, used instead.
- **Readmission:** the patient's next stay starts 1–30 days after this one ends. Rows where the next stay starts on or before the day this one ends are duplicate bills and are removed (sql/README.md, step 2).
- **Benchmark:** 9.18%. Rank states from lowest rate and add whole states until they cover at least 10% of stays, then pool them. Simplified from Weissman et al., "Achievable benchmarks of care: the ABCs of benchmarking" (https://pubmed.ncbi.nlm.nih.gov/10461579/).
- **State** = the patient's home state (`person.location_id` → `location.state`).
- **Don't analyze provider or hospital IDs;** CMS says they're random (manual, p. 15).
- **Texas:** 87,088 stays, 9,055 readmissions, about 1,057 above the benchmark. The $14.1 million uses $13,300 per readmission; it is not an estimate of preventable cost or savings.
- These are synthetic records. Don't draw conclusions about real states or hospitals.

## To-do

- [ ] Compare the model with the simple rule (call everyone hospitalized in the last 6 months) on the test patients. Walk me through the approach before we write the query.
- [ ] Test whether Texas's patient mix explains its gap: use the model (trained without state) to add up the readmissions it expects for Texas stays, and compare with the 9,055 that happened. Walk me through this approach before we use it.
