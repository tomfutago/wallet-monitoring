model (
  name prod.listing_protocol_totals,
  kind view
);

with listing_protocol_totals_daily_ext as (
  select *, row_number() over (order by load_dt desc) as load_dt_rn
  from wallets.prod.listing_protocol_totals_daily
)

select
  product_id::int as product_id,
  listing::varchar as listing,
  protocol::varchar as protocol,
  is_plan::boolean as is_plan,
  cnt_cover::int as cnt_cover,
  cnt_wallet::int as cnt_wallet,
  usd_cover::double as usd_cover,
  eth_cover::double as eth_cover,
  usd_exposed::double as usd_exposed,
  eth_exposed::double as eth_exposed
from listing_protocol_totals_daily_ext
where load_dt_rn = 1;
