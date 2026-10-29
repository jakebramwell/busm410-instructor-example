# Review the Branch Before You Merge

**For Jake · October 28, 2026 · Branch: `review/project-audit`**

I treated this as a hiring portfolio that is still in progress. My job was to make the work easy for an employer to understand, make the current evidence checkable, and keep the student's judgment visible. I made the changes directly on the review branch. Nothing has been merged or pushed.

The first review version mixed editorial comments with the project's story. This version separates them: the public files explain the project; this folder explains my changes to you.

## Start with these three things

1. Read the first screen of [README.md](../README.md). It should tell you the question, the finding, and the current stage.
2. Look at [the new chart](../visuals/readmission_comparison.png). It should make the comparison understandable without explaining the code.
3. Read [audit entry 16](../audit_log.md#audit-16--october-28-2026--reproduce-the-recorded-comparison). It shows a real check I performed and clearly leaves your review pending.

Then use the four review stops below. You can decide **keep**, **revise**, or **drop** for each. You do not need to approve the unfinished modeling work to keep improvements to the current story.

## 1. Can an employer follow the project?

**The context.** Your original README mostly listed files. The charter repeated a numerical problem statement, and the findings carried both the story and several claims that went beyond the calculation. A reader had to work out the project's purpose and status.

**What I changed.** The README now leads with the question, a short finding, and a chart. The charter owns the intended question and decision. Findings owns the evidence and recommendation. The recommendation is to validate the measurement and test a prioritization model before proposing an intervention.

| Before | After | Why I changed it |
|---|---|---|
| "Start here: findings.md" followed mainly by an inventory | A question, 9.61% versus 8.62%, a chart, and a clear stage statement | An employer can understand the project before navigating its files. |
| "700 to 1,100 avoidable readmissions" | A difference of about 891 recorded events at the reference rate | The calculation measures a difference; it does not identify preventable events. |
| A model will decide whether patients are sicker or care processes need fixing | A model will test whether prioritization improves on a simple rule | Prediction can inform a decision without proving its cause. |

**How you check it.** Open [README.md](../README.md), [charter.md](../charter.md), and [findings.md](../findings.md), in that order. Ask: can I explain the question, what was found, and what comes next? The README should also make it obvious that the model is not trained yet.

**The chart and numbers.** I replaced the main visual with a simpler three-way comparison: Texas, the full state/DC population, and the lower-rate reference. I removed the unverified confidence interval from the replacement, while preserving the old image as an earlier artifact.

I saved the state-level counts behind the chart and added a calculation that rebuilds the reference group. This makes the chart checkable even if the live Sheet changes. The new SQL offers the same calculation directly in BigQuery, without relying on fixed Sheet row positions.

**How you check the calculation.** Open [the input counts](../visuals/state_counts_2026-10-27.csv) and [the calculation guide](../sql/README.md). You can also run:

```sh
python3 scripts/reproduce.py
```

Expect **1,313,758 stays**, **19,412 / 225,105 = 8.6235%** for the reference, and **891.44** for the Texas difference. This uses saved counts and no Google resources. It does not recheck how the original stays were constructed.

**Merge decision:** the public story and its chart/calculation files should travel together. Keep this bundle if the reader can follow the argument and the evidence is traceable. The new cloud queries still need a live run before being called fully verified.

## 2. Does the repo show judgment when working with an agent?

**The context.** Your original audit examples were already valuable: you caught a nonexistent table, questioned the cost join, and corrected patients versus stays. I kept all 15 entries exactly as they were. The missing piece was a consistent way to distinguish what a student checked from what the agent checked.

**What I changed.** The protocol is now a short table of when to direct, check, and record the work. The reusable audit skill tells the agent to capture meaningful events as they happen. Working instructions point the agent to that skill. New entry 16 records the actual reproduction work performed by Codex, with human review pending.

**How you check it.** Read [the protocol](../audit_protocol.md), then [entry 16](../audit_log.md#audit-16--october-28-2026--reproduce-the-recorded-comparison). The entry should tell you who checked, what was checked, where the evidence is, and what is still unknown. It should not claim you checked something merely because I did.

For a simple skill demonstration, ask an agent working in this branch: "Use the project-audit skill to explain what evidence would be needed to close audit entry 6. Do not claim the check has run or edit the log." A sound answer will ask for the missing reconciliation output rather than mark the issue complete.

**Merge decision:** keep the protocol, log changes, skill, and working instructions as one bundle. The skill is useful now, but its behavior should still be observed during real student work.

## 3. Is the next modeling stage understandable and useful?

**The context.** The original `model/` folder was a placeholder. My first card also left too many design choices open. That made the next step hard to judge.

**What I changed.** I chose a modest first model: logistic regression, which estimates a yes/no event's probability. It starts with earlier inpatient use and claim duration. It will be compared with a constant probability and a simple prior-use ranking. The demonstration assumes capacity to follow up on 10% of stays; that assumption is stated explicitly.

**How you check it.** Read [the model card](../model/model_card.md). You should be able to answer: what will it predict, what simple approach must it improve on, and what result would justify recommending more work? The first sentence says the model has not been trained. No performance or clinical benefit is claimed.

**Merge decision:** this bundle is a concrete plan for the next project stage. Keep it if you want that direction; revise it if the intended decision differs. It is not approval of a trained model, because none exists yet.

## 4. What is still unfinished, and how do you choose what to merge?

**What I checked.** The saved-count calculations reproduce the story. Five automated checks pass, the replacement chart was visually inspected, and the new state-reference logic agrees with the independent calculation. [Verification record](verification.md)

**What still needs live data.** I have not rerun the public-data extraction, validated every stay/outcome label, trained the model, or verified the full workflow on a new student's free-tier account. Steps 4 and 5 are locally checked additions, not completed BigQuery jobs. The original three SQL files are unchanged.

| Bundle | Files to review | What accepting it means |
|---|---|---|
| Public story and reproducible comparison | README, charter, findings, chart/data/source guide, scripts, requirements, SQL guide, Steps 4–5 | A clearer current-stage project with checkable aggregates and explicitly unexecuted source checks |
| Working with an agent | AGENTS, CLAUDE pointer, audit protocol, audit log, audit skill | A documented process that distinguishes human and agent work |
| Modeling direction | `model/model_card.md` and `model/notes.md` | A proposed next stage, with results still pending |
| Instructor review materials | This folder and `review_proposal.md` | A record of these changes for you; not an extra student assignment |

For a before/after view, compare the branch with `main` in your Git viewer. Red lines are removed text; green lines are added text. A **merge** would bring the chosen changes into `main`; reviewing them does not do that.

If you prefer the terminal, this command only displays a comparison:

```sh
git diff main review/project-audit -- README.md
```

You can decide in plain language, for example: "Keep the story and audit workflow; revise the model plan." A partial merge should include the supporting files and adjust navigation to match. Do not cherry-pick a later commit in isolation: this branch also includes the first review commit, `530403a`, and the additions depend on one another.

Your pre-existing deletion of `visuals/notes.md` remains outside these commits. Nothing has been pushed or merged.
