---
title: Wallet Monitoring
---

<Dropdown name=data_level_choice title="unique exposed funds on wallets with multiple covers?" defaultValue="No">
  <DropdownOption value="No"/>
  <DropdownOption value="Yes"/>
</Dropdown>

## Exposed Funds vs Covered Amount per Cover Plan

```plan_cover_list
select
  listing,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed
from md_wallets.listing_totals_all
where is_plan
order by product_id
```

```plan_cover_list_unique
select
  listing,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed
from md_wallets.listing_totals_unique
where is_plan
order by product_id
```

<DataTable data={inputs.data_level_choice.value=="No" ? plan_cover_list : plan_cover_list_unique} totalRow=true>
  <Column id=listing title="listing" totalAgg="total"/>
  <Column id=cnt_cover title="# covers" />
  <Column id=cnt_wallet title="# wallets" />
  <Column id=usd_cover title="cover ($)" fmt=num0/>
  <Column id=eth_cover title="cover (Ξ)" fmt=num0/>
  <Column id=usd_exposed title="funds exposed ($)" fmt=num0 contentType=colorscale colorScale=negative />
  <Column id=eth_exposed title="funds exposed (Ξ)" fmt=num0 contentType=colorscale colorScale=negative />
</DataTable>

```plan_cover_stack
with agg_wallet_positions as (
  select
    product_id,
    listing,
    'Covered Amount' as total_type,
    usd_cover as usd_total,
    eth_cover as eth_total
  from md_wallets.listing_agg
  where is_plan
  union all
  select
    product_id,
    listing,
    'Exposed Funds' as total_type,
    usd_exposed as usd_total,
    eth_exposed as eth_total
  from md_wallets.listing_totals_all
  where is_plan
)
select
  listing,
  total_type,
  usd_total,
  eth_total
from agg_wallet_positions
order by product_id
```

```plan_cover_stack_unique
with agg_wallet_positions as (
  select
    product_id,
    listing,
    'Covered Amount' as total_type,
    usd_cover as usd_total,
    eth_cover as eth_total
  from md_wallets.listing_agg
  where is_plan
  union all
  select
    product_id,
    listing,
    'Exposed Funds' as total_type,
    usd_exposed as usd_total,
    eth_exposed as eth_total
  from md_wallets.listing_totals_unique
  where is_plan
)
select
  listing,
  total_type,
  usd_total,
  eth_total
from agg_wallet_positions
order by product_id
```

```plan_cover_daily
select
  load_dt,
  listing,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed,
  listing as label
from md_wallets.listing_totals_all_daily
where is_plan
order by load_dt, product_id
```

```plan_cover_daily_unique
select
  load_dt,
  listing,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed,
  listing as label
from md_wallets.listing_totals_unique_daily
where is_plan
order by load_dt, product_id
```

<Tabs fullWidth=true background=true>
  <Tab label='USD'>
    <BarChart
      data={inputs.data_level_choice.value=="No" ? plan_cover_stack : plan_cover_stack_unique}
      title="Cover Plan Totals ($)" x=listing y=usd_total yFmt=usd0k series=total_type swapXY=true type=grouped sort=false 
    />
    
    <AreaChart
      data={inputs.data_level_choice.value=="No" ? plan_cover_daily : plan_cover_daily_unique}
      x=load_dt y=usd_exposed yFmt=usd0k series=listing title="Exposed Funds ($) over time (per active cover)" 
    />
  </Tab>
  <Tab label='ETH'>
    <BarChart
      data={inputs.data_level_choice.value=="No" ? plan_cover_stack : plan_cover_stack_unique}
      title="Cover Plan Totals (Ξ)" x=listing y=eth_total yFmt=num0 series=total_type swapXY=true type=grouped sort=false 
    />
    
    <AreaChart
      data={inputs.data_level_choice.value=="No" ? plan_cover_daily : plan_cover_daily_unique}
      x=load_dt y=eth_exposed yFmt=num0 series=listing title="Exposed Funds (Ξ) over time (per active cover)" 
    />
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
  listing,
  protocol,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed
from md_wallets.listing_protocol_totals_all
where is_plan
  and listing = '${inputs.plan}'
order by product_id, protocol
```

```plan_cover_protocol_list_unique
select
  listing,
  protocol,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed
from md_wallets.listing_protocol_totals_unique
where is_plan
  and listing = '${inputs.plan}'
order by product_id, protocol
```

<DataTable
  data={inputs.data_level_choice.value=="No" ? plan_cover_protocol_list : plan_cover_protocol_list_unique}
  totalRow=true search=true
>
  <Column id=listing title="listing" totalAgg="total" />
  <Column id=protocol title="protocol"/>
  <Column id=usd_cover title="cover ($)" fmt='#,##0.00' totalAgg=mean />
  <Column id=eth_cover title="cover (Ξ)" fmt='#,##0.00' totalAgg=mean />
  <Column id=usd_exposed title="funds exposed ($)" fmt='#,##0.00' totalAgg=sum contentType=colorscale colorScale=negative />
  <Column id=eth_exposed title="funds exposed (Ξ)" fmt='#,##0.0000' totalAgg=sum contentType=colorscale colorScale=negative />
</DataTable>

```plan_cover_protocol_stack
select
  protocol,
  'Exposed Funds' as total_type,
  usd_exposed as usd_total,
  eth_exposed as eth_total
from md_wallets.listing_protocol_totals_all
where listing = '${inputs.plan}'
order by 1
```

```plan_cover_protocol_stack_unique
select
  protocol,
  'Exposed Funds' as total_type,
  usd_exposed as usd_total,
  eth_exposed as eth_total
