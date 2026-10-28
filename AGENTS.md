# AGENTS.md

Read this first. BUSM 410 instructor example: readmission analysis in BigQuery, built with an AI assistant.

For ongoing project work, load [.agents/skills/project-audit/SKILL.md](.agents/skills/project-audit/SKILL.md) and follow it when maintaining audit records. This is a repository instruction; verify that the chosen agent actually loads it.

## How to work with me
- Keep replies short: a couple of sentences, plain English, no undefined shorthand that I may not understand.
- Questions get answers, not actions. If I ask a question (including "should we...?" or "what do you think?"), reply only. Don't create, edit, or delete any file until I clearly tell you to make a change (for example, "go ahead" or "make that change"). Two standing exceptions: audit log entries and checkpoint commits (see below).
- Back claims about the data with a source (document + page). Say when something is your inference, not documented fact from the context files you're provided.
- Ask me to confirm a table or column exists before suggesting to use it. Don't assume the standard OMOP schema for this dataset.

## Queries
- Start simple and build one step at a time.
- Process: Draft the query, I approve, then save it as `sql/NN_short_name.sql`.
- SQL files get a one-line header only (`-- Step N: ... See sql/README.md for notes.`). All notes go in `sql/README.md` (purpose, cost, result, decision...keep it brief).
- Request the estimated scan cost from me provided by BigQuery SQL editor and add to `sql/README.md` as part of cost. 
- Select only the columns needed. `LIMIT` doesn't lower cost.

## Audit records
- Log meaningful checks in `audit_log.md`: catching an error, requiring and checking a source, separating AI opinion from documented fact, or changing the analysis because of a check. Agent-run checks can be recorded when consequential, clearly labeled as agent work with human review pending.
- Skip clarifying questions, wording or style feedback, and routine approvals.
- Identify who performed each check. Never describe an agent check as my check or a proposed check as completed. Preserve pending issues and link later resolutions.
- `audit_protocol.md` is my overall process for working with and auditing the agent; `audit_log.md` holds examples of it. When a log entry shows a check not yet in the protocol, suggest adding it. Don't edit the protocol without my approval.

## Git
- Commit checkpoints without asking. I run `git push origin main` myself.
- Reference documents go in `Other/`.

## Project facts
- Dataset: `bigquery-public-data.cms_synthetic_patient_data_omop` (synthetic; CMS manual in `Other/metadata.pdf`).
- Plan: describe the synthetic-data gap → validate definitions and calculations → compare a patient-risk model with a simple baseline → recommend a supported next step. Prediction does not prove causation. Excess events against a reference are not automatically preventable events.
- Inpatient rows: `condition_occurrence.condition_type_concept_id = 38000200`.
- No `visit_occurrence` table. Stays = group `condition_occurrence` by `(person_id, visit_occurrence_id)`.
- Dates: `condition_start_date` and `condition_end_date` are claim-date proxies. The current SQL calls them `admit_date` and `discharge_date`; those aliases do not establish clinical admission/discharge dates.
- Current project definition: the immediately next stay starts 2–30 days after the prior claim ends, with the query's death and follow-up filters. The 2-day rule is an assumption to validate; it does not prove that split claims or transfers have been resolved.
- Reference: 8.62%, from a raw state-ranking adaptation inspired by Achievable Benchmarks of Care. Select whole states in ascending rate order until they first cover at least 10% of eligible stays, then pool their readmissions/stays. The reviewed Sheet has 19,412 / 225,105. This does not implement the paper's small-sample ranking adjustment. Source: Weissman et al., "Achievable benchmarks of care: the ABCs of benchmarking" (https://pubmed.ncbi.nlm.nih.gov/10461579/).
- State = patient's home state (`person.location_id` → `location.state`).
- Don't analyze provider or care site IDs; CMS says they're random (manual, p. 15).
- The project is a synthetic-data teaching example. Do not infer actual state or provider performance, clinical causes, or intervention savings.
- Source documentation and project-specific field/definition notes belong in `sql/README.md`; do not recreate the full CMS manual.
- This instructor example has one human author. Never invent a second student, review, model result, or completed audit.
