# Medicare Patients: Example Project

This is a worked example of the BUSM 410 semester project, using public data in BigQuery and an AI agent.

## Problem framing

In this synthetic dataset, **90,016 hospital stays by Texas residents** were followed by a readmission **9.61%** of the time, compared with **8.62%** in the benchmark group. That difference works out to **about 891 additional recorded events** over three years. At an estimated $13,300 per readmission, that represents **about $11.9 million in hospital costs**.

This gives us a gap to investigate. It does not tell us how many events could have been prevented or how much money an intervention would save. The next step is to use a model to help inform a recommendation.

The data is synthetic Medicare data from 2008–2010. These results describe this dataset, not actual Texas patients or hospitals. The model has not been built yet.

## Explore the work

| File or link | What it's for |
|---|---|
| [charter.md](charter.md) | The question, scope, and intended decision |
| [findings.md](findings.md) | The data story, charts, and recommendation |
| [Analysis workbook](https://docs.google.com/spreadsheets/d/1-k3lznH6OZNAZwy39aBjoEVW0L6m0MZH7Ud-2KlPrN8/edit?usp=sharing) | Connected Sheets analysis; use Pivot Table 1 |
| [sql/](sql/README.md) | Queries and short notes on how the numbers were produced |
| [model/](model/notes.md) | Model work; the [model card](model/model_card.md) is a placeholder |
| [visuals/](visuals/) | Charts |
| [Other/metadata.pdf](Other/metadata.pdf) | CMS documentation for the source data |
| [Other/readmission_erd.dbml](Other/readmission_erd.dbml) | The table relationship diagram source |
| [AGENTS.md](AGENTS.md) | Instructions and project facts for the agent |
| [audit_protocol.md](audit_protocol.md) | How I work with and check the agent |
| [audit_log.md](audit_log.md) | Examples of me checking and correcting the agent |
| [Audit skill](.agents/skills/project-audit/SKILL.md) | Instructions for the agent to maintain the audit records as we work |
| [CLAUDE.md](CLAUDE.md) | Points Claude to the same working instructions |
| [.gitignore](.gitignore) | Keeps local files and credentials out of GitHub |

## Check the numbers

Open the analysis workbook listed above and select **Pivot Table 1**. Texas has 8,654 recorded readmissions across 90,016 stays. The benchmark pools 19,412 readmissions across 225,105 stays.

Use [sql/README.md](sql/README.md) to follow the queries in BigQuery. Replace the instructor's project ID, `cloud-services-example`, with your own before saving results.

## Who did the work

Jake Bramwell, working with an AI agent. The audit log shows how I checked the agent's work.
