model (
  name prod.cover_wallet_protocol_diff_totals,
  kind view
);

select
  cover_id::bigint as cover_id,
  product_id::int as product_id,
  listing::varchar as listing,
  is_plan::boolean as is_plan,
  wallet::varchar as wallet,
  wallet_short::varchar as wallet_short,
  protocol::varchar as protocol,
  usd_cover::double as usd_cover,
  eth_cover::double as eth_cover,
  usd_exposed::double as usd_exposed,
  eth_exposed::double as eth_exposed,
  cover_start_date::date as cover_start_date,
  cover_end_date::date as cover_end_date
from wallets.prod.cover_wallet_protocol_diff_totals_daily
where usd_exposed is null
  or load_dt = (select max(load_dt) from wallets.prod.cover_wallet_protocol_diff_totals_daily);
