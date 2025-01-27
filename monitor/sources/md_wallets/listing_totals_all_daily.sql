select
  load_dt,
  product_id,
  listing,
  is_plan,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed
from prod.listing_totals_all_daily
order by 1, 2
