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
    sum(eth_exposed) as eth_exposed
  from wallets.prod.cover_wallet_enriched_daily
  where is_active
    and load_dt between @start_dt and @end_dt
  group by 1, 2, 3, 4, 5
  having sum(usd_exposed) >= 0.01
)

select
  coalesce(ca.load_dt, current_date)::date as load_dt,
  -- cover level info:
  c.cover_id::bigint as cover_id,
  ct.product_id::int as product_id,
  c.listing::varchar as listing,
  c.is_plan::boolean as is_plan,
  c.usd_cover::double as usd_cover,
  c.eth_cover::double as eth_cover,
  (c.usd_cover * 0.05)::double as usd_deductible,
  (c.eth_cover * 0.05)::double as eth_deductible,
  ct.usd_exposed::double as usd_cover_exposed,
  ct.eth_exposed::double as eth_cover_exposed,
  (c.usd_cover / ct.usd_exposed)::double as coverage_ratio,
  -- wallet/protocol level info:
  ca.wallet::varchar as wallet,
  ca.wallet_short::varchar as wallet_short,
  ca.protocol::varchar as protocol,
  ca.usd_exposed::double as usd_protocol_exposed,
  ca.eth_exposed::double as eth_protocol_exposed,
  case
    when (ca.usd_exposed - (c.usd_cover * 0.05)) < 0 then 0
    when c.usd_cover > coalesce(ct.usd_exposed, 0) then (ca.usd_exposed - (c.usd_cover * 0.05))
    else (ca.usd_exposed - (c.usd_cover * 0.05)) * (c.usd_cover / ct.usd_exposed)
  end::double as usd_liability,
  case
    when (ca.eth_exposed - (c.eth_cover * 0.05)) < 0 then 0
    when c.eth_cover > coalesce(ct.eth_exposed, 0) then (ca.eth_exposed - (c.eth_cover * 0.05))
    else (ca.eth_exposed - (c.eth_cover * 0.05)) * (c.eth_cover / ct.eth_exposed)
  end::double as eth_liability,
  c.cover_start_date::date as cover_start_date,
  c.cover_end_date::date as cover_end_date
from wallets.prod.cover_agg c
  inner join wallets.prod.cover_totals_daily ct on c.cover_id = ct.cover_id
  left join cover_wallet_protocol_exposed_daily_agg ca on ct.cover_id = ca.cover_id and ct.load_dt = ca.load_dt;
