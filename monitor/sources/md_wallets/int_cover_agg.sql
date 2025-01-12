select
  cover_id,
  listing as plan,
  cover_start_date,
  cover_end_date,
  cnt_wallet,
  usd_cover,
  eth_cover
from prod.cover_agg
where is_active
  and is_plan
order by 1
