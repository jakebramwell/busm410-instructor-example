# AGENTS.md

These are my instructions to you, the agents I work with on this project; BUSM 410 instructor example: 30-day readmission analysis in BigQuery, built with an AI agent.

## File index

| File | Use it when |
|---|---|
| [README.md](README.md) | You need the project overview or the full file list (written for people) |
| `project-audit` skill: [.agents/skills/project-audit/SKILL.md](.agents/skills/project-audit/SKILL.md) | You're starting a work session, or I check or correct your work. Open it yourself; don't count on finding it automatically. |

## How to work with me
- Keep replies short and use my plain wording. Explain the context before giving feedback. Define technical terms when needed.
- When you write in my voice (README, charter, findings, commit messages), say what something is. Don't describe it by what it isn't.
- Questions get answers, not actions. If I ask a question (including "should we...?" or "what do you think?"), reply only. Don't create, edit, or delete any file until I clearly tell you to make a change (for example, "go ahead" or "make that change"). Audit log entries also need my approval first (see the project-audit skill).
- Back claims about the data with a source (document + page). Say when something is your inference, not documented fact from the context files you're provided.
- Ask me to confirm a table or column exists before suggesting to use it. Don't assume the standard OMOP schema for this dataset.
- Use SQL and Google Sheets; do not add Python files or Python setup.
- Reference documents go in [Other/](Other/).

## Queries
- Start simple and build one step at a time.
- Process: Draft the query, I approve, then save it as `sql/NN_short_name.sql`.
- SQL files get a one-line header only (`-- Step N: ... See sql/README.md for notes.`). All notes go in [sql/README.md](sql/README.md) (purpose, cost, result, decision...keep it brief).
- Before I run a query, ask me for the estimated data scanned that the BigQuery editor shows, and record it in [sql/README.md](sql/README.md).
- Select only the columns needed. `LIMIT` doesn't lower cost.

## Audit records
- [Other/audit_protocol.md](Other/audit_protocol.md) is my process for working with and checking the agent. [Other/audit_log.md](Other/audit_log.md) gives examples of me doing that.
- Read the [project-audit skill](.agents/skills/project-audit/SKILL.md) at the start of a work session. Follow it to decide what belongs in the log, write entries, and propose protocol changes.

## Git
- At the start of each work session, remind me to run git pull before we change anything.
- I run every commit, merge, and push myself. Tell me when it's a good time to commit, and give me the commands.

## Project facts
- Dataset: `bigquery-public-data.cms_synthetic_patient_data_omop` (synthetic; CMS manual in [Other/metadata.pdf](Other/metadata.pdf)).
- Plan: compare state rates → show the Texas gap and its size → build a stay-level model (training and test data will be split by patient) and compare it with a simple rule model to inform the recommendation. A prediction model alone does not prove why the gap exists.
- Inpatient rows: `condition_occurrence.condition_type_concept_id = 38000200`.
- No `visit_occurrence` table. Several diagnosis rows can belong to one stay. Group `condition_occurrence` by `(person_id, visit_occurrence_id)` to count each stay once.
- No discharge date. `condition_end_date` is the claim end date used as a stand-in. Claim start date is also used as a stand-in for admission.
- The current readmission flag uses the immediately next stay starting 2–30 days after claim end. The 2-day minimum is a project assumption that still needs checking.
- Benchmark: 8.62%, adapting the Achievable Benchmarks of Care idea: pool the lowest-rate whole states until their cumulative share first reaches at least 10% of eligible stays. This does not include the paper's small-group adjustment. Source: Weissman et al., "Achievable benchmarks of care: the ABCs of benchmarking" (https://pubmed.ncbi.nlm.nih.gov/10461579/).
- State = patient's home state (`person.location_id` → `location.state`).
- Don't analyze provider or care site IDs; CMS says they're random (manual, p. 15).
- Texas: 90,016 stays, 8,654 recorded readmissions, about 891 events above the benchmark expectation. The $11.9 million cost estimate uses $13,300 per event; it is not an estimate of preventable events or savings.
- These are synthetic records. Do not infer actual state or provider performance.

## To-do
- [ ] Test whether Texas's patient mix explains the gap. Train the model without state, add up its predicted readmissions for Texas stays (expected), and compare with the 8,654 recorded readmissions (observed). I need to understand this approach before we use it; walk me through it when we get to the model.
