# Audit Protocol

This is my process for working with and checking an AI assistant. The agent can draft records as we work. I remain responsible for the decisions and checks attributed to me. Specific examples belong in [audit_log.md](audit_log.md).

## Agree on the work

1. Define the question, next step, and what I will check. Use [AGENTS.md](AGENTS.md) for repository instructions. The reusable [project-audit skill](.agents/skills/project-audit/SKILL.md) helps record the process.
2. Keep questions separate from permission to edit. Review queries before they are saved, and check estimated bytes before they run. Confirm the chosen ML workflow fits the course's free-tier setup.

## Check before building on an answer

3. **Verify sources and meaning.** For a factual claim, check the source and its relevant page or section. Label documented facts, analytical findings, and interpretations separately. Analytical findings are valid when linked to reproducible calculations.
4. **Check the real schema.** Confirm tables and columns in BigQuery. A familiar standard or the agent's memory does not establish this dataset's structure.
5. **Check definitions and calculations.** Identify what one row represents, the numerator and denominator, date windows, joins, missing values, and exclusions. Use a direct calculation or a second query when needed. A preview supports only what was visible in that preview.
6. **Challenge the interpretation.** Check home versus treatment location, claims versus stays, association versus cause, excess versus preventable events, and assumed costs versus achievable savings.
7. **Check model evaluation.** Compare with a simple baseline, prevent use of future information, and keep final test data separate from model selection. Review errors relevant to the proposed decision.

## Keep evidence as we work

8. Record meaningful checks and corrections during the project. Include work accepted after a substantive check. Skip routine approvals, style changes, and ordinary clarification.
9. Identify who performed each check: the human, the agent, or another reviewer. Link the checked artifact and evidence when available. If I report a check outside the conversation, label it as reported unless evidence is supplied.
10. Keep uncertainty visible. An agent-proposed check is pending. An agent-run check is not automatically human-reviewed. Record a later resolution without erasing the earlier issue.
11. When a new check suggests a useful change to this process, the agent proposes the exact addition and why it helps. I approve protocol changes before they are made. Explicit permission to revise the protocol counts; routine approval of a query does not.

AI assistance should be disclosed in the README and, when applicable, commit history. Attribution alone does not establish that the work was checked.
