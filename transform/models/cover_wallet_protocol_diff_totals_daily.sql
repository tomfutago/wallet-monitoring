model (
  name prod.cover_wallet_protocol_diff_totals_daily,
  kind incremental_by_time_range (
    time_column load_dt
  ),
  cron '@daily',
  audits (
    not_null(columns := (load_dt, cover_id)),
    unique_combination_of_columns(columns := (load_dt, cover_id, wallet, protocol))
  )
);

with cover_wallet_protocol_diff_exposed_daily_agg as (
  select
    api.load_dt,
    c.cover_id,
    cw.wallet,
    cw.wallet_short,
    api.protocol,
    min(c.is_plan) as is_plan,
    sum(api.net_usd_value) as usd_exposed,
    sum(api.net_eth_value) as eth_exposed
  from wallets.prod.cover c
    inner join wallets.prod.cover_wallet cw on c.cover_id = cw.cover_id
    inner join wallets.prod.debank_data_daily_diff api on cw.wallet = api.wallet
  where c.is_active
    and api.load_dt between @start_dt and @end_dt
  group by 1, 2, 3, 4, 5
  having sum(api.net_usd_value) >= 0.01
)

select
  coalesce(ca.load_dt, current_date)::date as load_dt,
  c.cover_id::bigint as cover_id,
  c.product_id::int as product_id,
  c.listing::varchar as listing,
  c.is_plan::boolean as is_plan,
  ca.wallet::varchar as wallet,
  ca.wallet_short::varchar as wallet_short,
  ca.protocol::varchar as protocol,
  c.usd_cover::double as usd_cover,
  c.eth_cover::double as eth_cover,
  ca.usd_exposed::double as usd_exposed,
  ca.eth_exposed::double as eth_exposed,
  c.cover_start_date::date as cover_start_date,
  c.cover_end_date::date as cover_end_date
from wallets.prod.cover_agg c
  left join cover_wallet_protocol_diff_exposed_daily_agg ca on c.cover_id = ca.cover_id;