from md_wallets.listing_protocol_totals_unique
where listing = '${inputs.plan}'
order by 1
```

```plan_cover_protocol_daily
select
  load_dt,
  listing,
  protocol,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed
from md_wallets.listing_protocol_totals_all_daily
where is_plan
  and listing = '${inputs.plan}'
order by load_dt, product_id, protocol
```

```plan_cover_protocol_daily_unique
select
  load_dt,
  listing,
  protocol,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed
from md_wallets.listing_protocol_totals_unique_daily
where is_plan
  and listing = '${inputs.plan}'
order by load_dt, product_id, protocol
```

<Tabs fullWidth=true background=true>
  <Tab label='USD'>
    <BarChart
      data={inputs.data_level_choice.value=="No" ? plan_cover_protocol_stack : plan_cover_protocol_stack_unique}
      title="Protocol Totals ($)" x=total_type y=usd_total series=protocol swapXY=true yFmt=usd2 
    >
      <ReferenceLine
        data={inputs.data_level_choice.value=="No" ? plan_cover_protocol_list : plan_cover_protocol_list_unique}
        y=usd_cover color=red label=covered lineColor=red lineWidth=3 labelPosition=aboveCenter 
      />
    </BarChart>

    <AreaChart
      data={inputs.data_level_choice.value=="No" ? plan_cover_protocol_daily : plan_cover_protocol_daily_unique}
      x=load_dt y=usd_exposed yFmt=usd0 series=protocol title="Exposed Funds ($) per Protocol over time (per active cover)" 
    />
  </Tab>
  
  <Tab label='ETH'>
    <BarChart
      data={inputs.data_level_choice.value=="No" ? plan_cover_protocol_stack : plan_cover_protocol_stack_unique}
      title="Protocol Totals (Ξ)" x=total_type y=eth_total series=protocol swapXY=true yFmt=num4 
    >
      <ReferenceLine
        data={inputs.data_level_choice.value=="No" ? plan_cover_protocol_list : plan_cover_protocol_list_unique}
        y=eth_cover color=red label=covered lineColor=red lineWidth=3 labelPosition=aboveCenter 
      />
    </BarChart>

    <AreaChart
      data={inputs.data_level_choice.value=="No" ? plan_cover_protocol_daily : plan_cover_protocol_daily_unique}
      x=load_dt y=usd_exposed yFmt=num2 series=protocol title="Exposed Funds (Ξ) per Protocol over time (per active cover)" 
    />
  </Tab>
</Tabs>

```listing_list
select
  listing,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed
from md_wallets.listing_totals_all
where is_plan = false
order by 1
```

```listing_list_unique
select
  listing,
  cnt_cover,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed
from md_wallets.listing_totals_unique
where is_plan = false
order by 1
```

```listing_stack
with agg_wallet_positions as (
  select
    product_id,
    listing,
    'Covered Amount' as total_type,
    usd_cover as usd_total,
    eth_cover as eth_total
  from md_wallets.listing_agg
  where is_plan = false
  union all
  select
    product_id,
    listing,
    'Exposed Funds' as total_type,
    usd_exposed as usd_total,
    eth_exposed as eth_total
  from md_wallets.listing_totals_all
  where is_plan = false
)
select
  listing,
  total_type,
  usd_total,
  eth_total
from agg_wallet_positions
where usd_total > 500000
order by usd_total desc
```

```listing_stack_unique
with agg_wallet_positions as (
  select
    product_id,
    listing,
    'Covered Amount' as total_type,
    usd_cover as usd_total,
    eth_cover as eth_total
  from md_wallets.listing_agg
  where is_plan = false
  union all
  select
    product_id,
    listing,
    'Exposed Funds' as total_type,
    usd_exposed as usd_total,
    eth_exposed as eth_total
  from md_wallets.listing_totals_unique
  where is_plan = false
)
select
  listing,
  total_type,
  usd_total,
  eth_total
from agg_wallet_positions
where usd_total > 500000
order by usd_total desc
```

## Exposed Funds vs Covered Amount per Listing

<DataTable data={inputs.data_level_choice.value=="No" ? listing_list : listing_list_unique} totalRow=true>
  <Column id=listing title="listing" totalAgg="total" wrap=true/>
  <Column id=cnt_cover title="# covers" />
  <Column id=usd_cover title="cover ($)" fmt=num0/>
  <Column id=eth_cover title="cover (Ξ)" fmt=num0/>
  <Column id=usd_exposed title="funds exposed ($)" fmt=num0 contentType=colorscale colorScale=negative />
  <Column id=eth_exposed title="funds exposed (Ξ)" fmt=num0 contentType=colorscale colorScale=negative />
</DataTable>

<Tabs fullWidth=true background=true>
  <Tab label='USD'>
    <BarChart
      data={inputs.data_level_choice.value=="No" ? listing_stack : listing_stack_unique}
      title='Totals above $0.5M' x=listing y=usd_total yFmt=usd0m yLog=true series=total_type swapXY=true type=grouped sort=false 
    />
  </Tab>
  <Tab label='ETH'>
    <BarChart
      data={inputs.data_level_choice.value=="No" ? listing_stack : listing_stack_unique}
      title='Totals above $0.5M' x=listing y=eth_total yFmt=num0 yLog=true series=total_type swapXY=true type=grouped sort=false 
    />
  </Tab>
</Tabs>

<LineBreak lines=1/>

<LastRefreshed prefix="Data last updated"/>
