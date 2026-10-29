-- Step 4: Reproduce the state comparison and cumulative-stay reference. See sql/README.md for notes.

WITH state_counts AS (
  SELECT
    state,
    COUNT(*) AS stays,
    SUM(readmit_30) AS readmissions
  FROM `cloud-services-example.readmissions.stays_final`
  WHERE state IN (
    'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
    'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
    'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
    'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
    'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY', 'DC'
  )
  GROUP BY state
),
ranked AS (
  SELECT
    *,
    SAFE_DIVIDE(readmissions, stays) AS rate,
    SUM(stays) OVER () AS all_stays,
    COALESCE(
      SUM(stays) OVER (
        ORDER BY SAFE_DIVIDE(readmissions, stays), state
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
      ), 0
    ) AS preceding_stays
  FROM state_counts
),
reference AS (
  SELECT
    SUM(stays) AS reference_stays,
    SUM(readmissions) AS reference_readmissions,
    SAFE_DIVIDE(SUM(readmissions), SUM(stays)) AS reference_rate
  FROM ranked
  WHERE preceding_stays * 10 < all_stays
)
SELECT
  r.state,
  r.stays,
  r.readmissions,
  r.rate,
  r.preceding_stays * 10 < r.all_stays AS in_reference,
  b.reference_stays,
  b.reference_readmissions,
  b.reference_rate,
  r.rate - b.reference_rate AS gap,
  GREATEST(0, r.readmissions - r.stays * b.reference_rate) AS excess_readmissions,
  13300 * GREATEST(0, r.readmissions - r.stays * b.reference_rate) AS cost_equivalent_usd
FROM ranked r
CROSS JOIN reference b
ORDER BY r.rate DESC, r.state;
