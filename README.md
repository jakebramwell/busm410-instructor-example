# Medicare Readmissions: Instructor Example

A worked BUSM 410 project using public BigQuery data and an AI assistant. **This is synthetic Medicare data for learning. Findings do not describe actual Texas patients or hospitals.**

**Start with [findings.md](findings.md)** for the data story. The project currently has descriptive findings; the machine learning stage is planned.

| Item | Details |
|---|---|
| Human author | Jake Bramwell |
| AI assistance | Claude for the original work; Codex for the repository review branch |
| Dataset | `bigquery-public-data.cms_synthetic_patient_data_omop` |
| Period | 2008–2010 |
| Instructor's Cloud project | `cloud-services-example`; replace with your own project when reproducing |
| Analysis workbook | [Medicare_410_Project](https://docs.google.com/spreadsheets/d/1-k3lznH6OZNAZwy39aBjoEVW0L6m0MZH7Ud-2KlPrN8/edit?usp=sharing) |

## Where things belong

| File or folder | Purpose |
|---|---|
| [charter.md](charter.md) | What we intend to investigate, for whom, and within what scope |
| [findings.md](findings.md) | What we found, the supporting evidence, and the recommendation |
| [sql/README.md](sql/README.md) | Run order, source notes, project definitions, and calculations |
| `sql/` | Profiling, preparation, and analysis queries |
| [model/model_card.md](model/model_card.md) | Model purpose, baseline, evaluation plan, results, and limits |
| `model/` | Model training, evaluation, and scoring SQL when approved, plus model results |
| `visuals/` | Charts and the instructions or files needed to reproduce them |
| [audit_protocol.md](audit_protocol.md) | The student's process for working with and checking an agent |
| [audit_log.md](audit_log.md) | Specific evidence of that process |
| [AGENTS.md](AGENTS.md) | Working instructions for an agent |
| [.agents/skills/project-audit/SKILL.md](.agents/skills/project-audit/SKILL.md) | Reusable instructions for maintaining audit records during normal project work |
| `Other/` | Source documents and the earlier relationship diagram |
| [review_proposal.md](review_proposal.md) | Instructor review and remaining decisions; not an additional student deliverable |

## Reproduce the work

1. Use your own BigQuery project. Create a `readmissions` dataset in the US location, matching the public dataset.
2. Follow [sql/README.md](sql/README.md). Replace `cloud-services-example` in the saved queries with your project ID. Step 2 uses `CREATE TABLE` and needs a new destination table name on a repeat run.
3. Check the estimated bytes before running. The existing notes report about 2.4 GB for Step 1 and 11 GB for Step 2; these are historical scan estimates, not a current cost guarantee.
4. Use Step 3 as the Connected Sheets source. Follow the documented pivot and benchmark calculations. Viewing the shared workbook does not grant access to refresh the instructor's BigQuery project.
5. Reconcile the eligible population, rates, and benchmark before regenerating charts. The confidence interval and chart-generation steps still need to be documented.

The course target is a full workflow within Google's free usage limits. Query processing, stored data, and the chosen model's training allowance must each fit that target. Current guidance: [BigQuery pricing](https://cloud.google.com/bigquery/pricing) and [sandbox limitations](https://docs.cloud.google.com/bigquery/docs/sandbox).

## Contributions

This instructor example has one human author working with AI. It does not demonstrate two-student collaboration. In a student team, name both people, state what each built, and link one substantive review performed by each student. An AI co-author label does not demonstrate a second human's contribution.
