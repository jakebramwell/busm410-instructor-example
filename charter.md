# Project Charter

## The question

Hospital stays in some states lead to more readmissions (a return to the hospital within 30 days) than in others. Which states are above the best performers, by how much, and can we predict which patients are most likely to come back?

## Who this helps

A care-management leader deciding which patients to call after they leave the hospital. The data is synthetic (realistic but made-up), so a real decision would need to be checked against real data.

## Scope

- Data: synthetic Medicare records in BigQuery, 2008–2010.
- Each row is one hospital stay. One patient can have several.
- Compare readmission rates by the patient's home state, then look closely at Texas.

## What success looks like

- Every number can be traced back to a saved query or calculation.
- One prediction model, tested on patients it never saw, and compared with a simple rule.
- A recommendation that follows the evidence, even if that means using the simple rule instead of the model.
- An audit log showing real checks I made of the AI agent's work.
- Students can repeat the work for free in BigQuery's free tier.

Jake Bramwell owns the analysis and decisions. Results are in [findings.md](findings.md); the model is in [model/model_card.md](model/model_card.md).
