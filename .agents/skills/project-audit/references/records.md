# Audit record format

Use the project's existing format when it already captures the evidence. For new entries, a short block is easier to read than a very wide table:

```markdown
### Audit <next ID> — <actual date> — <brief issue>

- **Student/actor:** Who challenged the work and who performed the check.
- **AI contribution:** The specific claim, query, or decision being checked; tool/model if known.
- **Check and evidence:** What was actually done, with a file, cell, source section, result, or commit link.
- **Outcome:** What the evidence supports, what changed, and what remains unknown.
- **Status:** Pending check / Agent-checked; human review pending / Human-reviewed / Student-reported; supporting evidence unavailable.
- **Protocol:** Existing rule used, or a proposed addition awaiting approval, only when useful.
```

These are evidence descriptions, not grades. Use plain wording appropriate to the actual event. A rejected claim can be fully resolved and human-reviewed; "human-reviewed" does not mean the AI was correct.

## Evidence distinctions

| Situation | What can be recorded |
|---|---|
| Student asks for a source; no source is checked | Student challenge observed; resolution pending |
| Agent locates and inspects a source | Agent source check with page/section; no assumed student review |
| Student says they checked BigQuery, without output | Student-reported check; result and evidence availability stated honestly |
| Student provides output and explains the comparison | Student review supported by the supplied evidence |
| Agent runs a reconciliation query | Agent check, with executed output and query; student review remains separate |
| Student approves saving a query | Authorization; not a substantive audit by itself |
| Student spots an unsupported causal claim | A reasoning audit; link the claim and correction, no query required |
| Later evidence resolves a pending entry | Dated resolution linked to the original entry, preserving its history |

Record the event date if known. When documenting older work now, state both the recording date and the reported event date. Never assign the current date to an earlier event as if it happened today.

## Protocol content

Keep three things clear: how the student directs the agent, how the student checks consequential work, and how evidence or unresolved issues are recorded. Include source checks, data/model checks, and interpretation checks only at the detail needed for this project. Distinguish an agreed rule from a proposed rule and a practiced behavior from a future commitment.

An exact proposed addition can be presented inline: "Proposed rule: Before comparing rates, I check that the numerator and denominator describe the same population." Apply the repository's approval policy before inserting it into the protocol.
