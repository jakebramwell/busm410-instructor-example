# Project Charter

## Question and intended decision

Can a simple patient-risk model improve identification of stays followed by a readmission in this synthetic dataset, compared with a basic prediction rule?

**Proposed decision maker:** a care-management director considering which discharged patients to prioritize for follow-up. The project will demonstrate how to inform that decision. Real deployment would require real-world validation and evidence that the proposed follow-up helps.

## Opportunity to investigate

The initial analysis identifies a higher readmission rate for stays by Texas residents than a pooled reference rate. The size and supporting calculations belong in [findings.md](findings.md). A higher rate alone does not establish avoidable readmissions or poor care.

## Scope and success

- Use public CMS synthetic data in BigQuery, covering 2008–2010.
- Analyze reconstructed inpatient stays, grouped by patient and visit identifier. State means home state.
- Compare one suitable model with a simple baseline on held-out data: observations kept separate from model development.
- Recommend a next step supported by the model's measured value and limitations. A model that fails to improve the baseline is a valid finding.
- Keep the complete workflow within the course's free-tier constraints.
- Preserve evidence of human checks of AI-assisted work.

**Human author:** Jake Bramwell. **AI assistance:** Claude; Codex for this review branch. Model details and unresolved design choices belong in [model/model_card.md](model/model_card.md).

This charter sets direction. It is not a second findings report. Record a material change in scope briefly, with its reason, rather than rewriting the original intent to match later results.
