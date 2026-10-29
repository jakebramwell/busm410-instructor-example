# Project Charter

## The question

Where do recorded readmission rates exceed a lower-rate reference group, how large is the difference, and can a simple model help identify stays most likely to be followed by a readmission?

## The decision this project supports

The intended reader is a care-management leader considering how to prioritize follow-up after patients leave the hospital. This project demonstrates the analysis that could inform that decision. Because the records are synthetic, an operational recommendation would require validation with suitable real data.

## Scope

Use the public CMS synthetic patient dataset in BigQuery, covering 2008–2010. Reconstruct inpatient stays, compare rates by patient home state, and investigate the Texas difference. A stay is the unit counted; a person can contribute several stays.

## What success looks like

- A reader can trace the size of the difference to saved queries and calculations.
- One suitable machine learning model is compared with a simple prediction rule on observations kept separate from model development.
- The recommendation follows the evidence, including a recommendation to keep the simpler approach if the model adds little value.
- The audit log shows actual human checks of AI-assisted work.
- Students can repeat the work within the course's free-tier setup.

Jake Bramwell owns the analysis and decisions. AI assistance is disclosed in the README. Results belong in [findings.md](findings.md); the model's design belongs in [model/model_card.md](model/model_card.md).
