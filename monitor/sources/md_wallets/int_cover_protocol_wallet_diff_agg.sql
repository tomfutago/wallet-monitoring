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
    d.name as protocol,
    max_by(d.net_usd_value, to_timestamp(cast(d._dlt_load_id as double))) as net_usd_value,
    max_by(d.asset_usd_value, to_timestamp(cast(d._dlt_load_id as double))) as asset_usd_value,
    max_by(d.debt_usd_value, to_timestamp(cast(d._dlt_load_id as double))) as debt_usd_value,
    max_by(d.net_usd_value / p.avg_eth_usd_price, to_timestamp(cast(d._dlt_load_id as double))) as net_eth_value,
    max_by(d.asset_usd_value / p.avg_eth_usd_price, to_timestamp(cast(d._dlt_load_id as double))) as asset_eth_value,
    max_by(d.debt_usd_value / p.avg_eth_usd_price, to_timestamp(cast(d._dlt_load_id as double))) as debt_eth_value,
    max(to_timestamp(cast(d._dlt_load_id as double))) as load_dt
  from wallets.debank_wallet_protocol_balance d
    left join mapping_unique_procols m on d.name = m.debank_name
    cross join latest_prices p
  where m.protocol is null
  group by 1, 2, 3, 4
)

select
  c.cover_id,
  concat(left(api.wallet, 6), '..', right(api.wallet, 4)) as wallet,
  api.protocol,
  sum(api.net_usd_value) as usd_exposed,
  sum(api.net_eth_value) as eth_exposed
from wallets.cover_wallets c
  inner join debank_data_latest api on c.cover_id = api.cover_id and c.monitored_wallet = api.wallet
group by 1, 2, 3
having sum(api.net_usd_value) >= 0.01
order by 1, 2, 3
