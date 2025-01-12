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
  case plan
    when 'Entry Cover' then 1
    when 'Essential Cover' then 2
    when 'Elite Cover' then 3
  end::int as plan_id,
  plan::varchar as plan,
  cover_start_date::date as cover_start_date,
  cover_end_date::date as cover_end_date,
  if(cover_end_date::date >= current_date, true, false)::boolean as is_active,
  cover_asset::varchar as cover_asset,
  native_cover_amount::double as native_cover_amount,
  usd_cover_amount::double as usd_cover_amount,
  eth_cover_amount::double as eth_cover_amount,
  cover_owner::varchar as cover_owner
from wallets.main.cover_wallets;
