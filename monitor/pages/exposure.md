---
title: Exposure
---

## Overview

```sql exposure_overview
select name, usd_value, eth_value from md_wallets.exposure_overview order by id
```

```sql exposure_overview_split_usd
select listing as name, sum(usd_exposed) as value
from md_wallets.listing_totals_all
where is_plan
group by 1
```

```sql exposure_overview_split_eth
select listing as name, sum(eth_exposed) as value
from md_wallets.listing_totals_all
where is_plan
group by 1
```

```sql exposure_elite
select name, usd_value, eth_value from md_wallets.exposure_elite order by id
```

```sql exposure_elite_ratio_usd
select
  case when coverage_cover_ratio > 1 then 'Coverage Ratio 1>' else 'Coverage Ratio 1<' end as name,
  sum(usd_protocol_exposed) as value
from md_wallets.cover_wallet_protocol_totals
where listing = 'Elite Cover'
group by 1
```

```sql exposure_elite_ratio_eth
select
  case when coverage_cover_ratio > 1 then 'Coverage Ratio 1>' else 'Coverage Ratio 1<' end as name,
  sum(eth_protocol_exposed) as value
from md_wallets.cover_wallet_protocol_totals
where listing = 'Elite Cover'
group by 1
```

```sql exposure_essential
select name, usd_value, eth_value from md_wallets.exposure_essential order by id
```

```sql exposure_essential_ratio_usd
select
  case when coverage_cover_ratio > 1 then 'Coverage Ratio 1>' else 'Coverage Ratio 1<' end as name,
  sum(usd_protocol_exposed) as value
from md_wallets.cover_wallet_protocol_totals
where listing = 'Essential Cover'
group by 1
```

```sql exposure_essential_ratio_eth
select
  case when coverage_cover_ratio > 1 then 'Coverage Ratio 1>' else 'Coverage Ratio 1<' end as name,
  sum(eth_protocol_exposed) as value
from md_wallets.cover_wallet_protocol_totals
where listing = 'Essential Cover'
group by 1
```

```sql exposure_entry
select name, usd_value, eth_value from md_wallets.exposure_entry order by id
```

```sql exposure_entry_ratio_usd
select
  case when coverage_cover_ratio > 1 then 'Coverage Ratio 1>' else 'Coverage Ratio 1<' end as name,
  sum(usd_protocol_exposed) as value
from md_wallets.cover_wallet_protocol_totals
where listing = 'Entry Cover'
group by 1
```

```sql exposure_entry_ratio_eth
select
  case when coverage_cover_ratio > 1 then 'Coverage Ratio 1>' else 'Coverage Ratio 1<' end as name,
  sum(eth_protocol_exposed) as value
from md_wallets.cover_wallet_protocol_totals
where listing = 'Entry Cover'
group by 1
```

