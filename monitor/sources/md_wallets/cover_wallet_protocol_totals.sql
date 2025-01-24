select
  cover_id,
  product_id,
  listing,
  is_plan,
  usd_cover,
  eth_cover,
  usd_deductible,
  eth_deductible,
  usd_cover_exposed,
  eth_cover_exposed,
  coverage_ratio,
  wallet,
  wallet_short,
  protocol,
  usd_protocol_exposed,
  eth_protocol_exposed,
  usd_liability,
  eth_liability,
  cover_start_date,
  cover_end_date
from prod.cover_wallet_protocol_totals
order by cover_id, wallet, protocol
