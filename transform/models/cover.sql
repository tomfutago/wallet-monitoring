model (
  name prod.cover,
  kind incremental_by_unique_key (
    unique_key cover_id
  ),
  cron '@daily',
  grain cover_id,
  audits (
    not_null(columns := (cover_id, product_id)),
    unique_values(columns := (cover_id))
  )
);

select distinct
  cover_id::bigint as cover_id,
  product_id::int as product_id,
  product_name::varchar as product_name,
  product_type::varchar as product_type,
  nullif(plan, '<nil>')::varchar as plan,
  coalesce(
    nullif(plan, '<nil>'),
    concat(if(product_type = 'Multi Protocol Cover', 'Bundled - ', ''), product_name)
  )::varchar as listing,
  if(nullif(plan, '<nil>') is not null, true, false)::boolean as is_plan,
  cover_start_date::date as cover_start_date,
  cover_end_date::date as cover_end_date,
  if(cover_end_date::date >= current_date, true, false)::boolean as is_active,
  cover_asset::varchar as cover_asset,
  native_cover_amount::double as native_cover_amount,
  usd_cover_amount::double as usd_cover_amount,
  eth_cover_amount::double as eth_cover_amount,
  cover_owner::varchar as cover_owner,
  concat(left(cover_owner, 6), '..', right(cover_owner, 4))::varchar as cover_owner_short,
  '0.04' as version
from wallets.main.cover_wallets;
