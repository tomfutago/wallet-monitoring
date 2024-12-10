---
title: Wallet Monitoring
queries:
  - wallet_positions: wallet_positions.sql
---

```plan_list
with agg_wallet_positions as (
  select
    plan_id,
    plan,
    count(distinct cover_id) as cnt_cover,
    count(distinct monitored_wallet) as cnt_wallet,
    sum(usd_cover_amount) as usd_cover,
    sum(eth_cover_amount) as eth_cover,
    sum(amount_usd) as usd_exposed,
    sum(amount_eth) as eth_exposed
  from ${wallet_positions}
  group by 1, 2
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
with agg_wallet_positions as (
  select
    plan_id,
    plan,
    'Covered Amount' as total_type,
    sum(usd_cover_amount) as usd_total,
    sum(eth_cover_amount) as eth_total
  from ${wallet_positions}
  group by 1, 2
  union all
  select
    plan_id,
    plan,
    'Exposed Funds' as total_type,
    sum(amount_usd) as usd_total,
    sum(amount_eth) as eth_total
  from ${wallet_positions}
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

## Exposed Funds vs Covered Amount per Cover Plan

<Tabs>
  <Tab label='USD'>
    <BarChart 
      data={plan_stack}
      title='Totals'
      x=plan
      y=usd_total
      series=total_type
      swapXY=true
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
    />
  </Tab>
</Tabs>
