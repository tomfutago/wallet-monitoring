with

mapping_unique_procols as (
  select distinct protocol, debank_id, debank_name
  from wallets.plan_mapping
),

latest_prices as (
  select
    block_date,
    max_by(avg_eth_usd_price, block_date) as avg_eth_usd_price
  from wallets.capital_pool
  group by 1
),

debank_data_latest as (
  select
    d.cover_id,
    d.chain,
    d.wallet,
    m.protocol,
    max_by(d.net_usd_value, to_timestamp(cast(d._dlt_load_id as double))) as net_usd_value,
    max_by(d.asset_usd_value, to_timestamp(cast(d._dlt_load_id as double))) as asset_usd_value,
    max_by(d.debt_usd_value, to_timestamp(cast(d._dlt_load_id as double))) as debt_usd_value,
    max_by(d.net_usd_value / p.avg_eth_usd_price, to_timestamp(cast(d._dlt_load_id as double))) as net_eth_value,
    max_by(d.asset_usd_value / p.avg_eth_usd_price, to_timestamp(cast(d._dlt_load_id as double))) as asset_eth_value,
    max_by(d.debt_usd_value / p.avg_eth_usd_price, to_timestamp(cast(d._dlt_load_id as double))) as debt_eth_value,
    max(to_timestamp(cast(d._dlt_load_id as double))) as load_dt
  from wallets.debank_wallet_protocol_balance d
    inner join mapping_unique_procols m on d.name = m.debank_name
    cross join latest_prices p
  group by 1, 2, 3, 4
)

select
  cover_id,
  chain,
  wallet,
  protocol,
  net_usd_value,
  asset_usd_value,
  debt_usd_value,
  net_eth_value,
  asset_eth_value,
  debt_eth_value,
  load_dt
from debank_data_latest
order by 1, 2, 3, 4
