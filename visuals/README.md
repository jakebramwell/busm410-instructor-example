# Chart Source and Reproduction

The current chart is [readmission_comparison.png](readmission_comparison.png). Its inputs are the 51 state/DC rows in [state_counts_2026-10-27.csv](state_counts_2026-10-27.csv).

## Where the inputs came from

The counts were read from **Pivot Table 1** in [Medicare_410_Project](https://docs.google.com/spreadsheets/d/1-k3lznH6OZNAZwy39aBjoEVW0L6m0MZH7Ud-2KlPrN8/edit?gid=1737753067#gid=1737753067) during the October 27, 2026 review. The pivot's displayed last refresh was October 23, 2026, 4:32 PM Hawaii time.

The file stores only `state`, `stays`, and `readmissions`. Rates, reference membership, and the Texas comparison are recalculated rather than copied from formatted cells. This snapshot preserves the chart's inputs even if the live Sheet changes. It is not a fresh BigQuery extraction.

## Check the numbers without installing packages

From the repository folder:

```sh
python3 scripts/reproduce.py
python3 -m unittest discover -s scripts -p 'test_*.py' -v
```

Expect 1,313,758 stays, 120,503 readmissions, a 15-member reference group, and a Texas difference of about 891.44 events. These checks use Python's standard library and no Google services.

## Regenerate the chart

Install the free plotting library in your own Python environment, then run:

```sh
python3 -m pip install -r requirements.txt
python3 scripts/reproduce.py --chart visuals/readmission_comparison.png
```

The chart was generated and inspected using Python 3.14 and Matplotlib 3.11.2. Other supported versions may render fonts differently; the counts and calculation rules stay the same.

To use a fresh extraction, export the results of [Step 4](../sql/04_state_comparison.sql) to CSV and pass its path with `--input`. The script reads the three named count columns and tolerates additional result columns. Do not overwrite the dated snapshot with a different extraction date.

## Earlier chart

[texas_readmission_gap.png](texas_readmission_gap.png) is retained as an earlier project artifact. It includes a confidence interval whose derivation has not been recovered. The current story uses the reproducible replacement, which omits that interval and uses the qualified reference definition.
