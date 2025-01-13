---
title: Wallet Monitoring
---

```plan_cover_list
select
  listing as plan,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed
from md_wallets.listing_totals
where is_plan
order by product_id
```

```plan_cover_stack
with agg_wallet_positions as (
  select
    product_id,
    plan,
    'Covered Amount' as total_type,
    usd_cover as usd_total,
    eth_cover as eth_total
  from md_wallets.listing_agg
  union all
  select
    product_id,
    listing as plan,
    'Exposed Funds' as total_type,
    usd_exposed as usd_total,
    eth_exposed as eth_total
  from md_wallets.listing_totals
  where is_plan
)
select
  plan,
  total_type,
  usd_total,
  eth_total
from agg_wallet_positions
order by product_id
```

## Exposed Funds vs Covered Amount per Cover Plan

<DataTable data={plan_cover_list} totalRow=true>
  <Column id=plan title="plan" totalAgg="grand total"/>
  <Column id=cnt_cover title="# covers" />
  <Column id=cnt_wallet title="# wallets" />
  <Column id=usd_cover title="cover ($)" fmt=num0/>
  <Column id=eth_cover title="cover (Ξ)" fmt=num0/>
  <Column id=usd_exposed title="funds exposed ($)" fmt=num0 contentType=colorscale colorScale=negative />
  <Column id=eth_exposed title="funds exposed (Ξ)" fmt=num0 contentType=colorscale colorScale=negative />
</DataTable>

<Tabs>
  <Tab label='USD'>
    <BarChart data={plan_cover_stack} title='Totals' x=plan y=usd_total yFmt=usd0k series=total_type swapXY=true type=grouped sort=false />
  </Tab>
  <Tab label='ETH'>
    <BarChart data={plan_cover_stack} title='Totals' x=plan y=eth_total yFmt=num0 series=total_type swapXY=true type=grouped sort=false />
  </Tab>
</Tabs>

## Exposed Funds vs Covered Amount per Cover Plan & Protocol

<ButtonGroup name=plan title="Select Plan">
    <ButtonGroupItem valueLabel="Entry Cover" value="Entry Cover" default />
    <ButtonGroupItem valueLabel="Essential Cover" value="Essential Cover" />
    <ButtonGroupItem valueLabel="Elite Cover" value="Elite Cover" />
</ButtonGroup>

```plan_cover_protocol_list
select
  pc.listing as plan,
  pw.protocol,
  pc.cnt_cover,
  pc.cnt_wallet,
  pc.usd_cover,
  pc.eth_cover,
  pw.usd_exposed,
  pw.eth_exposed
from md_wallets.listing_agg pc
  left join md_wallets.int_plan_protocol_wallet_agg pw on pc.product_id = pw.product_id
where pc.listing = '${inputs.plan}'
order by pc.product_id
```

```plan_cover_protocol_stack
with agg_wallet_positions as (
  /*select
    product_id,
    plan,
    plan as protocol,
    'Covered Amount' as total_type,
    usd_cover as usd_total,
    eth_cover as eth_total
  from md_wallets.listing_agg
  union all*/
  select
    product_id,
    plan,
    protocol,
    'Exposed Funds' as total_type,
    usd_exposed as usd_total,
    eth_exposed as eth_total
  from md_wallets.int_plan_protocol_wallet_agg
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

<DataTable data={plan_cover_protocol_list} totalRow=true search=true>
  <Column id=plan title="plan" totalAgg="grand total" />
  <Column id=protocol title="protocol"/>
  <Column id=usd_cover title="cover ($)" fmt='#,##0.00' totalAgg=mean />
  <Column id=eth_cover title="cover (Ξ)" fmt='#,##0.00' totalAgg=mean />
  <Column id=usd_exposed title="funds exposed ($)" fmt='#,##0.00' totalAgg=sum contentType=colorscale colorScale=negative />
  <Column id=eth_exposed title="funds exposed (Ξ)" fmt='#,##0.0000' totalAgg=sum contentType=colorscale colorScale=negative />
</DataTable>

<Tabs>
  <Tab label='USD'>
    <BarChart data={plan_cover_protocol_stack} title='Totals' x=total_type y=usd_total series=protocol swapXY=true yFmt=usd2 >
      <ReferenceLine data={plan_cover_protocol_list} y=usd_cover color=red label=covered lineColor=red lineWidth=3 labelPosition=aboveCenter />
    </BarChart>
  </Tab>
  <Tab label='ETH'>
    <BarChart data={plan_cover_protocol_stack} title='Totals' x=total_type y=eth_total series=protocol swapXY=true yFmt=num4 >
      <ReferenceLine data={plan_cover_protocol_list} y=eth_cover color=red label=covered lineColor=red lineWidth=3 labelPosition=aboveCenter />
    </BarChart>
  </Tab>
</Tabs>

<LastRefreshed prefix="Data last updated"/>
