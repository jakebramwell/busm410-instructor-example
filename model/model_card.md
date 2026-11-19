# Model Card

**Bottom line:** This model is ready for inference. Its coefficients show which features have a real link to readmission. It isn't ready for prediction yet, because it doesn't beat the null classifier.

## What the model does

It gives each hospital stay a chance of readmission within 30 days. A care team could use that chance to decide whom to call after discharge.

| | |
|---|---|
| Y (what it predicts) | `readmit_30`: did the patient come back to the hospital within 30 days? (yes/no) |
| Model | Logistic regression in BigQuery ML ([sql/05](../sql/05_train_model.sql)) |
| Features (X's) | Age, sex, length of stay, prior stays, a hospital stay in the last 6 months (yes/no), and conditions in the past year. All are known when the patient leaves the hospital. |
| Training and testing | 80% of patients train the model. The other 20% (254,776 stays) test it, like a final exam the model never studied for. I split by patient, so all of a patient's stays land on the same side. |

## How I checked the data

Before training, I checked the model's table ([sql/04](../sql/04_analysis_table.sql)):

- 1,281,691 rows, the same as the stays table. No stays were duplicated.
- No blanks and no impossible values. Length of stay runs 0–35 days, age 24–101, and prior stays 0–14.
- About 17% of stays are patients under 65. That fits Medicare, which also covers younger people with disabilities.
- The shortest gap since a last stay is 1 day. That confirms the duplicate-bill rows are gone.
- I checked one patient by hand. The prior-stay count goes up by one each stay, a 135-day gap checks out, and the readmission flag sits on the right stay.

## Report card: is it any good?

`ML.EVALUATE` on the test patients ([sql/06](../sql/06_evaluate_model.sql)):

| Measure | Our number | What it means |
|---|---|---|
| accuracy | 0.901 | Share of test stays the model got right |
| baseline | 0.901 | Share right if you always guess "no readmission" (the null classifier) |
| roc_auc | 0.558 | 0.5 = no better than chance. Closer to 1.0 = better |

Our model does not beat the baseline (0.901 vs. 0.901), and its roc_auc of 0.558 is close to 0.5, so it is not ready to predict for a business decision.

Why accuracy ties the baseline: no stay scored above 50%, so the model never said "yes." It made the same calls as always guessing "no."

## Drivers: which features have a real link?

`ML.ADVANCED_WEIGHTS` ([sql/06](../sql/06_evaluate_model.sql)) gives each feature a coefficient and a p-value. The sign of the coefficient is the direction. A p-value below 0.05 means the link is likely real.

| Feature | Coefficient | p-value | Reading |
|---|---|---|---|
| Stay in last 6 months: yes (vs. no) | +0.3621 | <0.0001 | Real link, pushes readmission up |
| Length of stay (per day) | +0.0099 | <0.0001 | Real link, pushes readmission up |
| Sex: male (vs. female) | +0.0247 | 0.0005 | Real link, men slightly more likely |
| Conditions in past year (per condition) | +0.0004 | 0.0007 | Real link, a small push up |
| Prior stays (per stay) | +0.0106 | 0.0052 | Real link, pushes readmission up |
| Age (per year) | +0.0005 | 0.0411 | Real link, but only just under 0.05 |

Two notes on reading BigQuery's output:

- For sex and for a stay in the last 6 months, BigQuery also lists the comparison group (female, and no stay) with a coefficient of 0 and a p-value of NaN. I skip those rows.
- BigQuery shows a very small p-value as 0.0. I write it as <0.0001.

The two strongest drivers:

- **Stay in the last 6 months**' coefficient is positive, with a p-value below 0.0001, so holding the other features steady, a hospital stay in the last 6 months goes with a higher chance of readmission within 30 days.
- **Length of stay**'s coefficient is positive, with a p-value below 0.0001, so holding the other features steady, a longer stay goes with a higher chance of readmission within 30 days.

A real link shows what goes together in this data. Proving that a feature causes readmission would take more than this model.

## To-do

- [ ] **Check whether Texas's patients explain its gap.** Use the model to estimate how many readmissions Texas would have based on who its patients are, and compare that with the 9,055 that happened.

## Limits

- The data is synthetic. CMS changed the relationships between variables, which likely weakened the model. Results describe this dataset only.
