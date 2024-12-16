select
  cover_id,
  chain_id,
  address,
  app_id,
  protocol,
  name,
  position_type,
  value,
  price,
  cast(updated_at as timestamp) as updated_at,
  inserted_at
from wallets.zerion_positions
order by cover_id, app_id, chain_id
