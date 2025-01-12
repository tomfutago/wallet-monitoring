select
  product_id,
  listing as plan,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover
from prod.listing_agg
where is_active
  and is_plan
order by 1
