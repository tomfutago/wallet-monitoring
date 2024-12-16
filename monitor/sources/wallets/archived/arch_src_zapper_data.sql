select
  cover_id,
  network,
  address,
  app_id,
  app_name,
  balance_usd,
  cast(updated_at as timestamp) as updated_at,
  inserted_at
from wallets.zapper_positions
order by cover_id, app_id, network
