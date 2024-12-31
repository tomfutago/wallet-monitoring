model (
  name prod.cover_wallet_enriched,
  kind view
);

select
  c.plan_id::int as plan_id,
  c.plan::varchar as plan,
  c.cover_id::bigint as cover_id,
  api.protocol::varchar as protocol,
  api.chain::varchar as chain,
  api.wallet::varchar as wallet,
  concat(left(api.wallet, 6), '..', right(api.wallet, 4))::varchar as wallet_short,
  api.net_usd_value::double as usd_exposed,
  api.net_eth_value::double as eth_exposed
from wallets.prod.cover_wallet c
  inner join wallets.prod.debank_data_latest_match api on c.monitored_wallet = api.wallet
  inner join wallets.prod.plan_mapping m on c.plan_id = m.plan_id and api.protocol = m.protocol;
