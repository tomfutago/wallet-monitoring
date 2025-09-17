model (
  name prod.cover_wallet_enriched_daily,
  kind incremental_by_time_range (
    time_column load_dt
  ),
  cron '@daily',
  audits (
    not_null(columns := (load_dt, cover_id, wallet, protocol, chain)),
    unique_combination_of_columns(columns := (load_dt, cover_id, wallet, protocol, chain))
  )
);

select
  api.load_dt::date as load_dt,
  c.cover_id::bigint as cover_id,
  c.product_id::int as product_id,
  c.product_name::varchar as product_name,
  c.product_type::varchar as product_type,
  c.plan::varchar as plan,
  c.listing::varchar as listing,
  c.is_plan::boolean as is_plan,
  c.cover_start_date::date as cover_start_date,
  c.cover_end_date::date as cover_end_date,
  c.is_active::boolean as is_active,
  api.protocol::varchar as protocol,
  api.chain::varchar as chain,
  c.cover_owner::varchar as cover_owner,
  c.cover_owner_short::varchar as cover_owner_short,
  cw.wallet::varchar as wallet,
  cw.wallet_short::varchar as wallet_short,
  api.net_usd_value::double as usd_exposed,
  api.net_eth_value::double as eth_exposed
from wallets.prod.cover c
  inner join wallets.prod.cover_wallet cw on c.cover_id = cw.cover_id
  inner join wallets.prod.debank_data_daily_match api on cw.wallet = api.wallet
  inner join wallets.prod.listing_mapping m on c.product_id = m.product_id and api.protocol = m.protocol
where api.load_dt between @start_dt and @end_dt;
