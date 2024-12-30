model (
  name prod.cover,
  kind incremental_by_unique_key (
    unique_key cover_id
  ),
);

select distinct
  cover_id,
  case plan
    when 'Entry Cover' then 1
    when 'Essential Cover' then 2
    when 'Elite Cover' then 3
  end plan_id,
  plan,
  cover_start_date,
  cover_end_date,
  cover_asset,
  native_cover_amount,
  usd_cover_amount,
  eth_cover_amount,
  cover_owner
from wallets.main.cover_wallets;
