with

prices as (
  select
    block_date,
    avg_eth_usd_price
  from wallets.capital_pool
),

zerion_data as (
  select
    cover_id,
    chain_id as chain,
    address,
    protocol,
    value as amount_usd,
    value / avg_eth_usd_price as amount_eth,
    updated_at,
    inserted_at
  from wallets.zerion_positions zp
    left join prices p on zp.updated_at::date = p.block_date
  where position_type <> 'wallet'
),

zapper_data as (
  select
    cover_id,
    network as chain,
    address,
    app_name as protocol,
    balance_usd as amount_usd,
    balance_usd / avg_eth_usd_price as amount_eth,
    updated_at,
    inserted_at
  from wallets.zapper_positions zp
    left join prices p on zp.updated_at::date = p.block_date
),

wallets_combined as (
  select
    c.cover_id,
    c.plan,
    c.cover_start_date,
    c.cover_end_date,
    c.cover_asset,
    c.sum_assured,
    c.cover_owner,
    zr.address,
    zr.chain,
    zr.protocol,
    zr.amount_usd,
    zr.amount_eth,
    zr.updated_at,
    zr.inserted_at
  from wallets.cover_wallets c
    left join zerion_data zr on c.cover_id = zr.cover_id and c.monitored_wallet = zr.address
    -- for this to work - need to add protocol mapping table 
    --left join zapper_data zp on c.cover_id = zp.cover_id and c.monitored_wallet = zp.address and zr.protocol = zp.protocol
)

select
  *
from wallets_combined
