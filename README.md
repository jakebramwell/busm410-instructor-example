# Where Are Recorded Readmissions Higher?

**A Medicare analytics portfolio project using BigQuery, Google Sheets, and an AI assistant.**

This project investigates a difference in recorded hospital readmissions, measures its size, and prepares a model-based recommendation for a care-management leader. It demonstrates problem framing, SQL, analytical judgment, visualization, and human oversight of AI.

**Current stage:** descriptive analysis and reproducible comparison. The prediction model is the next project stage and has not been trained.

## The finding

In the synthetic records, stays by Texas residents have a **9.61%** readmission rate, compared with **8.62%** in the lower-rate reference group. The difference is about **10 additional recorded events per 1,000 stays**.

![Texas, overall, and reference readmission rates](visuals/readmission_comparison.png)

These are CMS synthetic records from 2008–2010. The comparison demonstrates a method; it does not measure actual Texas care quality or prove which readmissions could be prevented.

## Explore the work

| If you want to understand… | Start here |
|---|---|
| The question and intended decision | [Project charter](charter.md) |
| The evidence and recommendation | [Findings](findings.md) |
| Where the numbers came from | [SQL and calculation guide](sql/README.md) |
| The planned model and how it will be judged | [Model card](model/model_card.md) |
| How the human checked the agent | [Audit log](audit_log.md), using the [audit protocol](audit_protocol.md) |

## Check the result yourself

Open [the analysis workbook](https://docs.google.com/spreadsheets/d/1-k3lznH6OZNAZwy39aBjoEVW0L6m0MZH7Ud-2KlPrN8/edit?gid=1737753067#gid=1737753067), then select **Pivot Table 1**. Texas has 8,654 recorded readmissions across 90,016 stays.

For a calculation that uses no Google resources, run this from the repository folder:

```sh
python3 scripts/reproduce.py
```

It uses the saved state-level counts behind the chart and prints the rates, reference group, and Texas difference. [Chart source and regeneration instructions](visuals/README.md)

To rebuild from public data instead, follow the [BigQuery run guide](sql/README.md). The course target is Google's free usage tier; the complete cloud workflow still needs an account-level check, especially model training.

## Who did the work

Jake Bramwell is the human author. Claude assisted the initial analysis; Codex developed the review branch, reproducible comparison, and audit workflow. The log identifies human reviews separately from agent checks.

This is an instructor example with one human. Student teams should name each person's contribution and link a substantive review each performed.

**Instructor review:** [What changed, why, and how to check it](review/guide.md). Working instructions for agents are in [AGENTS.md](AGENTS.md).
