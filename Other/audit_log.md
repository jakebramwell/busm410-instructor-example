# Audit Log

Each entry is a time I checked my AI agent's work, grouped by the kind of check. Entry numbers stay the same when entries move.

| Category | What it means | Entries |
|---|---|---|
| [Caught an error](#caught-an-error) | The agent was wrong, and I found it. | 5 |
| [Verified a claim](#verified-a-claim) | I checked a claim against the documentation or the data. | 5 |
| [Separated fact from opinion](#separated-fact-from-opinion) | I asked whether a claim was documented or the agent's own conclusion. | 1 |
| [Changed the analysis](#changed-the-analysis) | My judgment changed the approach or the framing. | 5 |
| [Improved the agent's instructions](#improved-the-agents-instructions) | I fixed how the agent is told to work. | 1 |

## Caught an error

| # | Date | What the AI said or did | How I checked it | Result |
|---|---|---|---|---|
| 1 | 2026-10-23 | Told me to use the `visit_occurrence` table for inpatient stays. | Compared against the actual table list in BigQuery. | **Caught an error.** The table isn't in this dataset; the AI had assumed the standard schema. We switched to rebuilding stays from `condition_occurrence`. |
| 10 | 2026-10-23 | Labeled `condition_end_date` as the discharge date. | Asked whether the documentation actually says that. | **Corrected.** Neither document says it. The conversion code (OHDSI ETL-CMS, `CMS_SynPuf_ETL_CDM_v5.py`) sets it from the claim end date (`CLM_THRU_DT`), not the discharge date (`NCH_BENE_DSCHRG_DT`). I now call it "claim end date" and treat it as a stand-in for discharge, listed as a limitation. |
| 13 | 2026-10-23 | Planned to price the problem by joining the `cost` table to each inpatient stay. | Asked what exactly the AI planned to pull from `cost`, which made it check the conversion code instead of assuming. | **Caught an error.** The OMOP conversion (OHDSI ETL-CMS) only writes costs for prescription drugs and physician claim lines. Inpatient stay payments were never loaded into `cost`, so the original plan wouldn't work. |
| 14 | 2026-10-23 | Called the pooled best-quartile rate a "standard best-practice benchmark." | Asked for a published source proving it's standard, so a healthcare analytics employer would accept it. | **Corrected an overclaim.** No source defines a best-quartile benchmark. The closest established methods are Achievable Benchmarks of Care (Weissman et al., 1999; pooled rate of top performers covering at least 10% of patients) and the CMS Hospital Value-Based Purchasing benchmark (mean of the top 10% of hospitals). Switched to a named, citable method. |
| 17 | 2026-10-29 | Added its own calculation checks as audit entry 16. | I pointed out that this log should show the human auditing the agent, not the agent's own checks. | **Corrected the scope.** Removed entry 16 and changed the agent instructions and audit skill to log human checks only. |

## Verified a claim

| # | Date | What the AI said or did | How I checked it | Result |
|---|---|---|---|---|
| 2 | 2026-10-23 | Recommended `concept`, `death`, and `cost` tables. | Asked why, and checked they existed in BigQuery. | Confirmed. All three are in the dataset, and each has a stated purpose (claim type labels, removing deaths, pricing the problem). |
| 3 | 2026-10-23 | Said provider and care site IDs are random and shouldn't be analyzed. | Asked whether that came from the CMS documentation or was made up. | Confirmed with a source: CMS DE-SynPUF User Manual, Section 6, p. 15. |
| 6 | 2026-10-23 | Query showed only 2 claim type IDs across about 290 million rows. | Questioned whether that was plausible. | Pending: running a row count by type to confirm the two counts add up to the table total. |
| 8 | 2026-10-23 | Said `stop_reason` and `condition_status_concept_id` are probably empty in this data. | Opened the table's free Preview tab in BigQuery and looked. | Confirmed for `stop_reason` (null). Also found the datetime columns are empty, so only date columns are usable. |
| 19 | 2026-10-30 | Built the 30-day readmission flag (next stay starting 2–30 days after claim end, in-stay deaths removed, last 30 days of data removed). | Asked whether the method came from a validated procedure or was just the agent's best judgment. | **Found the method was improvised.** It matches parts of CMS's all-cause readmission measure (30-day window, in-stay deaths removed, one readmission per stay, readmissions can start a new window). It skips the planned-readmission exclusion, transfer and enrollment rules, other exclusions, and risk adjustment. The 2-day rule is our own assumption. Source: CMS All-Cause Readmission measure information form (2016). |

## Separated fact from opinion

| # | Date | What the AI said or did | How I checked it | Result |
|---|---|---|---|---|
| 4 | 2026-10-23 | Said "patient level is the only level with meaningful signal." | Asked whether that was the AI's conclusion or the documentation's. | **Separated inference from fact.** The AI confirmed it was its own conclusion. In my write-up I cite the two documented facts, not the AI's wording. |

## Changed the analysis

| # | Date | What the AI said or did | How I checked it | Result |
|---|---|---|---|---|
| 5 | 2026-10-23 | Proposed assigning patients to a state by home address. | Pushed back: I care where patients were treated, not where they live. | Kept home state, with a documented reason (CMS geographic comparisons use where patients live, and treatment location in this data was derived from home location). Logged out-of-state admissions as a limitation. |
| 9 | 2026-10-23 | Drafted a saved inpatient table and pointed out it would drop outpatient rows. | Weighed the cost against how many queries the problem statement needs. | Decided not to save a table: only a few queries are needed. Kept outpatient follow-up visits as a candidate feature for the model. |
| 11 | 2026-10-23 | Added a `diagnosis_count` column to the inpatient stays query. | Asked whether the problem statement actually needs it. | **Removed.** It was a sanity check, not part of the readmission rate, and it added scan cost. Saved as a possible model feature (how sick a patient is) for later. |
| 15 | 2026-10-23 | Described the finding as "Texas patients are readmitted at 9.6%." | Pointed out the rate is calculated per inpatient stay, not per patient. | **Corrected the unit of analysis.** The finding now reads "hospital stays by Texas residents," which reflects both the stay-level rate and that state means home state, not hospital location. |
| 18 | 2026-10-29 | Described the gap as about 10 additional events per 1,000 stays without giving the number of Texas stays. | I pointed out that the rate alone did not show the size of the problem and asked for the population, extra events, and dollar estimate. | **Improved the problem framing.** The README now includes 90,016 Texas stays, about 891 additional recorded events, and about $11.9 million at the stated cost assumption. |

## Improved the agent's instructions

| # | Date | What the AI said or did | How I checked it | Result |
|---|---|---|---|---|
| 12 | 2026-10-23 | Wrote an instruction in `AGENTS.md` ("If I ask a question, answer it. Only change files when I ask."). | Asked the AI to explain what the line meant to it, to test whether another agent would read it the same way. | **Rewritten.** The line was too vague. The new version gives examples of what counts as a question vs. a go-ahead and names the two standing exceptions. The AI also admitted it had broken the rule once (adding `.gitignore` without asking). |
