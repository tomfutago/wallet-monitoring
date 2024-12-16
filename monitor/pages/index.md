---
title: Wallet Monitoring
---

```plan_cover_list
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

```plan_cover_stack
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

```plan_cover_protocol_list
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

## Exposed Funds vs Covered Amount per Cover Plan

<DataTable data={plan_cover_list}>
  <Column id=plan title="plan"/>
  <Column id=cnt_cover title="# covers" />
  <Column id=cnt_wallet title="# wallets" />
  <Column id=usd_cover title="cover ($)" />
  <Column id=eth_cover title="cover (Ξ)" />
  <Column id=usd_exposed title="funds exposed ($)" />
  <Column id=eth_exposed title="funds exposed (Ξ)" />
</DataTable>

<Tabs>
  <Tab label='USD'>
    <BarChart 
      data={plan_cover_stack}
      title='Totals'
      x=plan
      y=usd_total
      series=total_type
      swapXY=true
      type=grouped
      sort=false
    />
    <BarChart 
      data={plan_cover_stack}
      title='% Share'
      x=plan
      y=usd_total
      series=total_type
      type=stacked100
      labels=true
      swapXY=true
      sort=false
    />
  </Tab>
  <Tab label='ETH'>
    <BarChart 
      data={plan_cover_stack}
      title='Totals'
      x=plan
      y=eth_total
      series=total_type
      swapXY=true
      type=grouped
      sort=false
    />
    <BarChart 
      data={plan_cover_stack}
      title="% Share"
      x=plan
      y=eth_total
      series=total_type
      type=stacked100
      labels=true
      swapXY=true
      sort=false
    />
  </Tab>
</Tabs>

## Exposed Funds vs Covered Amount per Cover Plan & Protocol

<DataTable data={plan_cover_protocol_list}>
  <Column id=plan title="plan" />
  <Column id=protocol title="protocol"/>
  <Column id=cnt_cover title="# covers" />
  <Column id=cnt_wallet title="# wallets" />
  <Column id=usd_cover title="cover ($)" />
  <Column id=eth_cover title="cover (Ξ)" />
  <Column id=usd_exposed title="funds exposed ($)" />
  <Column id=eth_exposed title="funds exposed (Ξ)" />
</DataTable>

<ButtonGroup name=plan title="Select Plan">
    <ButtonGroupItem valueLabel="Entry Cover" value="Entry Cover" />
    <ButtonGroupItem valueLabel="Essential Cover" value="Essential Cover" />
    <ButtonGroupItem valueLabel="Elite Cover" value="Elite Cover" default />
</ButtonGroup>

```plan_cover_protocol_stack
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
      data={plan_cover_protocol_stack}
      title='Totals'
      x=total_type
      y=usd_total
      series=protocol
      swapXY=true
    />
  </Tab>
  <Tab label='ETH'>
    <BarChart 
      data={plan_cover_protocol_stack}
      title='Totals'
      x=total_type
      y=eth_total
      series=protocol
      swapXY=true
    />
  </Tab>
</Tabs>

<LastRefreshed prefix="Data last updated"/>
