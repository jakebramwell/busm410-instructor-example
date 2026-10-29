# How I Work With and Check an Agent

The agent helps me investigate, write queries, and explain results. I direct the work and check the important claims. The agent may write the record, but it must identify who actually performed each check.

| When | My process | Evidence to keep when useful |
|---|---|---|
| Starting a task | Explain the question and intended next step. Review the agent's approach before building on it. | A material assumption challenged or a change in direction |
| The agent states a fact | Ask for the source and check its relevant page, section, or schema. Separate documentation from interpretation. | Source link and the specific claim checked |
| Preparing or running SQL | Review the query and estimated scan. Check the unit counted, joins, dates, exclusions, and surprising results. | Query, output, and a reconciliation or correction |
| Evaluating a model | Compare with a simple rule. Keep final testing separate from model development and prevent use of later information. | Evaluation results and the decision they support |
| Writing the recommendation | Check that the language matches the evidence. A higher rate does not itself establish a cause, preventability, or savings. | Before/after wording and the reason for the change |
| Saving the audit record | Record meaningful checks, name the actor, link evidence, and leave unresolved items pending. | An entry in [audit_log.md](audit_log.md) |

When a check suggests a useful new practice, the agent proposes a short addition to this protocol. I approve it before it becomes an agreed rule. This protocol describes the working process; an audit entry shows when that process was actually used.

The [project-audit skill](.agents/skills/project-audit/SKILL.md) helps maintain these records during normal work. An agent's check remains agent work until a human reviews it. Approval to save a file is not evidence that its contents were verified.
