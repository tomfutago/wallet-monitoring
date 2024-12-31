model (
  name prod.cover_wallet,
  kind incremental_by_unique_key (
    unique_key (cover_id, monitored_wallet)
  ),
  cron '@daily',
  grain (columns := (cover_id, monitored_wallet)),
  audits (
    not_null(columns := (cover_id, monitored_wallet)),
    unique_combination_of_columns(columns := (cover_id, monitored_wallet))
  )
);

select
  cover_id::bigint as cover_id,
  case plan
    when 'Entry Cover' then 1
    when 'Essential Cover' then 2
    when 'Elite Cover' then 3
  end::int as plan_id,
  plan::varchar as plan,
  cover_start_date::date as cover_start_date,
  cover_end_date::date as cover_end_date,
  cover_asset::varchar as cover_asset,
  native_cover_amount::double as native_cover_amount,
  usd_cover_amount::double as usd_cover_amount,
  eth_cover_amount::double as eth_cover_amount,
  cover_owner::varchar as cover_owner,
  monitored_wallet::varchar as monitored_wallet
from wallets.main.cover_wallets;
