"""Check the published comparison and reference-selection edge cases."""

from fractions import Fraction
import unittest

from reproduce import DEFAULT_INPUT, STATE_CODES, StateCount, calculate, read_counts


class ReproductionTests(unittest.TestCase):
    def test_observed_sheet_totals_and_texas_comparison(self):
        rows = read_counts(DEFAULT_INPUT)
        self.assertEqual({r.state for r in rows}, STATE_CODES)
        result = calculate(rows)
        self.assertEqual(result["total_stays"], 1313758)
        self.assertEqual(result["total_readmissions"], 120503)
        self.assertEqual(result["reference_stays"], 225105)
        self.assertEqual(result["reference_readmissions"], 19412)
        self.assertEqual(len(result["selected"]), 15)
        self.assertEqual(result["selected"][-1].state, "CA")
        self.assertEqual(result["focus"].readmissions, 8654)
        self.assertAlmostEqual(float(result["difference"]), 891.4421181226544)
        self.assertAlmostEqual(float(result["cost_equivalent"]), 11856180.171031304)

    def test_stops_at_an_exact_threshold_boundary(self):
        # Derived from observed counts: choose a threshold exactly equal to UT's share.
        rows = read_counts(DEFAULT_INPUT)
        share = Fraction(6533, sum(r.stays for r in rows))
        result = calculate(rows, share=share)
        self.assertEqual([r.state for r in result["selected"]], ["UT"])

    def test_input_order_cannot_change_reference_membership(self):
        rows = read_counts(DEFAULT_INPUT)
        normal = calculate(rows)
        reversed_result = calculate(reversed(rows))
        self.assertEqual(normal["selected"], reversed_result["selected"])

    def test_threshold_one_includes_the_full_population(self):
        result = calculate(read_counts(DEFAULT_INPUT), share=Fraction(1))
        self.assertEqual(result["reference_rate"], result["overall_rate"])

    def test_corrupted_or_duplicated_observations_are_rejected(self):
        rows = read_counts(DEFAULT_INPUT)
        with self.assertRaises(ValueError):
            calculate(rows + [rows[0]])
        with self.assertRaises(ValueError):
            calculate([StateCount("TX", 10, 11)])
        with self.assertRaises(ValueError):
            calculate([StateCount("TX", 0, 0)])
        with self.assertRaises(ValueError):
            calculate([StateCount("54", 10, 1)])


if __name__ == "__main__":
    unittest.main()
