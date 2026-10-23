# Audit Protocol

Filled in at CP1. These are the rules I follow when working with my AI assistant (Claude), which I manage like a junior analyst whose work gets checked.

## Before building on anything

1. **Ask for the source.** When the AI states a fact about the data, I ask where it came from and expect a document and page number.
2. **Separate fact from inference.** I ask whether a claim comes from the documentation or is the AI's own conclusion. I only cite documented facts in my write-up.
3. **Check the AI against the real system.** Before using a table or column the AI names, I confirm it exists in BigQuery.
4. **Question framing assumptions.** If the AI's approach doesn't match the business question (for example, home state vs. treatment location), I push back until the choice is justified or changed.

## Writing and running queries

5. **Start simple and build.** Queries go one small step at a time, so each result can be checked before the next step depends on it.
6. **Approve before saving.** The AI drafts each query, I review it, and only approved queries are saved in `sql/`.
7. **Check the cost first.** Before running, I check the estimated bytes BigQuery will scan.
8. **Verify surprising results.** If a result looks too clean or too strange, I run a second check query (for example, confirming counts add up to the table total).

## Recording the work

9. **Log every check.** Each time I catch, confirm, or correct the AI's work, it goes in `audit_log.md`.
10. **Keep AI contribution visible.** Commits the AI writes are labeled as co-authored by Claude in the GitHub history.
