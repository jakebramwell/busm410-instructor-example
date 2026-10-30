# Project Charter

## The question

Which states' 30-day readmission rates sit above a best-performer benchmark, how big is the gap, and can a simple model flag the stays most likely to be readmitted?

## The decision this supports

A care-management leader deciding where to focus follow-up after patients leave the hospital. The data is synthetic, so a real decision would need validation with real data.

## Scope

CMS synthetic patient data in BigQuery, 2008–2010. Rebuild inpatient stays, compare rates by patient home state, and investigate Texas. One row is one stay; a patient can have several.

## What success looks like

- Every number traces to a saved query or calculation.
- One model, compared with a simple prediction rule on data held out from model building.
- A recommendation that follows the evidence, including keeping the simple rule if the model adds little.
- An audit log of my real checks of the agent's work.
- Students can repeat the work in the free tier.

Jake Bramwell owns the analysis and decisions. Results are in [findings.md](findings.md); the model design is in [model/model_card.md](model/model_card.md).
