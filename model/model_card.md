# Model Card: Readmission Risk

**Status:** Proposed model. No model has been trained or evaluated in this repository. This card is a project-specific example; pending fields are not results.

## Purpose

Demonstrate whether predicted risk can help a care-management director prioritize follow-up after a stay. Use only synthetic data for the demonstration. This model cannot authorize real patient care, provider rankings, or claims of preventable costs.

## Prediction task

| Item | Proposed design |
|---|---|
| One prediction represents | One reconstructed inpatient stay |
| Prediction time | At the end of that stay, represented by the claim-end-date proxy |
| Target | The project's `readmit_30` flag; its definition needs validation before training |
| Source | Public CMS synthetic patient data in BigQuery, 2008–2010 |
| Population | Eligible stays defined in the preparation query; choose and document all-state versus Texas-only modeling before training |
| Model | Logistic regression in BigQuery ML, which estimates a probability for a yes/no outcome |
| Candidate inputs | Age, prior inpatient use, and documented diagnoses available by prediction time; exact fields and availability must be checked |
| Excluded inputs | Identifiers, next admission/date gap, `readmit_30`, `cost_per_readmit_usd`, future death dates/death-derived flags, and any later events or derived outcomes |

A diagnosis's clinical date does not by itself prove the information was available to a real-time care team. This is a retrospective demonstration using claims.

## Baseline: the simple approach to beat

For probability predictions, give every held-out stay the **readmission rate calculated from training data only**. Compare the model against that constant probability.

For prioritization, compare with a simple rule such as ordering by prior inpatient use, if that feature is verified. Apply the same follow-up capacity to both approaches. Capacity and tie handling are pending decisions to settle before comparing results.

The 8.62% state reference rate is a descriptive benchmark. It is not automatically the predictive baseline. An always-no-readmission classifier may have high accuracy because most stays have no recorded readmission; accuracy alone would be misleading.

## Evaluation plan

Keep patients separate across training, validation, and final testing for a first demonstration of generalization to unseen people. Choose the split proportions, stable assignment method, and any tuning on training/validation data before opening the final test results. Fit preprocessing on training data only.

If the intended claim is prediction of future stays, use a time-based design instead and describe whether returning patients may appear in both periods. In either design, construct history features using only information before each prediction and ensure outcome follow-up is observable. Exact split SQL and cohort counts are pending.

| Check | Why it matters | Baseline result | Model result |
|---|---|---|---|
| Log loss | Measures the quality of predicted probabilities; lower is better | Not run | Not run |
| Predicted versus observed rates by risk group | Checks whether probability estimates match observed outcomes | Not run | Not run |
| Readmissions captured at agreed follow-up capacity | Tests the decision the model is intended to support | Not run | Not run |
| Errors by home state and available age groups | Checks where performance is weaker; show group sizes | Not run | Not run |

Explain false positives (flagged stays with no readmission) and false negatives (readmissions the model misses). Keep the final test set separate from model, threshold, or capacity selection.

## Results and decision

**Pending:** training/evaluation SQL, run date, model identifier and options, split counts, metrics, uncertainty, and human review. Add links to executed artifacts when they exist. Feature associations can suggest questions; they cannot prove why readmissions occur.

Recommend the model only if its held-out benefit at the agreed capacity supports its added complexity. Otherwise recommend the simpler approach. Even a successful synthetic-data model needs real-world validation before operational use.

## Reproduce and audit

Preparation: [sql/README.md](../sql/README.md). Human checks: [audit_log.md](../audit_log.md). Before training, confirm the model type and full run plan fit the course's free-tier setup. Training cost and availability have not been checked for this proposed run.
