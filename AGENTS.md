# Working Instructions

This is Jake Bramwell's BUSM 410 instructor example, built with AI assistance. Start with [README.md](README.md), then load [.agents/skills/project-audit/SKILL.md](.agents/skills/project-audit/SKILL.md) when doing project work.

## Communicate with context

- Keep replies concise and use plain English. Explain a technical term when it first matters.
- Give the purpose, the proposed or completed change, and how Jake can check it. Explain what an issue affects before giving a verdict.
- A question is a request for an answer, not permission to edit. When Jake explicitly authorizes work on a branch, complete that scope without asking again for every file change.

## Work with the data

- Use [sql/README.md](sql/README.md) for definitions, sources, run order, and known limits. Verify schemas before adding fields; do not assume a standard OMOP schema.
- For new analytical work, draft a query and get approval before saving it unless the current instruction already authorizes implementing that work. Start simple, use only needed columns, and check estimated bytes before execution.
- Use the one-line SQL header convention and keep explanations in `sql/README.md`. Model-specific SQL goes in `model/`.
- Distinguish a locally tested calculation from an executed BigQuery job. Do not invent outputs, job IDs, model metrics, source links, or cost estimates.
- These records are synthetic. Separate a recorded difference from preventability, causal care quality, and intervention savings.

## Maintain audit evidence

- `audit_protocol.md` is the student's process for directing and checking an agent. `audit_log.md` holds actual examples.
- Record meaningful checks as they occur. Identify the actor and evidence; label agent checks and student-reported checks accurately. Routine approvals and wording changes do not need entries.
- Preserve historical entries and add dated resolutions for pending issues. Propose protocol additions when a new check reveals a useful practice; obtain approval before changing the protocol unless the current task already authorizes its revision.
- Never invent a second student or certify human understanding from an agent's own work.

## Save and review

- Work on the authorized branch. Checkpoint commits are allowed. Do not merge or push without an explicit instruction.
- Preserve unrelated local changes. Reference documents belong in `Other/`.
- When changing code or calculations, run the relevant checks and report exactly what was verified and what remains unexecuted.
