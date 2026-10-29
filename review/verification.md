# Verification Record

Checked October 28, 2026, by Codex on the local review branch. Human review is pending.

| Check | Result | What this establishes |
|---|---|---|
| Recalculate all 51 saved state/DC count rows | Passed | 1,313,758 stays, 120,503 readmissions, 15 reference members, and about 891.44 Texas events above the reference expectation |
| Reference-selection boundary, input order, full coverage, invalid/duplicate counts | Five automated tests passed, including the full-data comparison | The calculation stops at the threshold correctly and rejects the tested invalid inputs |
| BigQuery syntax parsing for Steps 4 and 5 | Passed using SQLGlot 30.25.0 | Syntax recognition, not validation of live tables or permissions |
| Step 4 reference logic against saved count rows | Passed | Its window calculation was run locally using the saved aggregate rows in place of raw aggregation; all 51 results agree with the independent exact-fraction calculation |
| Replacement chart | Generated and visually inspected | Labels, rates, units, source note, and layout match the calculation |
| Original 15 audit entries | Preserved verbatim | Earlier accounts were retained, not rewritten as newly verified events |

Calculation checks use Python's standard library. Chart generation was checked with Python 3.14 and Matplotlib 3.11.2. SQL logic was checked locally with SQLite plus the named calculation functions. These are development tools; the new SQL has not been run in BigQuery.

## Still requires a live source check

- Rebuild the saved stays and inspect Step 5's diagnostics.
- Reconcile the 9,173-stay population difference and verify the meaning of state code `54`.
- Review overlapping or adjacent claims before treating the current readmission flag as settled.
- Confirm the exact OMOP conversion-code sources reported in historical audit entries.
- Run the full workflow on a student account and confirm free-tier feasibility.
- Train and evaluate the planned model. There are no model results to approve yet.

## Repeat the local checks

From the repository folder:

```sh
python3 scripts/reproduce.py
python3 -m unittest discover -s scripts -p 'test_*.py' -v
```

These commands read the dated aggregate file, use no Google resources, and do not change the saved source data. [Chart regeneration](../visuals/README.md) is separate.
