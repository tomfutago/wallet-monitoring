model (
  name prod.cover_wallet_protocol_totals_daily,
  kind incremental_by_time_range (
    time_column load_dt
  ),
  cron '@daily',
  audits (
    not_null(columns := (load_dt, cover_id)),
    unique_combination_of_columns(columns := (load_dt, cover_id, wallet, protocol))
  )
);

with cover_wallet_protocol_exposed_daily_agg as (
  select
    load_dt,
    cover_id,
    wallet,
    wallet_short,
    protocol,
    sum(usd_exposed) as usd_exposed,
    sum(eth_exposed) as eth_exposed,
    dense_rank() over (order by load_dt desc) as load_dt_dr
  from wallets.prod.cover_wallet_enriched_daily
  where is_active
    and load_dt between @start_dt and @end_dt
  group by 1, 2, 3, 4, 5
  having sum(usd_exposed) >= 0.01
)

select
  coalesce(ca.load_dt, current_date)::date as load_dt,
  c.cover_id::bigint as cover_id,
  c.listing::varchar as listing,
  c.is_plan::boolean as is_plan,
  ca.wallet::varchar as wallet,
  ca.wallet_short::varchar as wallet_short,
  ca.protocol::varchar as protocol,
  c.usd_cover::double as usd_cover,
  c.eth_cover::double as eth_cover,
  ca.usd_exposed::double as usd_exposed,
  ca.eth_exposed::double as eth_exposed,
  (c.usd_cover / ca.usd_exposed)::double as coverage_ratio,
  (c.usd_cover * 0.05)::double as usd_deductible,
  (c.eth_cover * 0.05)::double as eth_deductible,
  (ca.usd_exposed * c.usd_cover / ct.usd_exposed)::double as usd_liability,
  (ca.eth_exposed * c.eth_cover / ct.eth_exposed)::double as eth_liability,
  c.cover_start_date::date as cover_start_date,
  c.cover_end_date::date as cover_end_date,
  if(coalesce(ca.load_dt_dr, 1) = 1, true, false)::boolean as is_latest
from wallets.prod.cover_agg c
  left join cover_wallet_protocol_exposed_daily_agg ca on c.cover_id = ca.cover_id
  left join wallets.prod.cover_totals_daily ct on c.cover_id = ct.cover_id and ca.load_dt = ct.load_dt;