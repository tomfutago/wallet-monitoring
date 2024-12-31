model (
  name prod.debank_data_latest_match,
  kind view
);

with

mapping_unique_procols as (
  select distinct protocol, debank_id, debank_name
  from wallets.prod.plan_mapping
)

select
  d.wallet::varchar as wallet,
  m.protocol::varchar as protocol,
  d.chain::varchar as chain,
  d.net_usd_value::double as net_usd_value,
  d.asset_usd_value::double as asset_usd_value,
  d.debt_usd_value::double as debt_usd_value,
  d.net_eth_value::double as net_eth_value,
  d.asset_eth_value::double as asset_eth_value,
  d.debt_eth_value::double as debt_eth_value,
  d.load_ts::timestamp as load_ts
from wallets.prod.debank_data_latest d
  inner join mapping_unique_procols m on d.protocol = m.debank_name;
