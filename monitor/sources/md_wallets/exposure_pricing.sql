select
  product_id,
  plan,
  protocol,
  base_pricing,
  usd_exposed,
  eth_exposed,
  usd_annual_cost,
  eth_annual_cost
from prod.exposure_pricing
order by product_id, protocol
