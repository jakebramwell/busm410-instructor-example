# Model Notes

Decisions made while building the model, in order. The finished results are in the [model card](model_card.md).

## Building the table

- **The model needs its own table.** `stays_final` has one row per stay and the answer (`readmit_30`), but no features. Some of its columns, like the days until the next stay, would give the answer away. So the model learns from a new table, `analysis_table` ([sql/04](../sql/04_analysis_table.sql)).
- **Only facts known when the patient leaves the hospital** go in as features.
- **How sick the patient is** is measured as the number of different diagnoses in the year before admission. It's simpler than picking out specific diseases.
- **Train/test split by patient:** about 80% of patients train the model and 20% test it. All of a patient's stays stay on one side, so the model is never tested on a patient it has already seen.
- **State stays out of the model.** It's kept in the table for the Texas check later.

## Choosing the "recent stay" feature

- The plan called for "average days between earlier stays." I used **days since the last stay** instead, because it's simpler to explain.
- That number is blank on a patient's first stay, and BigQuery would fill blanks with the average, which is wrong. So it goes into the model as a TRUE/FALSE flag: **in the hospital in the last 6 months?** A first stay is FALSE.
- The flag is built once, in the table, so every later query uses exactly the same version.
- It's also the simple rule the model has to beat.

## Checks on the table

- 1,281,691 rows, the same as `stays_final`, so no stays were duplicated.
- No blanks, and no impossible values: length of stay 0–35 days, age 24–101, prior stays 0–14.
- About 17% of stays are patients under 65. That fits Medicare, which also covers younger people with disabilities.
- The shortest gap since a last stay is 1 day, which confirms the duplicate-bill rows were removed.
- Hand-checked one patient (person 2): the prior-stay count goes up by one each stay, one gap of 135 days checks out by hand, and the readmission flag sits on the right stay.

## Results

- **Weak model:** score of 0.548, where 0.5 is a coin flip.
- **The model tied the simple rule:** about 13 of every 100 patients called came back, either way.
- **Decision:** recommend the rule. Details are in the [model card](model_card.md).
