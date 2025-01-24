model (
  name prod.cover_wallet_protocol_totals,
  kind view
);

with cover_wallet_protocol_totals_daily_ext as (
  select *, row_number() over (partition by cover_id, wallet, protocol order by load_dt desc) as load_dt_rn
  from wallets.prod.cover_wallet_protocol_totals_daily
)

select
  cover_id::bigint as cover_id,
  product_id::int as product_id,
  listing::varchar as listing,
  is_plan::boolean as is_plan,
  usd_cover::double as usd_cover,
  eth_cover::double as eth_cover,
  usd_deductible::double as usd_deductible,
  eth_deductible::double as eth_deductible,
  usd_cover_exposed::double as usd_cover_exposed,
  eth_cover_exposed::double as eth_cover_exposed,
  coverage_cover_ratio::double as coverage_cover_ratio,
  wallet::varchar as wallet,
  wallet_short::varchar as wallet_short,
  protocol::varchar as protocol,
  usd_protocol_exposed::double as usd_protocol_exposed,
  eth_protocol_exposed::double as eth_protocol_exposed,
  coverage_protocol_ratio::double as coverage_protocol_ratio,
  usd_liability::double as usd_liability,
  eth_liability::double as eth_liability,
  cover_start_date::date as cover_start_date,
  cover_end_date::date as cover_end_date
from cover_wallet_protocol_totals_daily_ext
where load_dt_rn = 1;
