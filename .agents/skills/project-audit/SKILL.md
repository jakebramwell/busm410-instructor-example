---
name: project-audit
description: Maintain a student's audit protocol and evidence log during AI-assisted data analysis. Use while checking sources, SQL, model evaluation, or analytical claims, or when asked to establish or update these audit records.
---

# Project Audit

Help students demonstrate how they direct, check, and correct an agent while completing their own project. Capture meaningful evidence as the work happens. Preserve the student's existing file structure and concise writing style.

## Start from the project

Read the repository's working instructions, current audit protocol, and latest audit entries. Respect the student's authorization boundaries for queries, edits, and commits. This skill does not grant permission to execute queries, spend money, publish, or change a protocol.

Use existing audit filenames and formats. For a new project, propose a short protocol tailored to the student's actual workflow. Mark it as a draft until the student agrees. Do not describe proposed practices as habits the student has already demonstrated.

When recording an entry or proposing a protocol change, read [references/records.md](references/records.md) for the compact format and evidence distinctions.

## During normal project work

Notice substantive checks: a student challenges a source or assumption, confirms a schema, reconciles counts, tests a join or date boundary, spots leakage, compares a baseline, or limits an unsupported conclusion. Accepted work after a meaningful check also counts. Skip style feedback, routine approvals, and ordinary clarification.

Record each event near the work that produced it. Keep the claim, check, result, actor, and evidence separate. Describe the actual effect on the analysis. Link the query, workbook cell, source section, result, or commit when available. Do not invent a source, job ID, precise model version, date, reviewer, result, or link.

An observed student challenge is evidence of questioning. A verified answer is evidence of resolution. Do not combine those into "student verified the result" unless that happened.

Label agent-run checks as agent work. When the student reports checking something elsewhere, say "student-reported" and note whether supporting evidence was provided. A source request is not proof the source was inspected; a preview is not proof of a full-column property; approval to save is not validation.

If a check is proposed but not performed, label it pending only when it is a meaningful open audit issue. Keep general next steps outside the audit log. If evidence is incomplete, record what is known and the one concrete action needed to resolve it. Do not interrupt every task with a checklist or demand a formal sign-off for low-impact work.

Use the next stable entry ID. Preserve old entries and outcomes. Add a dated resolution linked to the original ID when new evidence arrives. If an existing format requires editing a row, preserve the previous pending result and append the resolution with its date and evidence. Do not backfill apparent student activity from code history or the agent's recollection.

## Grow the protocol carefully

When a meaningful check is missing from the protocol, propose one short addition tied to the observed event. Explain what future error it would help catch. Follow the repository's approval rule before editing. If approval is pending, continue other authorized work and record the proposal separately from established practice.

Update the protocol when practices change, not after every log entry. Use cross-references instead of repeating entry narratives. Remove a protocol rule only with the student's agreement, retaining the reason in version history or a brief change note.

## At a checkpoint

Summarize only what changed: checks completed, issues still pending, and any protocol addition awaiting approval. Before saving records, verify that every completed claim has corresponding evidence or is explicitly labeled as reported. Ensure the human/agent distinction remains clear. Do not add grading scores or assume a second human exists.

For a two-student project, name the actual reviewer. For an instructor working alone with an agent, record that arrangement honestly. The agent cannot certify a student's understanding or stand in as a human teammate.

## Portability

Use the actual tools available. If the agent cannot inspect a workbook, source, or BigQuery result, state the access limit and leave the relevant verification pending. The skill is a set of instructions, not a background recorder. The active agent must load it through its supported skill mechanism or an explicit repository instruction.
