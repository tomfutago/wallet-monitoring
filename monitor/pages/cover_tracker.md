---
title: Cover Tracker
---

```cover_dropdown
select cover_id from md_wallets.cover order by 1
```

<Dropdown data={cover_dropdown} name=cover_id value=cover_id title="Select Cover ID" />

```cover_list
select
  c.cover_id,
  c.plan,
  c.cnt_wallet,
  c.usd_cover,
  c.eth_cover,
  cw.usd_exposed,
  cw.eth_exposed,
  c.usd_cover / cw.usd_exposed as coverage_ratio,
  c.usd_cover * 0.05 as usd_deductible,
  c.eth_cover * 0.05 as eth_deductible
from md_wallets.cover_agg c
  left join md_wallets.int_cover_wallet_agg cw on c.cover_id = cw.cover_id
where c.cover_id = '${inputs.cover_id.value}'
```

## <Value data={cover_list} column=plan/> <Value data={cover_list} column=cover_id/> - Overview

<DataTable data={cover_list}>
  <Column id=cnt_wallet title="# wallets" />
  <Column id=usd_cover title="cover ($)" fmt=num2 />
  <Column id=eth_cover title="cover (Ξ)" fmt=num2 />
  <Column id=usd_exposed title="funds exposed ($)" fmt=num2 />
  <Column id=eth_exposed title="funds exposed (Ξ)" fmt=num2 />
  <Column id=coverage_ratio title="coverage (%)" fmt=pct2 />
  <Column id=usd_deductible title="deductible ($)" fmt=num2 />
  <Column id=eth_deductible title="deductible (Ξ)" fmt=num2 />
</DataTable>

```cover_wallets
select cover_id, cover_owner, wallet
from md_wallets.cover_wallets
where cover_id = '${inputs.cover_id.value}'
```

<Details title="Wallets">

### Cover owner:

<Value data={cover_wallets} column=cover_owner/>

### Designated wallet(s):

