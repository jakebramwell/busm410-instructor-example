# Model Card

**Bottom line:** The model works only a little better than guessing, and it did no better than a one-line rule. Recommendation: use the rule.

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

`ML.EVALUATE` on the test patients:

| roc_auc | accuracy | precision | recall | log_loss |
|---|---|---|---|---|
| 0.548 | 0.901 | 0.0 | 0.0 | 0.321 |

- **roc_auc 0.548 is weak.** 0.5 is a coin flip and 0.7 is useful. The model is only slightly better than guessing.
- **Ignore the 90% accuracy.** Only about 10% of stays were readmitted, so always guessing "no" also scores 90%.
- **Precision and recall are 0** because no stay scored above 50%, so the model never said "yes." That's why we compare call lists below instead.

## Drivers: what the model relied on

`ML.GLOBAL_EXPLAIN` ranks the X's; a higher importance number means the model relied on it more. `ML.ADVANCED_WEIGHTS` shows whether each one raises or lowers risk, and by how much (converted to odds with `EXP(weight)`).

| Rank | Feature | Importance | Effect on the odds of readmission | Real? (p-value) |
|---|---|---|---|---|
| 1 | Prior stays | 0.106 | +12.6% per earlier stay | Yes |
| 2 | Sex | 0.037 | Men 8.3% lower than women | Yes |
| 3 | Length of stay | 0.035 | +1% per day | Yes |
| 4 | Stay in last 6 months | 0.028 | +10.1% if yes | Yes |
| 5 | Conditions in past year | 0.011 | Slightly lower, and too small to matter | Yes |
| 6 | Age | 0.003 | None | No (p = 0.28) |

**Do the drivers matter?**

- **Prior stays is the one that matters.** A patient with 3 earlier stays has about 43% higher odds than a first-timer.
- **Sex is real but not useful.** A care team can't act on it.
- **Length of stay is real but small.**

Two surprises:

- **Age had no effect,** even though age matters in real Medicare data. This is probably because the data is synthetic.
- **More conditions slightly lowered the odds,** which is backwards. Prior stays likely takes the credit for sicker patients. This is a guess and hasn't been tested.

## Model vs. a simple rule

A model only earns its place if it beats something simpler. The rule comes from LACE, a readmission score widely used by hospitals: **call everyone who was in the hospital in the last 6 months.**

Both lists were made from the same test patients and checked against what actually happened:

- **Model's list:** line patients up from highest score to lowest and take the first 10% (25,478 stays).
- **Rule's list:** everyone who was in the hospital in the last 6 months (about 75,560 stays, or 30% of patients).

| Who gets a call | Readmitted, per 100 called | Share of all readmissions caught |
|---|---|---|
| Random patients | about 10 | — |
| Model's top 10% | about 13 | about 13% |
| Rule | about 13 | about 38% |

**They tie.** Both beat random by about 3 per 100 calls. The model's edge is only 0.35 percentage points, and a rough 95% confidence interval for it (−0.13 to +0.83 points) includes zero. Even if the edge is real, it's about one extra readmission caught per 300 calls.

One note: the 6-month flag is also one of the model's X's. So the real question was whether the other five X's add anything beyond the rule. They added almost nothing.

## Recommendation

Use the rule. It finds readmissions as well as the model, needs no model to build or maintain, and a nurse can apply it without a computer.

## Limits

- The data is synthetic. CMS changed the relationships between variables, which likely weakened the model. Results describe this dataset only.
- The rule's list is 3 times longer than the model's. A team that can only call 10% of patients would need a tighter rule, such as 2 or more prior stays (not tested).
- Not yet done: checking whether Texas's patient mix explains its gap (expected vs. observed readmissions).

Rule source: van Walraven et al., "Derivation and validation of an index to predict early death or unplanned readmission after discharge from hospital to the community," *CMAJ* 182(6), 2010, pp. 551–557 ([doi:10.1503/cmaj.091117](https://doi.org/10.1503/cmaj.091117)).
