# Audit Protocol

How I direct and check my AI agent. Examples are in [audit_log.md](audit_log.md).

1. **Explain the objective first.** Make sure the agent's next step fits the objective.
2. **Ask for sources.** When the agent states a fact about the data, ask where it came from, then check the document and page or the BigQuery table.
3. **Separate fact from opinion.** Ask whether a claim comes from the documentation, a calculation, or the agent's own interpretation.
4. **Describe the query I want.** Tell the agent exactly what the result should look like: what one row is and which columns.
5. **Review the draft.** Read each line of the query and check the estimated scan before running it.
6. **Run it and question surprises.** Run it in BigQuery and push back on any result that looks off.
7. **Log my checks.** When I catch, confirm, or correct something, the agent logs it. I make the check; the agent writes it up.

## General rules

- **Question what doesn't make sense.** When something an agent wrote doesn't quite make sense, I question it until I get an answer that does. That's where I find most mistakes.

The audit skill tells the agent how to keep these records. When a check suggests a new step, the agent proposes it and I approve it first.
