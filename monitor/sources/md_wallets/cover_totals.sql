select
  cover_id,
  product_id,
  listing,
  is_plan,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed,
  coverage_ratio,
  usd_deductible,
  eth_deductible,
  cover_start_date,
  cover_end_date
from prod.cover_totals
order by 1
