"""Recalculate the descriptive story from published state-level counts."""

import argparse
import csv
from dataclasses import dataclass
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_INPUT = ROOT / "visuals/state_counts_2026-10-27.csv"
STATE_CODES = set("AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY DC".split())


@dataclass(frozen=True)
class StateCount:
    state: str
    stays: int
    readmissions: int

    @property
    def rate(self):
        return Fraction(self.readmissions, self.stays)


def read_counts(path):
    with Path(path).open(newline="", encoding="utf-8-sig") as stream:
        reader = csv.DictReader(stream)
        if not {"state", "stays", "readmissions"}.issubset(reader.fieldnames or []):
            raise ValueError("Input needs state, stays, and readmissions columns.")
        return [StateCount(r["state"], int(r["stays"]), int(r["readmissions"])) for r in reader]


def calculate(rows, share=Fraction(1, 10), focus="TX", unit_cost=13300):
    rows = list(rows)
    if not rows or not 0 < share <= 1:
        raise ValueError("Provide observations and a reference share above zero and at most one.")
    seen = set()
    for row in rows:
        if row.state not in STATE_CODES or row.state in seen:
            raise ValueError(f"Invalid or duplicated state: {row.state}")
        if row.stays <= 0 or not 0 <= row.readmissions <= row.stays:
            raise ValueError(f"Invalid counts for {row.state}")
        seen.add(row.state)
    total = sum(r.stays for r in rows)
    total_events = sum(r.readmissions for r in rows)
    selected, cumulative = [], 0
    for row in sorted(rows, key=lambda r: (r.rate, r.state)):
        if cumulative >= share * total:
            break
        selected.append(row)
        cumulative += row.stays
    reference_events = sum(r.readmissions for r in selected)
    reference = Fraction(reference_events, cumulative)
    target = next((r for r in rows if r.state == focus), None)
    if target is None:
        raise ValueError(f"Focus state {focus} is missing.")
    difference = target.readmissions - reference * target.stays
    return {
        "total_stays": total,
        "total_readmissions": total_events,
        "overall_rate": Fraction(total_events, total),
        "selected": selected,
        "reference_stays": cumulative,
        "reference_readmissions": reference_events,
        "reference_rate": reference,
        "before_crossing_share": Fraction(cumulative - selected[-1].stays, total),
        "selected_share": Fraction(cumulative, total),
        "focus": target,
        "gap": target.rate - reference,
        "difference": difference,
        "cost_equivalent": difference * unit_cost,
        "unit_cost": unit_cost,
    }


def describe(result):
    p = lambda value: f"{float(value) * 100:.4f}%"
    return "\n".join([
        f"State population: {result['total_stays']:,} stays; {result['total_readmissions']:,} readmissions; {p(result['overall_rate'])}",
        f"Reference: {len(result['selected'])} states/DC; {result['reference_readmissions']:,} / {result['reference_stays']:,}; {p(result['reference_rate'])}",
        f"Coverage: {p(result['before_crossing_share'])} before the crossing state; {p(result['selected_share'])} after it",
        f"{result['focus'].state}: {p(result['focus'].rate)}; gap {float(result['gap']) * 100:.4f} percentage points",
        f"Count difference: {float(result['difference']):,.2f}; cost equivalent ${float(result['cost_equivalent']):,.2f}",
        "Scope: saved aggregate counts only; this does not validate source-stay construction or a clinical intervention.",
    ])


def plot(result, destination):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.ticker import PercentFormatter

    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 12})
    fig, ax = plt.subplots(figsize=(11, 5.6), dpi=180)
    fig.patch.set_facecolor("#fbfcfe")
    ax.set_facecolor("#fbfcfe")
    labels = ["Texas residents", "All states + DC", "Lower-rate reference"]
    values = [result["focus"].rate, result["overall_rate"], result["reference_rate"]]
    colors = ["#1763a6", "#728296", "#138477"]
    positions = [2, 1, 0]
    for position, rate, color in zip(positions, values, colors):
        ax.hlines(position, 0, float(rate), color=color, linewidth=5, alpha=.15)
        ax.scatter(float(rate), position, color=color, s=130, zorder=3)
        ax.text(float(rate) + .003, position, f"{float(rate):.2%}", va="center", color=color, weight="bold")
    ax.set_yticks(positions, labels)
    ax.set_xlim(0, .12)
    ax.set_ylim(-.6, 2.6)
    ax.xaxis.set_major_formatter(PercentFormatter(1, decimals=0))
    ax.set_xlabel("Stays followed by a recorded readmission", labelpad=12)
    ax.grid(axis="x", color="#dfe5eb", linewidth=.7)
    ax.set_axisbelow(True)
    ax.tick_params(axis="both", length=0, pad=10)
    for spine in ax.spines.values():
        spine.set_visible(False)
    fig.text(.07, .93, "Texas records a higher readmission rate", fontsize=21, weight="bold", color="#162b42")
    fig.text(.07, .875, "Synthetic Medicare data | Home state | 2008–2010", fontsize=12, color="#59697a")
    fig.text(.07, .13, f"Gap: +{float(result['gap']) * 100:.2f} percentage points, or about {float(result['gap']) * 1000:.1f} additional events per 1,000 stays.", fontsize=12, color="#162b42")
    fig.text(.07, .075, f"Reference: {result['reference_readmissions']:,} readmissions / {result['reference_stays']:,} stays in the lowest-rate whole states reaching 10% of stays.", fontsize=9, color="#59697a")
    fig.text(.07, .035, "Source: Medicare_410_Project pivot, observed Oct 27, 2026. Describes synthetic records; no causal or preventability estimate.", fontsize=9, color="#59697a")
    fig.subplots_adjust(left=.25, right=.94, bottom=.30, top=.79)
    destination = Path(destination)
    destination.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(destination, facecolor=fig.get_facecolor())
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--chart", type=Path, help="Also save a chart. Requires matplotlib.")
    args = parser.parse_args()
    result = calculate(read_counts(args.input))
    print(describe(result))
    if args.chart:
        plot(result, args.chart)
        print(f"Chart saved: {args.chart}")


if __name__ == "__main__":
    main()
