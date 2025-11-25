/*
model (
  name prod.listing_protocol_totals_unique_daily,
  kind incremental_by_time_range (
    time_column load_dt
  ),
  cron '@daily',
  audits (
    not_null(columns := (load_dt, product_id)),
    unique_combination_of_columns(columns := (load_dt, product_id, protocol))
  )
);
*/

model (
  name prod.listing_protocol_totals_unique_daily,
  kind view
);

with listing_exposed_daily_agg as (
  select
    load_dt,
    product_id,
    listing,
    protocol,
    sum(usd_exposed) as usd_exposed,
    sum(eth_exposed) as eth_exposed
  from (
    select distinct load_dt, wallet, product_id, listing, protocol, usd_exposed, eth_exposed
    from wallets.prod.cover_wallet_enriched_daily
    where is_active
      --and load_dt between @start_dt and @end_dt
  ) t
  group by 1, 2, 3, 4
),

/*
first_run as (
  select
    product_id,
    min(load_dt) as first_run_date
  from @this_model
  group by 1
),
*/

last_run as (
  select
    max(load_dt) as last_run_date
  from listing_exposed_daily_agg
)

select
  --coalesce(lea.load_dt, fr.first_run_date, lr.last_run_date)::date as load_dt,
  coalesce(lea.load_dt, lr.last_run_date)::date as load_dt,
  la.product_id::int as product_id,
  la.listing::varchar as listing,
  lea.protocol::varchar as protocol,
  la.is_plan::boolean as is_plan,
  la.cnt_cover::int as cnt_cover,
  la.cnt_wallet::int as cnt_wallet,
  la.usd_cover::double as usd_cover,
  la.eth_cover::double as eth_cover,
  lea.usd_exposed::double as usd_exposed,
  lea.eth_exposed::double as eth_exposed
from wallets.prod.listing_agg la
  left join listing_exposed_daily_agg lea on la.product_id = lea.product_id
  --left join first_run fr on la.product_id = fr.product_id
  cross join last_run lr;
