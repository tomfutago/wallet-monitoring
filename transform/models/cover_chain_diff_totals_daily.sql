model (
  name prod.cover_chain_diff_totals_daily,
  kind incremental_by_time_range (
    time_column load_dt
  ),
  cron '@daily',
  audits (
    not_null(columns := (load_dt, cover_id, chain)),
    unique_combination_of_columns(columns := (load_dt, cover_id, chain))
  )
);

with cover_chain_diff_exposed_daily_agg as (
  select
    api.load_dt,
    c.cover_id,
    api.chain,
    min(c.is_plan) as is_plan,
    sum(api.net_usd_value) as usd_exposed,
    sum(api.net_eth_value) as eth_exposed,
    dense_rank() over (order by api.load_dt desc) as load_dt_dr
  from wallets.prod.cover c
    inner join wallets.prod.cover_wallet cw on c.cover_id = cw.cover_id
    inner join wallets.prod.debank_data_daily_diff api on cw.wallet = api.wallet
  where c.is_active
    and api.load_dt between @start_dt and @end_dt
  group by 1, 2, 3
  having sum(api.net_usd_value) >= 0.01
)

select
  ca.load_dt::date as load_dt,
  c.cover_id::bigint as cover_id,
  c.listing::varchar as listing,
  c.is_plan::boolean as is_plan,
  ca.chain::varchar as chain,
  c.usd_cover::double as usd_cover,
  c.eth_cover::double as eth_cover,
  ca.usd_exposed::double as usd_exposed,
  ca.eth_exposed::double as eth_exposed,
  c.cover_start_date::date as cover_start_date,
  c.cover_end_date::date as cover_end_date,
  if(coalesce(ca.load_dt_dr, 1) = 1, true, false)::boolean as is_latest
from wallets.prod.cover_agg c
  inner join cover_chain_diff_exposed_daily_agg ca on c.cover_id = ca.cover_id;
