select
  load_dt,
  cover_id,
  product_id,
  listing,
  is_plan,
  wallet,
  wallet_short,
  protocol,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed,
  cover_start_date,
  cover_end_date
from prod.cover_wallet_protocol_diff_totals_daily
order by 1, 2
