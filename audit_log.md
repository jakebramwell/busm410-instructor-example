# Audit Log

Added to all semester, starting at CP1. Each entry is a time I checked work from my AI assistant (Claude) instead of accepting it as given.

| # | Date | What the AI said or did | How I checked it | Result |
|---|---|---|---|---|
| 1 | 2026-10-23 | Told me to use the `visit_occurrence` table for inpatient stays. | Compared against the actual table list in BigQuery. | **Caught an error.** The table isn't in this dataset; the AI had assumed the standard schema. We switched to rebuilding stays from `condition_occurrence`. |
| 2 | 2026-10-23 | Recommended `concept`, `death`, and `cost` tables. | Asked why, and checked they existed in BigQuery. | Confirmed. All three are in the dataset, and each has a stated purpose (claim type labels, removing deaths, pricing the problem). |
| 3 | 2026-10-23 | Said provider and care site IDs are random and shouldn't be analyzed. | Asked whether that came from the CMS documentation or was made up. | Confirmed with a source: CMS DE-SynPUF User Manual, Section 6, p. 15. |
| 4 | 2026-10-23 | Said "patient level is the only level with meaningful signal." | Asked whether that was the AI's conclusion or the documentation's. | **Separated inference from fact.** The AI confirmed it was its own conclusion. In my write-up I cite the two documented facts, not the AI's wording. |
| 5 | 2026-10-23 | Proposed assigning patients to a state by home address. | Pushed back: I care where patients were treated, not where they live. | Kept home state, with a documented reason (CMS geographic comparisons use where patients live, and treatment location in this data was derived from home location). Logged out-of-state admissions as a limitation. |
| 6 | 2026-10-23 | Query showed only 2 claim type IDs across about 290 million rows. | Questioned whether that was plausible. | Pending: running a row count by type to confirm the two counts add up to the table total. |
| 7 | 2026-10-23 | Made a git commit that listed itself as co-author. | Noticed the AI's name on GitHub and asked why. | Understood: AI-written commits are labeled as co-authored, which keeps the AI's contribution visible in the project history. |
