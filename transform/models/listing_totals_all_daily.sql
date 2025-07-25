model (
  name prod.listing_totals_all_daily,
  kind incremental_by_time_range (
    time_column load_dt
  ),
  cron '@daily',
  audits (
    not_null(columns := (load_dt, product_id)),
    unique_combination_of_columns(columns := (load_dt, product_id))
  )
);

with

listing_wallet_exposed_daily_agg as (
  select
    load_dt,
    product_id,
    listing,
    sum(usd_exposed) as usd_exposed,
    sum(eth_exposed) as eth_exposed
  from wallets.prod.cover_wallet_enriched_daily
  where is_active
    and load_dt between @start_dt and @end_dt
  group by 1, 2, 3
),

first_run as (
  select
    product_id,
    min(load_dt) as first_run_date
  from @this_model
  group by 1
),

last_run as (
  select
    max(load_dt) as last_run_date
  from listing_wallet_exposed_daily_agg
)

select
  coalesce(lwa.load_dt, fr.first_run_date, lr.last_run_date)::date as load_dt,
  la.product_id::int as product_id,
  la.listing::varchar as listing,
  la.is_plan::boolean as is_plan,
  la.cnt_cover::int as cnt_cover,
  la.cnt_wallet::int as cnt_wallet,
  la.usd_cover::double as usd_cover,
  la.eth_cover::double as eth_cover,
  lwa.usd_exposed::double as usd_exposed,
  lwa.eth_exposed::double as eth_exposed
from wallets.prod.listing_agg la
  left join listing_wallet_exposed_daily_agg lwa on la.product_id = lwa.product_id
  left join first_run fr on la.product_id = fr.product_id
  cross join last_run lr;
