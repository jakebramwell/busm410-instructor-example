# Model Card

**Bottom line:** The model works only a little better than guessing. Next, we'll check whether it beats a simple rule (see To-do).

## What the model does

It gives every hospital stay a score: the chance the patient comes back to the hospital within 30 days. A care team could use the scores to decide whom to call after discharge.

| | |
|---|---|
| Predicts | `readmit_30`: was the stay followed by a readmission within 30 days? (yes/no) |
| Model | Logistic regression in BigQuery ML ([sql/05](../sql/05_train_model.sql)) |
| Features (X's) | Age, sex, length of stay, number of prior stays, hospital stay in the last 6 months (yes/no), number of conditions in the past year. Only facts known at discharge. |
| Training vs. testing | 80% of patients trained the model. The other 20% (254,776 stays) were held back to test it, like a final exam the model never studied for. Split by patient, so no patient appears in both. |

## How the data was checked

Before training, the model's table ([sql/04](../sql/04_analysis_table.sql)) was checked for problems:

- 1,281,691 rows, the same as the stays table, so no stays were duplicated.
- No blanks and no impossible values: length of stay 0–35 days, age 24–101, prior stays 0–14.
- About 17% of stays are patients under 65. That fits Medicare, which also covers younger people with disabilities.
- The shortest gap since a last stay is 1 day, which confirms the duplicate-bill rows were removed.
- One patient was checked by hand: the prior-stay count goes up by one each stay, a 135-day gap checks out, and the readmission flag sits on the right stay.

## Report card: is it any good?

`ML.EVALUATE` on the test patients ([sql/06](../sql/06_evaluate_model.sql)):

| roc_auc | accuracy | precision | recall | log_loss |
|---|---|---|---|---|
| 0.548 | 0.901 | 0.0 | 0.0 | 0.321 |

- **roc_auc 0.548 is weak.** 0.5 is a coin flip and 0.7 is useful. The model is only slightly better than guessing.
- **Ignore the 90% accuracy.** Only about 10% of stays were readmitted, so always guessing "no" also scores 90%.
- **Precision and recall are 0** because no stay scored above 50%, so the model never said "yes."

## Drivers: what the model relied on

`ML.GLOBAL_EXPLAIN` ranks the features. A higher number means the model relied on that feature more.

| Rank | Feature | Importance |
|---|---|---|
| 1 | Prior stays | 0.106 |
| 2 | Sex | 0.037 |
| 3 | Length of stay | 0.035 |
| 4 | Stay in last 6 months | 0.028 |
| 5 | Conditions in past year | 0.011 |
| 6 | Age | 0.003 |

- **Prior stays matters most, by far:** almost 3 times more than anything else. Patients who have been in the hospital before are the ones the model watches.
- **Age barely matters,** even though it does in real Medicare data. This is probably because the data is synthetic.

## To-do

- [ ] **Rerun the model so it matches the code.** The saved model was trained with two extra options that have since been removed from sql/05. Rerun sql/05, then both queries in sql/06, and update the numbers on this page if they change. Do this before comparing the model with the rule.
- [ ] **Compare the model with a simple rule.** A model is only worth using if it does better than something simpler. The rule: call everyone who was in the hospital in the last 6 months. Test both on the same test patients and see which one finds more of the people who actually came back.
- [ ] **Check whether Texas's patients explain its gap.** Use the model to estimate how many readmissions Texas would have based on who its patients are, and compare that with the 9,055 that happened.

The rule comes from LACE, a readmission score used by hospitals: van Walraven et al., "Derivation and validation of an index to predict early death or unplanned readmission after discharge from hospital to the community," *CMAJ* 182(6), 2010, pp. 551–557 ([doi:10.1503/cmaj.091117](https://doi.org/10.1503/cmaj.091117)).

## Limits

- The data is synthetic. CMS changed the relationships between variables, which likely weakened the model. Results describe this dataset only.
