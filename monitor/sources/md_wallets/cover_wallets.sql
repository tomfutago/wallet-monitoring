select
  cover_id,
  product_id,
  product_name,
  product_type,
  plan,
  listing,
  is_plan,
  cover_start_date,
  cover_end_date,
  is_active,
  cover_asset,
  native_cover_amount,
  usd_cover_amount,
  eth_cover_amount,
  cover_owner,
  wallet
from prod.cover_wallet
where is_active
order by cover_id, wallet