{#each cover_wallets as row}

  - <Value data={row} column=wallet/>

{/each}

</Details>

```cover_wallet_protocol_list
select
  c.cover_id,
  cw.wallet,
  cw.wallet_short,
  cw.protocol,
  c.usd_cover,
  c.eth_cover,
  cw.usd_exposed,
  cw.eth_exposed,
  cw.usd_exposed * c.usd_cover / cw_total.usd_exposed as usd_liability,
  cw.eth_exposed * c.eth_cover / cw_total.eth_exposed as eth_liability
from md_wallets.cover_agg c
  left join md_wallets.int_cover_protocol_wallet_agg cw on c.cover_id = cw.cover_id
  left join md_wallets.int_cover_wallet_agg cw_total on c.cover_id = cw_total.cover_id
where c.cover_id = '${inputs.cover_id.value}'
order by 2, 3
```

## Funds Exposed within <Value data={cover_list} column=plan/>

{#if cover_wallet_protocol_list[0].wallet == null}

None found.

{:else}

<DataTable data={cover_wallet_protocol_list} totalRow=true search=true>
  <Column id=cover_id title="cover id" totalAgg="grand total"/>
  <Column id=wallet_short title="wallet"/>
  <Column id=protocol title="protocol" />
  <Column id=usd_exposed title="funds exposed ($)" fmt=num2 totalAgg=sum />
  <Column id=eth_exposed title="funds exposed (Ξ)" fmt=num4 totalAgg=sum />
  <Column id=usd_liability title="liability ($)" fmt=num2 totalAgg=sum />
  <Column id=eth_liability title="liability (Ξ)" fmt=num2 totalAgg=sum />
</DataTable>

```sql cover_usd_exposed_by_protocol_treemap
select protocol as name, usd_exposed as value
from ${cover_wallet_protocol_list}
```

```sql cover_usd_exposed_by_chain_pie
select chain as name, usd_exposed as value
from md_wallets.int_cover_exposed_chain_agg
where cover_id = '${inputs.cover_id.value}'
```

```sql cover_eth_exposed_by_protocol_treemap
select protocol as name, eth_exposed as value
from ${cover_wallet_protocol_list}
```

```sql cover_eth_exposed_by_chain_pie
select chain as name, eth_exposed as value
from md_wallets.int_cover_exposed_chain_agg
where cover_id = '${inputs.cover_id.value}'
```

<Tabs>
  <Tab label='USD'>

    <Grid cols=2>

    <ECharts config={
      {
        title: {
          text: 'Protocol Exposure',
          left: 'center'
        },
        tooltip: {
          formatter: params => `${params.name}: ${Number(params.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
        },
        series: [
          {
            type: 'treemap',
            visibleMin: 300,
            label: {
              show: true,
              formatter: params => `${params.name}: ${Math.round(params.value / 1000).toLocaleString()}k`
            },
            itemStyle: {
              borderColor: '#fff'
            },
            roam: false,
            nodeClick: false,
            data: [...cover_usd_exposed_by_protocol_treemap],
            breadcrumb: {
              show: false
            }
          }
        ]
        }
      }
    />

    <ECharts config={
      {
        title: {
          text: 'Chain Exposure',
          left: 'center'
        },
        tooltip: {
          trigger: 'item',
          formatter: params => `${params.name}: ${Number(params.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
        },
        legend: {
          orient: 'vertical',
          left: 'right',
          top: 'top'
        },
        series: [
          {
            name: 'Access From',
            type: 'pie',
            radius: ['40%', '70%'],
            center: ['40%', '50%'],
            avoidLabelOverlap: false,
            itemStyle: {
              borderRadius: 10,
              borderColor: '#fff',
              borderWidth: 2
            },
            label: {
              show: false,
              position: 'center'
            },
            emphasis: {
              label: {
                show: true,
                fontSize: 30,
                fontWeight: 'bold',
                formatter: params => `${params.name}: ${params.percent}%`
              }
            },
            labelLine: {
              show: false
            },
            data: cover_usd_exposed_by_chain_pie.map(item => ({
              ...item,
              itemStyle: {
                color: ({
                  'Ethereum': '#00875F',
                  'OP': '#FF0420',
                  'Polygon': '#7047EB',
                  'Base': '#0052FF',
                  'Arbitrum': '#98C6E6'
                })[item.name] || null // default color for any other name
              }
            }))
          }
        ]
      }
    }/>

    </Grid>

  </Tab>
  <Tab label='ETH'>

    <Grid cols=2>

    <ECharts config={
      {
        title: {
          text: 'Protocol Exposure',
          left: 'center'
        },
        tooltip: {
          formatter: params => `${params.name}: ${Number(params.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
        },
        series: [
          {
            type: 'treemap',
            visibleMin: 300,
            label: {
              show: true,
              formatter: params => `${params.name}: ${Math.round(params.value).toLocaleString()}`
            },
            itemStyle: {
              borderColor: '#fff'
            },
            roam: false,
            nodeClick: false,
            data: [...cover_eth_exposed_by_protocol_treemap],
            breadcrumb: {
              show: false
            }
          }
        ]
        }
      }
    />

    <ECharts config={
      {
        title: {
          text: 'Chain Exposure',
          left: 'center'
        },
        tooltip: {
          trigger: 'item',
          formatter: params => `${params.name}: ${Math.round(params.value).toLocaleString()}`
        },
        legend: {
          orient: 'vertical',
          left: 'right',
          top: 'top'
        },
        series: [
          {
            name: 'Access From',
            type: 'pie',
            radius: ['40%', '70%'],
            center: ['40%', '50%'],
            avoidLabelOverlap: false,
            itemStyle: {
              borderRadius: 10,
              borderColor: '#fff',
              borderWidth: 2
            },
            label: {
              show: false,
              position: 'center'
            },
            emphasis: {
              label: {
                show: true,
                fontSize: 30,
                fontWeight: 'bold',
                formatter: params => `${params.name}: ${params.percent}%`
              }
            },
            labelLine: {
              show: false
            },
            data: cover_eth_exposed_by_chain_pie.map(item => ({
              ...item,
              itemStyle: {
                color: ({
                  'Ethereum': '#00875F',
                  'OP': '#FF0420',
                  'Polygon': '#7047EB',
                  'Base': '#0052FF',
                  'Arbitrum': '#98C6E6'
                })[item.name] || null // default color for any other name
              }
            }))
          }
        ]
      }
    }/>

    </Grid>

  </Tab>
</Tabs>

{/if}


```cover_wallet_protocol_diff_list
select
  c.cover_id,
  cw.wallet,
  cw.protocol,
  c.usd_cover,
  c.eth_cover,
  cw.usd_exposed,
  cw.eth_exposed
from md_wallets.cover_agg c
  left join md_wallets.int_cover_protocol_wallet_diff_agg cw on c.cover_id = cw.cover_id
where c.cover_id = '${inputs.cover_id.value}'
order by 2, 3
```

## Funds Exposed outside <Value data={cover_list} column=plan/>

{#if cover_wallet_protocol_diff_list[0].wallet == null}

None found.

{:else}

<DataTable data={cover_wallet_protocol_diff_list} totalRow=true search=true>
  <Column id=cover_id title="cover id" totalAgg="grand total"/>
  <Column id=wallet title="wallet"/>
  <Column id=protocol title="protocol" />
  <Column id=usd_exposed title="funds exposed ($)" fmt=num2 totalAgg=sum />
  <Column id=eth_exposed title="funds exposed (Ξ)" fmt=num4 totalAgg=sum />
</DataTable>

```sql cover_usd_exposed_by_protocol_diff_treemap
select protocol as name, usd_exposed as value
from ${cover_wallet_protocol_diff_list}
```

```sql cover_usd_exposed_by_chain_diff_pie
select chain as name, usd_exposed as value
from md_wallets.int_cover_exposed_chain_diff_agg
where cover_id = '${inputs.cover_id.value}'
```

```sql cover_eth_exposed_by_protocol_diff_treemap
select protocol as name, eth_exposed as value
from ${cover_wallet_protocol_diff_list}
```

```sql cover_eth_exposed_by_chain_diff_pie
select chain as name, eth_exposed as value
from md_wallets.int_cover_exposed_chain_diff_agg
where cover_id = '${inputs.cover_id.value}'
```

<Tabs>
  <Tab label='USD'>

    <Grid cols=2>

    <ECharts config={
      {
        title: {
          text: 'Protocol Exposure',
          left: 'center'
        },
        tooltip: {
          formatter: params => `${params.name}: ${Number(params.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
        },
        series: [
          {
            type: 'treemap',
            visibleMin: 300,
            label: {
              show: true,
              formatter: params => `${params.name}: ${Math.round(params.value / 1000).toLocaleString()}k`
            },
            itemStyle: {
              borderColor: '#fff'
            },
            roam: false,
            nodeClick: false,
            data: [...cover_usd_exposed_by_protocol_diff_treemap],
            breadcrumb: {
              show: false
            }
          }
        ]
        }
      }
    />

    <ECharts config={
      {
        title: {
          text: 'Chain Exposure',
          left: 'center'
        },
        tooltip: {
          trigger: 'item',
          formatter: params => `${params.name}: ${Number(params.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
        },
        legend: {
          orient: 'vertical',
          left: 'right',
          top: 'top'
        },
        series: [
          {
            name: 'Access From',
            type: 'pie',
            radius: ['40%', '70%'],
            center: ['40%', '50%'],
            avoidLabelOverlap: false,
            itemStyle: {
              borderRadius: 10,
              borderColor: '#fff',
              borderWidth: 2
            },
            label: {
              show: false,
              position: 'center'
            },
            emphasis: {
              label: {
                show: true,
                fontSize: 30,
                fontWeight: 'bold',
                formatter: params => `${params.name}: ${params.percent}%`
              }
            },
            labelLine: {
              show: false
            },
            data: cover_usd_exposed_by_chain_diff_pie.map(item => ({
              ...item,
              itemStyle: {
                color: ({
                  'Ethereum': '#00875F',
                  'OP': '#FF0420',
                  'Polygon': '#7047EB',
                  'Base': '#0052FF',
                  'Arbitrum': '#98C6E6'
                })[item.name] || null // default color for any other name
              }
            }))
          }
        ]
      }
    }/>

    </Grid>

  </Tab>
  <Tab label='ETH'>

    <Grid cols=2>

    <ECharts config={
      {
        title: {
          text: 'Protocol Exposure',
          left: 'center'
        },
        tooltip: {
          formatter: params => `${params.name}: ${Number(params.value).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
        },
        series: [
          {
            type: 'treemap',
            visibleMin: 300,
            label: {
              show: true,
              formatter: params => `${params.name}: ${Math.round(params.value).toLocaleString()}`
            },
            itemStyle: {
              borderColor: '#fff'
            },
            roam: false,
            nodeClick: false,
            data: [...cover_eth_exposed_by_protocol_diff_treemap],
            breadcrumb: {
              show: false
            }
          }
        ]
        }
      }
    />

    <ECharts config={
      {
        title: {
          text: 'Chain Exposure',
          left: 'center'
        },
        tooltip: {
          trigger: 'item',
          formatter: params => `${params.name}: ${Math.round(params.value).toLocaleString()}`
        },
        legend: {
          orient: 'vertical',
          left: 'right',
          top: 'top'
        },
        series: [
          {
            name: 'Access From',
            type: 'pie',
            radius: ['40%', '70%'],
            center: ['40%', '50%'],
            avoidLabelOverlap: false,
            itemStyle: {
              borderRadius: 10,
              borderColor: '#fff',
              borderWidth: 2
            },
            label: {
              show: false,
              position: 'center'
            },
            emphasis: {
              label: {
                show: true,
                fontSize: 30,
                fontWeight: 'bold',
                formatter: params => `${params.name}: ${params.percent}%`
              }
            },
            labelLine: {
              show: false
            },
            data: cover_eth_exposed_by_chain_diff_pie.map(item => ({
              ...item,
              itemStyle: {
                color: ({
                  'Ethereum': '#00875F',
                  'OP': '#FF0420',
                  'Polygon': '#7047EB',
                  'Base': '#0052FF',
                  'Arbitrum': '#98C6E6'
                })[item.name] || null // default color for any other name
              }
            }))
          }
        ]
      }
    }/>

    </Grid>

  </Tab>
</Tabs>

{/if}
