# Model Card

A short explanation of the model: what it predicts, what data it uses, how it was tested, how it compares with a simple prediction rule, and its limits.

The model hasn't been built yet. Fill in the sections above once it is.

## Planning notes

Decisions so far on how we'll build and test the model.

| Topic | Plan | Why |
|---|---|---|
| What it predicts | `readmit_30` for each stay in `stays_final` | The same flag behind the state rates |
| First model | Logistic regression in BigQuery ML | Simple, and easy to explain |
| Features | Only what's known at discharge: age, sex, chronic conditions, length of stay, number of previous stays, and average days between previous stays (blank until a patient has two earlier stays) | Information from after discharge would make the model look better than it is |
| Training and test sets | Split by patient: about 80% of patients to training, 20% to test, with each patient's stays all on one side (for example, `MOD(ABS(FARM_FINGERPRINT(CAST(person_id AS STRING))), 10) < 8` for training) | Patients have several stays. If one patient's stays land in both sets, the model can learn that patient and score too well on the test set. |
| Year split | Considered and set aside | A split by year still puts the same patient in both sets. Combining a patient split with a year split is stricter but discards a lot of data. |
| How we judge it | On the test set only: ROC AUC from `ML.EVALUATE` (0.5 is a coin flip, 0.7 or higher is useful), and the share of the top 10% highest-scored stays that were readmitted | AUC shows overall accuracy; the top 10% is what a care manager would act on |
| Comparison | Simple rule: flag every stay where the patient had another hospital stay in the six months before admission (see below) | If the model's top 10% isn't clearly better than the rule, recommend the rule |

## Simple rule baseline

The model has to beat a simple rule to be worth using. The rule: flag every stay where the patient had another hospital stay in the six months before admission.

The rule comes from the LACE index, a widely used readmission score built from four items: **L**ength of stay, **A**cuity of the admission, **C**omorbidity, and **E**mergency department visits in the six months before admission. Our rule is a one-item version of the E that counts earlier hospital stays.

Source: van Walraven et al., "Derivation and validation of an index to predict early death or unplanned readmission after discharge from hospital to the community," *CMAJ* 182(6), 2010, pp. 551–557 ([doi:10.1503/cmaj.091117](https://doi.org/10.1503/cmaj.091117)).
