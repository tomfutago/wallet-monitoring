model (
  name prod.cover_totals,
  kind view
);

select
  cover_id::bigint as cover_id,
  product_id::int as product_id,
  listing::varchar as listing,
  is_plan::boolean as is_plan,
  cnt_wallet::int as cnt_wallet,
  usd_cover::double as usd_cover,
  eth_cover::double as eth_cover,
  usd_exposed::double as usd_exposed,
  eth_exposed::double as eth_exposed,
  coverage_ratio::double as coverage_ratio,
  usd_deductible::double as usd_deductible,
  eth_deductible::double as eth_deductible,
  cover_start_date::date as cover_start_date,
  cover_end_date::date as cover_end_date
from wallets.prod.cover_totals_daily
where load_dt = (select max(load_dt) from wallets.prod.cover_totals_daily)
  and 1=1;
