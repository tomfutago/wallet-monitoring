model (
  name prod.listing_protocol_totals_all,
  kind view
);

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
from wallets.prod.listing_protocol_totals_all_daily
where usd_exposed is null
  or load_dt = (select max(load_dt) from wallets.prod.listing_protocol_totals_all_daily);
