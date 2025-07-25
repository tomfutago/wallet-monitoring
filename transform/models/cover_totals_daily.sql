model (
  name prod.cover_totals_daily,
  kind incremental_by_time_range (
    time_column load_dt
  ),
  cron '@daily',
  audits (
    not_null(columns := (load_dt, cover_id)),
    unique_combination_of_columns(columns := (load_dt, cover_id))
  )
);

with cover_exposed_daily_agg as (
  select
    load_dt,
    cover_id,
    sum(usd_exposed) as usd_exposed,
    sum(eth_exposed) as eth_exposed
  from wallets.prod.cover_wallet_enriched_daily
  where is_active
    and load_dt between @start_dt and @end_dt
  group by 1, 2
),

first_run as (
  select
    cover_id,
    min(load_dt) as first_run_date
  from @this_model
  group by 1
),

last_run as (
  select
    max(load_dt) as last_run_date
  from cover_exposed_daily_agg
)

select
  coalesce(ca.load_dt, fr.first_run_date, lr.last_run_date)::date as load_dt,
  c.cover_id::bigint as cover_id,
  c.product_id::int as product_id,
  c.listing::varchar as listing,
  c.is_plan::boolean as is_plan,
  c.cnt_wallet::int as cnt_wallet,
  c.usd_cover::double as usd_cover,
  c.eth_cover::double as eth_cover,
  ca.usd_exposed::double as usd_exposed,
  ca.eth_exposed::double as eth_exposed,
  (c.usd_cover / ca.usd_exposed)::double as coverage_ratio,
  (c.usd_cover * 0.05)::double as usd_deductible,
  (c.eth_cover * 0.05)::double as eth_deductible,
  c.cover_start_date::date as cover_start_date,
  c.cover_end_date::date as cover_end_date
from wallets.prod.cover_agg c
  left join cover_exposed_daily_agg ca on c.cover_id = ca.cover_id
  left join first_run fr on c.cover_id = fr.cover_id
  cross join last_run lr;
