# Hospital Readmissions in Medicare: Example Project

This is a worked example of the BUSM 410 semester project. I used public data in Google BigQuery, with help from an AI agent, to find a business problem, measure it, and test a way to address it.

| | |
|---|---|
| Name | Jake Bramwell |
| Team | Instructor Example (no Canvas team number) |
| Data | Synthetic (realistic but made-up) Medicare patient records, 2008–2010: `bigquery-public-data.cms_synthetic_patient_data_omop` |
| Google Cloud project ID | `cloud-services-example` |

## The short version

- **The problem:** A *readmission* is when a patient leaves the hospital and has to come back within 30 days. Hospital stays by Texas residents led to a readmission **10.40%** of the time. The best-performing states averaged **9.18%**.
- **How big it is:** That gap adds up to about **1,057 extra readmissions** over three years, or about **$14.1 million** in hospital costs at $13,300 each.
- **What's in progress:** We built a prediction model to help a care team decide which patients to call after they leave the hospital. It's weak so far. Next, we'll test whether it beats a simple rule: call everyone who was in the hospital in the last 6 months.

## Files

| File | What's in it |
|---|---|
| [charter.md](charter.md) | The question and what a good answer looks like |
| [findings.md](findings.md) | The results so far |
| [model/model_card.md](model/model_card.md) | The prediction model: how it was built and tested, and what's next |
| [sql/README.md](sql/README.md) | Every query, in order, with what it did and why |
| [Analysis workbook](https://docs.google.com/spreadsheets/d/1XnLg82ePxkSuYE-KfKobFYNcuVbInf0kQ4ceUpW6lQA/edit?gid=738753992#gid=738753992) | Google Sheet connected to BigQuery; the state rates are in Pivot Table 1 |
| [Other/state_pivot_2026-10-30.csv](Other/state_pivot_2026-10-30.csv) | Saved copy of the state table from Oct 30, before the Nov 12 data fix |
| [visuals/](visuals/) | Charts |
| [Other/metadata.pdf](Other/metadata.pdf) | CMS's guide to the original data |
| [Other/ERD.pdf](Other/ERD.pdf) | Diagram of how the data tables connect ([code that draws it](Other/readmission_erd.dbml)) |

**Working with the AI agent**

| File | What's in it |
|---|---|
| [AGENTS.md](AGENTS.md) | My instructions to the AI agent |
| [CLAUDE.md](CLAUDE.md) | Points Claude to AGENTS.md |
| [Other/audit_protocol.md](Other/audit_protocol.md) | How I check the agent's work |
| [Other/audit_log.md](Other/audit_log.md) | Examples of me catching and correcting the agent |
| [.agents/skills/project-audit/SKILL.md](.agents/skills/project-audit/SKILL.md) | Tells the agent how to keep the audit records |
| [.gitignore](.gitignore) | Keeps private files off GitHub |
