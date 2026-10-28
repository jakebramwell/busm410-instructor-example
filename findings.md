# Findings

*CMS DE-SynPUF synthetic data, 2008–2010. This is a teaching demonstration. CMS cautions that altered relationships between variables limit real-world inference (User Manual, printed pp. 1–2 and 16).*

## What the analysis shows

Using the project's reconstructed-stay definition, stays by Texas residents have a higher recorded readmission rate than a pooled reference group. This identifies a pattern to investigate within the synthetic data. It does not establish that actual Texas hospitals perform poorly.

The saved query produced **1,322,931 stays**, according to the original run notes. The connected state pivot contains **1,313,758 stays**, after excluding the row labeled `54`, with **120,503 recorded readmissions: 9.17%**. The earlier write-up reported 9.16%; these populations must be distinguished. The meaning of `54` still needs a source-backed confirmation.

## How the reference rate is calculated

Rank the 50 states plus DC from lowest to highest readmission rate. Include whole states until their cumulative share of **eligible stays** first reaches at least 10%. Pool the selected states' readmissions and stays.

The 14 lowest-rate states cover 122,486 stays, or 9.32% of the state-pivot population. Adding California gives 15 states, 225,105 stays, and 19,412 readmissions. Their pooled rate is **8.6235%, displayed as 8.62%**. Including the full crossing state explains why the group covers 17.13% of stays.

This is an **ABC-inspired reference rate**. The published Achievable Benchmarks of Care method also adjusts rankings for small provider samples; this project's raw state ranking does not implement that adjustment. The paper describes a patient-pool threshold; this project adapts it to stays. [Weissman et al., 1999](https://pubmed.ncbi.nlm.nih.gov/10461579/)

## Texas comparison

| Measure | Value |
|---|---|
| Eligible stays by Texas residents | 90,016 |
| Recorded readmissions | 8,654 |
| Readmission rate | 9.6138% |
| Gap against the pooled reference | +0.9903 percentage points |
| Difference in readmission counts at the reference rate | about 891 |
| Illustrative cost equivalent | about $11.9 million |

The count is `8,654 − (90,016 × 19,412 / 225,105)`, or about 891.44. This is a comparison with a reference rate, not an estimate of preventable events.

The cost equivalent multiplies that difference by $13,300. That rounded assumption comes from the 2011 Medicare age-65+ totals in [HCUP Statistical Brief #172, Table 1](https://www.ncbi.nlm.nih.gov/books/NBK206781/table/sb172.t1/): $24.0 billion divided by 1.8 million readmissions. These are hospital costs, not insurer payments, marginal savings, or a measured intervention effect. The source year and age restriction also differ from this project's full cohort.

These aggregate checks reproduce the visible Sheet calculations. They do not independently validate the source query's stay construction or outcome labels.

## Existing chart

![Existing state comparison chart](visuals/texas_readmission_gap.png)

The existing chart preserves the earlier presentation. Its benchmark label should say "ABC-inspired reference." Its confidence interval remains unverified, and its cost annotation should be read as the illustrative cost equivalent above. The workbook inputs were inspected without editing or refreshing the Sheet.

## Uncertainty and limitations

- The original gap interval of 0.77–1.21 percentage points is retained here as a historical result awaiting its formula and assumptions. Do not use it to claim the gap cannot be due to chance. Repeated stays by the same person, selection of the reference group, and synthetic-data limitations need consideration.
- State is home state, not treatment location. Dates are claim-date proxies. The 2–30-day rule is a project definition, not a validated CMS readmission measure.
- The current query checks only the immediately next stay. Review how it handles overlapping claims or a 0–1-day next stay followed by another qualifying stay within 30 days.
- Source data are synthetic. Prediction and adjusted associations cannot establish causes of actual readmissions or prove that an intervention would work.

## Recommendation and next step

First validate the outcome definition and complete the calculation trail. Then test whether a simple risk model improves prioritization compared with a baseline. Use that result to recommend either further evaluation of the model or a simpler approach. A real care-management recommendation would need validation on suitable real data and a separate evaluation of the intervention.

See [sql/README.md](sql/README.md) for the source and calculations, [model/model_card.md](model/model_card.md) for the proposed model, and [charter.md](charter.md) for scope.
