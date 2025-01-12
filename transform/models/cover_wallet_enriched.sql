model (
  name prod.cover_wallet_enriched,
  kind view
);

select
  c.cover_id::bigint as cover_id,
  c.product_id::int as product_id,
  c.product_name::varchar as product_name,
  c.product_type::varchar as product_type,
  c.plan_id::int as plan_id,
  c.plan::varchar as plan,
  c.is_plan::boolean as is_plan,
  c.cover_start_date::date as cover_start_date,
  c.cover_end_date::date as cover_end_date,
  c.is_active::boolean as is_active,
  api.protocol::varchar as protocol,
  api.chain::varchar as chain,
  api.wallet::varchar as wallet,
  concat(left(api.wallet, 6), '..', right(api.wallet, 4))::varchar as wallet_short,
  api.net_usd_value::double as usd_exposed,
  api.net_eth_value::double as eth_exposed
from wallets.prod.cover_wallet c
  inner join wallets.prod.debank_data_latest_match api on c.monitored_wallet = api.wallet
  inner join wallets.prod.listing_mapping m on c.product_id = m.product_id and api.protocol = m.protocol;
