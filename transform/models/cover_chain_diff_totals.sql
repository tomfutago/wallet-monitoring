model (
  name prod.cover_chain_diff_totals,
  kind view
);

with cover_chain_diff_totals_daily_ext as (
  select *, row_number() over (partition by cover_id, chain order by load_dt desc) as load_dt_rn
  from wallets.prod.cover_chain_diff_totals_daily
)

select
  cover_id::bigint as cover_id,
  product_id::int as product_id,
  listing::varchar as listing,
  is_plan::boolean as is_plan,
  chain::varchar as chain,
  usd_cover::double as usd_cover,
  eth_cover::double as eth_cover,
  usd_exposed::double as usd_exposed,
  eth_exposed::double as eth_exposed,
  cover_start_date::date as cover_start_date,
  cover_end_date::date as cover_end_date
from cover_chain_diff_totals_daily_ext
where load_dt_rn = 1;
