model (
  name prod.debank_data_latest,
  kind view
);

with

latest_prices as (
  select max_by(avg_eth_usd_price, block_date) as avg_eth_usd_price
  from wallets.main.capital_pool
),

debank_data_latest as (
  select
    d.wallet,
    d.protocol,
    d.chain,
    max_by(d.net_usd_value, d.load_ts) as net_usd_value,
    max_by(d.asset_usd_value, d.load_ts) as asset_usd_value,
    max_by(d.debt_usd_value, d.load_ts) as debt_usd_value,
    max_by(d.net_usd_value / p.avg_eth_usd_price, d.load_ts) as net_eth_value,
    max_by(d.asset_usd_value / p.avg_eth_usd_price, d.load_ts) as asset_eth_value,
    max_by(d.debt_usd_value / p.avg_eth_usd_price, d.load_ts) as debt_eth_value,
    max(d.load_ts) as load_ts
  from wallets.prod.debank_data d
    cross join latest_prices p
  group by 1, 2, 3
)

select
  wallet::varchar as wallet,
  protocol::varchar as protocol,
  chain::varchar as chain,
  net_usd_value::double as net_usd_value,
  asset_usd_value::double as asset_usd_value,
  debt_usd_value::double as debt_usd_value,
  net_eth_value::double as net_eth_value,
  asset_eth_value::double as asset_eth_value,
  debt_eth_value::double as debt_eth_value,
  load_ts::timestamp as load_ts
from debank_data_latest;
