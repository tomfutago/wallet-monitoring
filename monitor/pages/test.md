## test

```test
with

mapping_full as (
  select plan, protocol, zapper_id, zapper_name, zerion_id, zerion_name
  from wallets.src_plan_mapping
),

mapping_unique_procols as (
  select distinct protocol, zapper_id, zapper_name, zerion_id, zerion_name
  from wallets.src_plan_mapping
),

prices as (
  select
    block_date,
    avg_eth_usd_price
  from wallets.src_capital_pool
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
  from wallets.src_zerion_data zp
    inner join mapping_unique_procols m on zp.app_id = m.zerion_id
    left join prices p on zp.updated_at::date = p.block_date::date
  where zp.position_type <> 'wallet'
  group by 1, 2, 3, 4
)

select * from zerion_data_latest
```

```plan_list
select
  pc.plan,
  pc.cnt_cover,
  pc.cnt_wallet,
  pc.usd_cover,
  pc.eth_cover,
  pw.usd_exposed,
  pw.eth_exposed
from wallets.int_plan_cover_agg pc
  left join wallets.int_plan_wallet_agg pw on pc.plan_id = pw.plan_id
order by pc.plan_id
```

```plan_protocol_list
select
  pc.plan,
  pw.protocol,
  pc.cnt_cover,
  pc.cnt_wallet,
  pc.usd_cover,
  pc.eth_cover,
  pw.usd_exposed,
  pw.eth_exposed
from wallets.int_plan_cover_agg pc
  left join wallets.int_plan_protocol_wallet_agg pw on pc.plan_id = pw.plan_id
order by pc.plan_id
```

```plan_stack
with agg_wallet_positions as (
  select
    plan_id,
    plan,
    'Covered Amount' as total_type,
    usd_cover as usd_total,
    eth_cover as eth_total
  from wallets.int_plan_cover_agg
  union all
  select
    plan_id,
    plan,
    'Exposed Funds' as total_type,
    usd_exposed as usd_total,
    eth_exposed as eth_total
  from wallets.int_plan_wallet_agg
)
select
  plan,
  total_type,
  usd_total,
  eth_total
from agg_wallet_positions
order by plan_id
```

<ButtonGroup name=plan title="Select Plan">
    <ButtonGroupItem valueLabel="Entry Cover" value="Entry Cover" />
    <ButtonGroupItem valueLabel="Essential Cover" value="Essential Cover" />
    <ButtonGroupItem valueLabel="Elite Cover" value="Elite Cover" default />
</ButtonGroup>

```protocol_stack
with agg_wallet_positions as (
  select
    plan_id,
    plan,
    plan as protocol,
    'Covered Amount' as total_type,
    usd_cover as usd_total,
    eth_cover as eth_total
  from wallets.int_plan_cover_agg
  union all
  select
    plan_id,
    plan,
    protocol,
    'Exposed Funds' as total_type,
    usd_exposed as usd_total,
    eth_exposed as eth_total
  from wallets.int_plan_protocol_wallet_agg
)
select
  protocol,
  total_type,
  usd_total,
  eth_total
from agg_wallet_positions
where plan = '${inputs.plan}'
order by 1
```

<Tabs>
  <Tab label='USD'>
    <BarChart 
      data={protocol_stack}
      title='Totals'
      x=total_type
      y=usd_total
      series=protocol
      swapXY=true
    />
    <BarChart 
      data={protocol_stack}
      title='% Share'
      x=total_type
      y=usd_total
      series=protocol
      type=stacked100
      swapXY=true
    />
  </Tab>
  <Tab label='ETH'>
    <BarChart 
      data={protocol_stack}
      title='Totals'
      x=protocol
      y=eth_total
      series=total_type
      swapXY=true
      type=grouped
    />
    <BarChart 
      data={protocol_stack}
      title="% Share"
      x=protocol
      y=eth_total
      series=total_type
      type=stacked100
      labels=true
      swapXY=true
    />
  </Tab>
</Tabs>
