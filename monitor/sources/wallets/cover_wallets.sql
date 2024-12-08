select
  cover_id,
  plan,
  cover_start_date,
  cover_end_date,
  cover_asset,
  sum_assured,
  cover_owner,
  monitored_wallet
from wallets.cover_wallets
