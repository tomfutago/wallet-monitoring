select
  cover_id,
  wallet,
  wallet_short,
  is_active
from prod.cover_wallet
where is_active
order by cover_id, wallet