<Tabs fullWidth=true background=true>
  <Tab label='USD'>

    <Grid cols=2 gapSize=lg>

      <DataTable data={exposure_overview}>
        <Column id=name title=" "/>
        <Column id=usd_value title=" " align=right/>
      </DataTable>

      <ECharts config={
        {
          tooltip: {
            trigger: 'item',
            formatter: params => `${params.name}: ${Number(params.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
          },
          legend: {
            orient: 'vertical',
            left: 'right',
            top: 'top',
            align: 'right',
            itemGap: 5,
            padding: [20, 10, 0, 0],
            width: 'auto',
            right: 0
          },
          series: [
            {
              type: 'pie',
              radius: ['0%', '50%'],
              center: ['40%', '40%'],
              avoidLabelOverlap: false,
              itemStyle: {
                borderRadius: 10,
                borderColor: '#fff',
                borderWidth: 2
              },
              label: {
                show: true,
                position: 'inside',
                formatter: params => params.percent < 15 ? '' : `${params.percent}%`
              },
              data: [...exposure_overview_split_usd]
            }
          ]
        }
      }/>

      <DataTable data={exposure_elite}>
        <Column id=name title=" "/>
        <Column id=usd_value title=" " align=right/>
      </DataTable>

      <ECharts config={
        {
          tooltip: {
            trigger: 'item',
            formatter: params => `${params.name}: ${Number(params.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
          },
          legend: {
            orient: 'vertical',
            left: 'right',
            top: 'top',
            align: 'right',
            itemGap: 5,
            padding: [20, 10, 0, 0],
            width: 'auto',
            right: 0
          },
          series: [
            {
              type: 'pie',
              radius: ['0%', '50%'],
              center: ['40%', '40%'],
              avoidLabelOverlap: false,
              itemStyle: {
                borderRadius: 10,
                borderColor: '#fff',
                borderWidth: 2
              },
              label: {
                show: true,
                position: 'inside',
                formatter: params => params.percent < 15 ? '' : `${params.percent}%`
              },
              data: [...exposure_elite_ratio_usd]
            }
          ]
        }
      }/>

      <DataTable data={exposure_essential}>
        <Column id=name title=" "/>
        <Column id=usd_value title=" " align=right/>
      </DataTable>

      <ECharts config={
        {
          tooltip: {
            trigger: 'item',
            formatter: params => `${params.name}: ${Number(params.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
          },
          legend: {
            orient: 'vertical',
            left: 'right',
            top: 'top',
            align: 'right',
            itemGap: 5,
            padding: [20, 10, 0, 0],
            width: 'auto',
            right: 0
          },
          series: [
            {
              type: 'pie',
              radius: ['0%', '50%'],
              center: ['40%', '40%'],
              avoidLabelOverlap: false,
              itemStyle: {
                borderRadius: 10,
                borderColor: '#fff',
                borderWidth: 2
              },
              label: {
                show: true,
                position: 'inside',
                formatter: params => params.percent < 15 ? '' : `${params.percent}%`
              },
              data: [...exposure_essential_ratio_usd]
            }
          ]
        }
      }/>

      <DataTable data={exposure_entry}>
        <Column id=name title=" "/>
        <Column id=usd_value title=" " align=right/>
      </DataTable>

      <ECharts config={
        {
          tooltip: {
            trigger: 'item',
            formatter: params => `${params.name}: ${Number(params.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
          },
          legend: {
            orient: 'vertical',
            left: 'right',
            top: 'top',
            align: 'right',
            itemGap: 5,
            padding: [20, 10, 0, 0],
            width: 'auto',
            right: 0
          },
          series: [
            {
              type: 'pie',
              radius: ['0%', '50%'],
              center: ['40%', '40%'],
              avoidLabelOverlap: false,
              itemStyle: {
                borderRadius: 10,
                borderColor: '#fff',
                borderWidth: 2
              },
              label: {
                show: true,
                position: 'inside',
                formatter: params => params.percent < 15 ? '' : `${params.percent}%`
              },
              data: [...exposure_entry_ratio_usd]
            }
          ]
        }
      }/>

    </Grid>

  </Tab>
  <Tab label='ETH'>

    <Grid cols=2 gapSize=lg>

      <DataTable data={exposure_overview}>
        <Column id=name title=" "/>
        <Column id=eth_value title=" " align=right/>
      </DataTable>

      <ECharts config={
        {
          tooltip: {
            trigger: 'item',
            formatter: params => `${params.name}: ${Number(params.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
          },
          legend: {
            orient: 'vertical',
            left: 'right',
            top: 'top',
            align: 'right',
            itemGap: 5,
            padding: [20, 10, 0, 0],
            width: 'auto',
            right: 0
          },
          series: [
            {
              type: 'pie',
              radius: ['0%', '50%'],
              center: ['40%', '40%'],
              avoidLabelOverlap: false,
              itemStyle: {
                borderRadius: 10,
                borderColor: '#fff',
                borderWidth: 2
              },
              label: {
                show: true,
                position: 'inside',
                formatter: params => params.percent < 15 ? '' : `${params.percent}%`
              },
              data: [...exposure_overview_split_eth]
            }
          ]
        }
      }/>

      <DataTable data={exposure_elite}>
        <Column id=name title=" "/>
        <Column id=eth_value title=" " align=right/>
      </DataTable>

      <ECharts config={
        {
          tooltip: {
            trigger: 'item',
            formatter: params => `${params.name}: ${Number(params.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
          },
          legend: {
            orient: 'vertical',
            left: 'right',
            top: 'top',
            align: 'right',
            itemGap: 5,
            padding: [20, 10, 0, 0],
            width: 'auto',
            right: 0
          },
          series: [
            {
              type: 'pie',
              radius: ['0%', '50%'],
              center: ['40%', '40%'],
              avoidLabelOverlap: false,
              itemStyle: {
                borderRadius: 10,
                borderColor: '#fff',
                borderWidth: 2
              },
              label: {
                show: true,
                position: 'inside',
                formatter: params => params.percent < 15 ? '' : `${params.percent}%`
              },
              data: [...exposure_elite_ratio_eth]
            }
          ]
        }
      }/>

      <DataTable data={exposure_essential}>
        <Column id=name title=" "/>
        <Column id=eth_value title=" " align=right/>
      </DataTable>

      <ECharts config={
        {
          tooltip: {
            trigger: 'item',
            formatter: params => `${params.name}: ${Number(params.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
          },
          legend: {
            orient: 'vertical',
            left: 'right',
            top: 'top',
            align: 'right',
            itemGap: 5,
            padding: [20, 10, 0, 0],
            width: 'auto',
            right: 0
          },
          series: [
            {
              type: 'pie',
              radius: ['0%', '50%'],
              center: ['40%', '40%'],
              avoidLabelOverlap: false,
              itemStyle: {
                borderRadius: 10,
                borderColor: '#fff',
                borderWidth: 2
              },
              label: {
                show: true,
                position: 'inside',
                formatter: params => params.percent < 15 ? '' : `${params.percent}%`
              },
              data: [...exposure_essential_ratio_eth]
            }
          ]
        }
      }/>

      <DataTable data={exposure_entry}>
        <Column id=name title=" "/>
        <Column id=eth_value title=" " align=right/>
      </DataTable>

      <ECharts config={
        {
          tooltip: {
            trigger: 'item',
            formatter: params => `${params.name}: ${Number(params.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
          },
          legend: {
            orient: 'vertical',
            left: 'right',
            top: 'top',
            align: 'right',
            itemGap: 5,
            padding: [20, 10, 0, 0],
            width: 'auto',
            right: 0
          },
          series: [
            {
              type: 'pie',
              radius: ['0%', '50%'],
              center: ['40%', '40%'],
              avoidLabelOverlap: false,
              itemStyle: {
                borderRadius: 10,
                borderColor: '#fff',
                borderWidth: 2
              },
              label: {
                show: true,
                position: 'inside',
                formatter: params => params.percent < 15 ? '' : `${params.percent}%`
              },
              data: [...exposure_entry_ratio_eth]
            }
          ]
        }
      }/>

    </Grid>

  </Tab>
</Tabs>

<LineBreak lines=1/>

## NM Cover Exposure

```cover_list
select
  product_id,
  listing,
  cover_id,
  cnt_wallet,
  usd_cover,
  eth_cover,
  usd_exposed,
  eth_exposed,
  coverage_ratio,
  usd_deductible,
  eth_deductible,
  cover_start_date,
  cover_end_date
from md_wallets.cover_totals
where is_plan
order by product_id, cover_id
```

<Details title='Notes'>
Grand total on "Cover ($)" is lower here than "Cover Amount" in the Overview section above, because table below only contains data for wallets with deployed funds. In other words, if a cover has a single wallet and no funds deployed in any DeFi position from this wallet, cover amount on this cover will not be included in the grand total here.
</Details>

<DataTable data={cover_list} totalRow=true search=true >
  <Column id=listing title="listing" totalAgg="total" />
  <Column id=cover_id title="cover id"  totalAgg="-"/>
  <Column id=cnt_wallet title="# wallets" />
  <Column id=usd_cover title="cover ($)" fmt=num2 />
  <Column id=eth_cover title="cover (Ξ)" fmt=num2 />
  <Column id=usd_exposed title="funds exposed ($)" fmt=num2 />
  <Column id=eth_exposed title="funds exposed (Ξ)" fmt=num2 />
  <Column id=coverage_ratio title="coverage (%)" fmt=pct2 totalAgg="-" />
  <Column id=usd_deductible title="deductible ($)" fmt=num2 />
  <Column id=eth_deductible title="deductible (Ξ)" fmt=num2 />
  <Column id=cover_start_date title="start date" fmt='yyyy-mm-dd' />
  <Column id=cover_end_date title="end date" fmt='yyyy-mm-dd' />
</DataTable>

<LineBreak lines=1/>

## Individual Exposure

```sql individual_exposure 
select
  product_id,
  listing,
  cover_id,
  usd_cover,
  eth_cover,
  usd_deductible,
  eth_deductible,
  usd_cover_exposed,
  eth_cover_exposed,
  coverage_cover_ratio,
  wallet,
  wallet_short,
  protocol,
  usd_protocol_exposed,
  eth_protocol_exposed,
  coverage_protocol_ratio,
  usd_liability,
  eth_liability,
  cover_start_date,
  cover_end_date
from md_wallets.cover_wallet_protocol_totals
where is_plan
order by product_id, cover_id
```

<DataTable data={individual_exposure} totalRow=true search=true >
  <Column id=listing title=listing totalAgg="total"/>
  <Column id=cover_id title=cover_id totalAgg="-"/>
  <Column id=wallet_short title=wallet/>
  <Column id=protocol title=protocol/>
  <Column id=usd_protocol_exposed title="funds exposed ($)" fmt=num2 />
  <Column id=eth_protocol_exposed title="funds exposed (Ξ)" fmt=num2 />
  <Column id=usd_liability title="liability ($)" fmt=num2 totalAgg=sum />
  <Column id=eth_liability title="liability (Ξ)" fmt=num2 totalAgg=sum />
  <Column id=coverage_protocol_ratio title="coverage (%)" fmt=pct2 totalAgg="-" />
</DataTable>

<LineBreak lines=1/>

<LastRefreshed prefix="Data last updated"/>
