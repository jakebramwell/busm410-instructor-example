# Audit Protocol

How I direct and check my AI agent. Examples are in [audit_log.md](audit_log.md).

1. **Explain the question first.** Make sure the agent's next step fits what I'm trying to find out.
2. **Ask for sources.** When the agent states a fact about the data, ask where it came from, then check the document and page or the BigQuery table.
3. **Separate fact from opinion.** Ask whether a claim comes from the documentation, a calculation, or the agent's own interpretation.
4. **Review each query before using it.** Start simple. Check what one row is, the joins, dates, exclusions, and estimated scan. Question surprising results and run a second check when needed.
5. **Check the model.** Compare it with a simple prediction rule, tested on data held out from model building.
6. **Check the recommendation.** It should claim only what the evidence supports. A rate gap shows where to look; causes need more evidence.
7. **Log my checks.** Record meaningful questions, confirmations, and corrections, and skip routine approvals. The agent writes the entry; the check is mine.

The audit skill tells the agent how to keep these records. When a check suggests a new step, the agent proposes it and I approve it first.
