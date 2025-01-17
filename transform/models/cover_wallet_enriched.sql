model (
  name prod.cover_wallet_enriched,
  kind view
);

select
  cover_id::bigint as cover_id,
  product_id::int as product_id,
  product_name::varchar as product_name,
  product_type::varchar as product_type,
  plan::varchar as plan,
  listing::varchar as listing,
  is_plan::boolean as is_plan,
  cover_start_date::date as cover_start_date,
  cover_end_date::date as cover_end_date,
  is_active::boolean as is_active,
  protocol::varchar as protocol,
  chain::varchar as chain,
  cover_owner::varchar as cover_owner,
  cover_owner_short::varchar as cover_owner_short,
  wallet::varchar as wallet,
  wallet_short::varchar as wallet_short,
  usd_exposed::double as usd_exposed,
  eth_exposed::double as eth_exposed
from wallets.prod.cover_wallet_enriched_daily
where is_latest;
