# Findings

*Synthetic Medicare data (CMS DE-SynPUF), inpatient stays 2008–2010. Results describe this dataset, not real Medicare.*

## Why readmissions

When a patient goes back into the hospital within 30 days of leaving, it often signals a gap in care: a missed follow-up, a medication problem, a discharge that came too soon. These readmissions are expensive, and Medicare has penalized hospitals for high readmission rates since 2012. So the question is: **where are readmissions higher than they should be, and what does that cost?**

## Setting the bar

Across all 1.3 million inpatient stays, 9.16% were followed by a readmission within 30 days. But the average isn't the right target, because it includes the states that perform poorly. Instead, the benchmark is what the best-performing states actually achieve.

Using the Achievable Benchmarks of Care method, we took the lowest-rate states until they covered at least 10% of all stays (15 states) and pooled their rate: **8.62%**.

## Where the gap is

Most states sit above that benchmark, but Texas stands out. It has one of the highest rates (9.61%), and with 90,016 stays it's one of the largest states in the data, so its gap translates into more excess readmissions than any other state.

![Hospital stays by Texas residents are readmitted above the benchmark](visuals/texas_readmission_gap.png)

## How big the problem is

| Measure | Texas |
|---|---|
| Inpatient stays | 90,016 |
| 30-day readmission rate | 9.61% |
| Gap vs. benchmark (8.62%) | +0.99 points |
| Excess readmissions | about 891 |
| Cost of excess readmissions | about $11.9 million |

Cost uses $13,300 per readmission, the average Medicare readmission cost from AHRQ's Healthcare Cost and Utilization Project (2011).

## Is it real?

A gap this size could, in principle, be luck. It isn't: the 95% confidence interval for the gap runs from **0.77 to 1.21 points**, well above zero. That's roughly 700 to 1,100 avoidable readmissions, or $9 to $15 million.

## What's next

Knowing *where* the problem is leads to the next question: **why?** The next step is a patient-level model to test whether stays by Texas residents involve sicker patients (more chronic conditions, more prior stays) or whether similar patients simply do worse there. The answer decides the recommendation: target high-risk patients, or fix the care process, such as follow-up visits after discharge.

## Limitations

- The data is synthetic. CMS altered relationships between variables to protect privacy.
- State is the patient's home state, not where they were treated.
- There's no discharge date in the data; the claim end date is used instead.
- The cost figure is from 2011, one year after the data ends.

For the problem statement and goals, see [`charter.md`](charter.md). For how the numbers were produced, see [`sql/README.md`](sql/README.md).
