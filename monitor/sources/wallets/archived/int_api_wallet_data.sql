with

mapping_unique_procols as (
  select distinct protocol, zapper_id, zapper_name, zerion_id, zerion_name
  from wallets.plan_mapping
),

prices as (
  select
    block_date,
    avg_eth_usd_price
  from wallets.capital_pool
),

zerion_data_latest as (
  select
    zp.cover_id,
    zp.chain_id as chain,
    zp.address,
    m.protocol,
    max_by(zp.value, zp.inserted_at) as amount_usd,
    max_by(zp.value / p.avg_eth_usd_price, zp.inserted_at) as amount_eth,
    max_by(cast(zp.updated_at as timestamp), zp.inserted_at) as updated_at,
    max(zp.inserted_at) as inserted_at
  from wallets.zerion_positions zp
    inner join mapping_unique_procols m on zp.app_id = m.zerion_id
    left join prices p on zp.updated_at::date = p.block_date::date
  where zp.position_type <> 'wallet'
  group by 1, 2, 3, 4
),

zapper_data_latest as (
  select
    zp.cover_id,
    zp.network as chain,
    zp.address,
    m.protocol,
    max_by(zp.balance_usd, zp.inserted_at) as amount_usd,
    max_by(zp.balance_usd / p.avg_eth_usd_price, zp.inserted_at) as amount_eth,
    max_by(cast(zp.updated_at as timestamp), zp.inserted_at) as updated_at,
    max(zp.inserted_at) as inserted_at
  from wallets.zapper_positions zp
    inner join mapping_unique_procols m on zp.app_id = m.zerion_id
    left join prices p on zp.updated_at::date = p.block_date
  group by 1, 2, 3, 4
)

select
  coalesce(zr.cover_id, zp.cover_id) as cover_id,
  coalesce(zr.address, zp.address) as address,
  coalesce(zr.chain, zp.chain) as chain,
  coalesce(zr.protocol, zp.protocol) as protocol,
  if(coalesce(zr.updated_at, to_timestamp(0)) >= coalesce(zp.updated_at, to_timestamp(0)), zr.amount_usd, zp.amount_usd) as amount_usd,
  if(coalesce(zr.updated_at, to_timestamp(0)) >= coalesce(zp.updated_at, to_timestamp(0)), zr.amount_eth, zp.amount_eth) as amount_eth,
  if(coalesce(zr.updated_at, to_timestamp(0)) >= coalesce(zp.updated_at, to_timestamp(0)), zr.updated_at, zp.updated_at) as updated_at,
  if(coalesce(zr.updated_at, to_timestamp(0)) >= coalesce(zp.updated_at, to_timestamp(0)), zr.inserted_at, zp.inserted_at) as inserted_at
from zerion_data_latest zr
  full outer join zapper_data_latest zp
    on zp.cover_id = zr.cover_id
    and zp.address = zr.address
    and zp.chain = zr.chain
    and zp.protocol = zr.protocol
order by 1, 2, 3, 4
