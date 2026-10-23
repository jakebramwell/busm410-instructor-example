# AGENTS.md

Read this first. BUSM 410 instructor example: 30-day readmission analysis in BigQuery, built with an AI assistant.

## How to work with me
- Keep replies short: a couple of sentences, plain English, no undefined shorthand that I may not understand.
- Questions get answers, not actions. If I ask a question (including "should we...?" or "what do you think?"), reply only. Don't create, edit, or delete any file until I clearly tell you to make a change (for example, "go ahead" or "make that change"). Two standing exceptions: audit log entries and checkpoint commits (see below).
- Back claims about the data with a source (document + page). Say when something is your inference, not documented fact from the context files you're provided.
- Ask me to confirm a table or column exists before suggesting to use it. Don't assume the standard OMOP schema for this dataset.

## Queries
- Start simple and build one step at a time.
- Draft the query, I approve, then save it as `sql/NN_short_name.sql`.
- SQL files get a one-line header only (`-- Step N: ... See sql/README.md for notes.`). All notes go in `sql/README.md` (purpose, cost, result, decision).
- State the estimated scan cost. Select only the columns needed. `LIMIT` doesn't lower cost. No saved tables or views (decided).

## Audit records
- Every time I check, question, or correct your work, add an entry to `audit_log.md` without being asked.
- New rules or processes go in `audit_protocol.md`.

## Git
- Commit checkpoints without asking. I run `git push origin main` myself.
- Reference documents go in `Other/`.

## Project facts
- Dataset: `bigquery-public-data.cms_synthetic_patient_data_omop` (synthetic; CMS manual in `Other/metadata.pdf`).
- Plan: overall readmission rate (benchmark) → state above benchmark (problem) → excess readmissions × cost → patient-level ML model (why) → recommendation.
- Inpatient rows: `condition_occurrence.condition_type_concept_id = 38000200`.
- No `visit_occurrence` table. Stays = group `condition_occurrence` by `visit_occurrence_id`.
- No discharge date. `condition_end_date` (claim end date) is the proxy.
- A readmission must start at least 2 days after the prior claim ends.
- State = patient's home state (`person.location_id` → `location.state`).
- Don't analyze provider or care site IDs; CMS says they're random (manual, p. 15).
