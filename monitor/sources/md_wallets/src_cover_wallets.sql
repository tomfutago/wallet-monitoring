select
  cover_id,
  plan_id,
  plan,
  cover_start_date,
  cover_end_date,
  cover_asset,
  native_cover_amount,
  usd_cover_amount,
  eth_cover_amount,
  cover_owner,
  monitored_wallet
from wallets.prod.cover_wallet
order by cover_id, monitored_wallet
