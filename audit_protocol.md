# Audit Protocol

This is how I work with and check my AI agent. Examples of these checks go in [audit_log.md](audit_log.md).

1. **Explain the question first.** Make sure the agent's next step fits what I'm trying to find out.
2. **Ask for sources.** When the agent states a fact about the data, ask where it came from. Check the document and page, or the actual BigQuery table.
3. **Separate fact from opinion.** Ask whether a claim comes from the documentation, a calculation, or the agent's interpretation.
4. **Review queries before using them.** Start simple. Check what one row represents, joins, dates, exclusions, and the estimated scan. Question surprising results and run a second check when needed.
5. **Check the model when we get there.** Compare it with a simple prediction rule and test it on data kept separate from model development.
6. **Check the recommendation.** Make sure it says what the evidence supports. A rate difference alone does not prove a cause or show which events could be prevented.
7. **Keep examples of my checks.** Log meaningful questions, confirmations, and corrections. Skip routine approvals and wording changes. The agent can write the entry, but it must describe a check I actually made.

The audit skill tells the agent how to keep these records as we work. The protocol tells the reader how I check the agent. If a new check suggests a useful addition to this process, the agent proposes it and I approve it before the protocol changes.
