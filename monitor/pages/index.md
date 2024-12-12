---
title: Wallet Monitoring
---

```plan_list
with

wallet_cover as (
  select
    plan_id,
    plan,
    count(distinct cover_id) as cnt_cover,
    sum(usd_cover_amount) as usd_cover,
    sum(eth_cover_amount) as eth_cover
  from (
    select distinct
      plan_id, plan, cover_id, usd_cover_amount, eth_cover_amount
    from wallets.src_cover_wallets
  ) cw
  group by 1, 2
),

agg_wallet_positions as (
  select
    c.plan_id,
    c.plan,
    c.cnt_cover,
    count(distinct w.monitored_wallet) as cnt_wallet,
    c.usd_cover,
    c.eth_cover,
    sum(w.amount_usd) as usd_exposed,
    sum(w.amount_eth) as eth_exposed
  from wallet_cover c
    inner join wallets.wallet_positions w on c.plan_id = w.plan_id
  group by 1, 2, 3, 5, 6
)

select
  plan,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed
from agg_wallet_positions
order by plan_id
```

```plan_stack
with

wallet_cover as (
  select
    plan_id,
    plan,
    count(distinct cover_id) as cnt_cover,
    sum(usd_cover_amount) as usd_cover,
    sum(eth_cover_amount) as eth_cover
  from (
    select distinct
      plan_id, plan, cover_id, usd_cover_amount, eth_cover_amount
    from wallets.src_cover_wallets
  ) cw
  group by 1, 2
),

agg_wallet_positions as (
  select
    plan_id,
    plan,
    'Covered Amount' as total_type,
    usd_cover as usd_total,
    eth_cover as eth_total
  from wallet_cover
  union all
  select
    plan_id,
    plan,
    'Exposed Funds' as total_type,
    sum(amount_usd) as usd_total,
    sum(amount_eth) as eth_total
  from wallets.wallet_positions
  group by 1, 2
)

select
  plan,
  total_type,
  usd_total,
  eth_total
from agg_wallet_positions
order by plan_id
```

```plan_protocol_list
with

wallet_cover as (
  select
    plan_id,
    plan,
    count(distinct cover_id) as cnt_cover,
    sum(usd_cover_amount) as usd_cover,
    sum(eth_cover_amount) as eth_cover
  from (
    select distinct
      plan_id, plan, cover_id, usd_cover_amount, eth_cover_amount
    from wallets.src_cover_wallets
  ) cw
  group by 1, 2
),

agg_wallet_positions as (
  select
    c.plan_id,
    c.plan,
    w.protocol,
    c.cnt_cover,
    count(distinct w.monitored_wallet) as cnt_wallet,
    c.usd_cover,
    c.eth_cover,
    sum(w.amount_usd) as usd_exposed,
    sum(w.amount_eth) as eth_exposed
  from wallet_cover c
    inner join wallets.wallet_positions w on c.plan_id = w.plan_id
  group by 1, 2, 3, 4, 6, 7
)

select
  plan,
  protocol,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed
from agg_wallet_positions
order by plan_id, protocol
```

## Exposed Funds vs Covered Amount per Cover Plan

<DataTable data={plan_list}>
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
      data={plan_stack}
      title='Totals'
      x=plan
      y=usd_total
      series=total_type
      swapXY=true
      type=grouped
      sort=false
    />
    <BarChart 
      data={plan_stack}
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
      data={plan_stack}
      title='Totals'
      x=plan
      y=eth_total
      series=total_type
      swapXY=true
      type=grouped
      sort=false
    />
    <BarChart 
      data={plan_stack}
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

<DataTable data={plan_protocol_list}>
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

```protocol_stack
with

wallet_cover as (
  select
    plan_id,
    plan,
    count(distinct cover_id) as cnt_cover,
    sum(usd_cover_amount) as usd_cover,
    sum(eth_cover_amount) as eth_cover
  from (
    select distinct
      plan_id, plan, cover_id, usd_cover_amount, eth_cover_amount
    from wallets.src_cover_wallets
  ) cw
  group by 1, 2
),

agg_wallet_positions as (
  select
    c.plan,
    w.protocol,
    'Covered Amount' as total_type,
    usd_cover as usd_total,
    eth_cover as eth_total
  from wallet_cover c
    inner join wallets.wallet_positions w on c.plan_id = w.plan_id
  union all
  select
    plan,
    protocol,
    'Exposed Funds' as total_type,
    sum(amount_usd) as usd_total,
    sum(amount_eth) as eth_total
  from wallets.wallet_positions
  group by 1, 2
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
      x=protocol
      y=usd_total
      series=total_type
      swapXY=true
      type=grouped
    />
    <BarChart 
      data={protocol_stack}
      title='% Share'
      x=protocol
      y=usd_total
      series=total_type
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

<LastRefreshed prefix="Data last updated"/>
