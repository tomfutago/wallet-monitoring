select
  product_id,
  listing,
  protocol,
  is_plan,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed
from prod.listing_protocol_totals_all
order by 1
