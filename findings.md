# Findings

*Synthetic Medicare data, 2008–2010. Results describe this dataset only.*

## The gap

Texas residents had 90,016 hospital stays, and 8,654 were followed by a readmission within 30 days: a rate of **9.61%**. The benchmark rate is **8.62%**.

| Measure | Texas |
|---|---|
| Hospital stays | 90,016 |
| Recorded readmissions | 8,654 |
| Readmission rate | 9.61% |
| Difference from the benchmark | +0.99 percentage points |
| Readmissions above the benchmark | about 891 |
| Cost of those readmissions at $13,300 each | about $11.9 million |

The 891 is the gap between what Texas recorded and what the benchmark rate would give. The $11.9 million shows its scale; how much is preventable needs further study.

![Texas readmission comparison](visuals/texas_readmission_gap.png)

The gap is 0.99 points, with a 95% confidence interval of 0.77 to 1.22 points. The whole interval is above zero, so the gap is unlikely to be chance.

## The benchmark

Rank states from lowest rate, then add whole states until they cover at least 10% of stays. The first 14 cover 9.32%; adding California crosses 10%, for 15 states (including DC), 225,105 stays, and 19,412 readmissions. Their pooled rate is **8.62%**. This adapts Achievable Benchmarks of Care ([Weissman et al., 1999](https://pubmed.ncbi.nlm.nih.gov/10461579/)), without the paper's small-group adjustment.

Cost is $13,300 per readmission, from 2011 Medicare hospital-cost totals ([HCUP Statistical Brief #172, Table 1](https://www.ncbi.nlm.nih.gov/books/NBK206781/table/sb172.t1/)).

## What's next

Check the stay definition, then build a model and compare it with a simple prediction rule. A model can flag higher-risk stays. Explaining the gap and testing whether follow-up reduces it are separate steps.

## Limits

- The data is synthetic, and CMS changed the relationships between variables. Findings describe this dataset only.
- State is the patient's home state.
- Claim start and end dates stand in for admission and discharge.
- The readmission rule is a simplified version of CMS's all-cause readmission measure, without its planned-readmission exclusion or risk adjustment. The 2-day minimum gap is our own assumption.

Calculation steps are in [sql/README.md](sql/README.md); the question and scope are in [charter.md](charter.md).
