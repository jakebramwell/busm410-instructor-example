# Model Card: Prioritizing Follow-Up

**Stage: design only. The model has not been trained, and there are no model results yet.** A model card explains the job a model should do, how it will be tested, and where its use is limited.

## The decision

A care-management leader has limited follow-up capacity. The project will test whether a model can identify more stays followed by a recorded readmission than a simple rule can, while prioritizing the same number of stays.

For this teaching demonstration, set capacity at **10% of eligible stays**. This is a planning assumption, not an observed staffing limit. The same capacity must be used for the model and the comparison rule.

## The first model

| Design choice | Decision |
|---|---|
| One prediction represents | One reconstructed inpatient stay, at its claim-end-date proxy |
| What is predicted | The probability of the project's recorded 2–30-day readmission flag |
| Population | Eligible state/DC stays, with Texas results also shown separately |
| Method | Logistic regression in BigQuery ML: a model that estimates a probability for a yes/no outcome |
| Initial inputs | Number of earlier inpatient stays before the current claim starts; current claim duration |
| Information excluded | Patient/visit IDs as predictors, later admissions, future death information, outcome flags, and cost fields derived from those flags |

Both initial inputs can be derived from the existing stay fields. They are a modest starting point. Age and diagnosis features should be added only after their availability and timing are verified. Patient and visit keys can join records and break ranking ties; they do not become model predictors.

## The simple approaches to beat

**Probability check:** assign every test stay the readmission rate calculated from training data only. The model should provide better probability estimates than that constant prediction.

**Prioritization check:** rank stays by the number of earlier inpatient stays and take the top 10%. Compare how many recorded readmissions this rule captures with how many the model captures. Use the same stable visit-key tie-break for both rankings.

The **8.62% state reference** measures a descriptive difference. The **model baseline** tests whether prediction adds value. They answer different questions.

## How it will be tested

Assign patients, rather than individual stays, to stable 60% training, 20% development, and 20% final-test groups. This checks performance on people excluded from training. It does not establish future-year performance. Fit any data transformations on training data only, and build history features using only earlier events.

Use the development group to make model choices. Keep the final-test group separate until the design is fixed. Report probability error, readmissions captured at the 10% capacity, flagged stays without a readmission, and results by Texas versus other states with group sizes.

## What would change the recommendation

If the model improves the final-test comparison enough to justify its complexity, recommend further validation. If it adds little, recommend the simpler rule. Predictive associations do not establish why events occur or whether follow-up would prevent them.

**Still required before training:** validate stay/outcome definitions, write feature and split SQL, inspect available history, confirm the training run fits the free-tier setup, and save executed evaluation results. Synthetic-data success would still require real-world validation before care use.

[Preparation and checks](../sql/README.md) · [Audit evidence](../audit_log.md)
