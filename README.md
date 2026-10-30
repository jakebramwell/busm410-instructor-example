# Medicare Patients: Example Project

This is a worked example of the BUSM 410 semester project, using public data in BigQuery and an AI agent (Claude Work - Opus 5.5).

| Item | Value |
|---|---|
| Name | Jake Bramwell |
| Team name | Instructor Example |
| Canvas team number | None (instructor) |
| Dataset | `bigquery-public-data.cms_synthetic_patient_data_omop` (synthetic Medicare patient records) |
| Google Cloud project ID | `cloud-services-example` |

## Problem framing

In this synthetic dataset, **90,016 hospital stays by Texas residents** were followed by a readmission to a hospital within 30 days **9.61%** of the time, compared with **8.62%** in the benchmark group. That difference works out to **about 891 additional recorded events** over three years. At an estimated $13,300 per readmission, that represents **about $11.9 million in hospital costs**.

The 8.62% benchmark uses the Achievable Benchmarks of Care (ABC) method, from [Weissman et al., "Achievable benchmarks of care: the ABCs of benchmarking" (1999)](https://pubmed.ncbi.nlm.nih.gov/10461579/).

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
| [Other/ERD.pdf](Other/ERD.pdf) | The table relationship diagram as a picture |
| **[AGENTS.md](AGENTS.md)** | Instructions and project facts for the agent |
| **[Other/audit_protocol.md](Other/audit_protocol.md)** | How I work with and check the agent |
| **[Other/audit_log.md](Other/audit_log.md)** | Examples of me checking and correcting the agent |
| **[Audit skill](.agents/skills/project-audit/SKILL.md)** | Instructions for the agent to maintain the audit records as we work |
| **[CLAUDE.md](CLAUDE.md)** | Points Claude to the same working instructions |
| [.gitignore](.gitignore) | Keeps local files and credentials out of GitHub |

## Check the numbers

Open the analysis workbook listed above and select **Pivot Table 1**. Texas has 8,654 recorded readmissions across 90,016 stays. The benchmark pools 19,412 readmissions across 225,105 stays.

Use [sql/README.md](sql/README.md) to follow the queries in BigQuery. Replace the instructor's project ID, `cloud-services-example`, with your own before saving results.

## Who did the work

Jake Bramwell, working with an AI agent. How I worked with my AI agent is documented in the files in bold above. 
