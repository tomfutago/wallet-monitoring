---
title: Individual Cover Tracker
---

```duped_wallets
select * from md_wallets.int_duped_wallets order by 1
```

## Wallets with Multiple Covers
<DataTable data={duped_wallets} totalRow=true>
  <Column id=wallet title=wallet totalAgg="grand total"/>
  <Column id=plans title=plans/>
  <Column id=covers title=covers/>
  <Column id=count title="# wallets" totalAgg=sum />
</DataTable>

```cover_dropdown
select cover_id from md_wallets.src_cover order by 1
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
  cw.eth_exposed
from md_wallets.int_cover_agg c
  left join md_wallets.int_cover_wallet_agg cw on c.cover_id = cw.cover_id
where c.cover_id = '${inputs.cover_id.value}'
```

```cover_wallet_protocol_list
select
  c.cover_id,
  cw.wallet,
  cw.protocol,
  c.usd_cover,
  c.eth_cover,
  cw.usd_exposed,
  cw.eth_exposed
from md_wallets.int_cover_agg c
  left join md_wallets.int_cover_protocol_wallet_agg cw on c.cover_id = cw.cover_id
where c.cover_id = '${inputs.cover_id.value}'
order by 2, 3
```

```cover_wallet_protocol_diff_list
select
  c.cover_id,
  cw.wallet,
  cw.protocol,
  c.usd_cover,
  c.eth_cover,
  cw.usd_exposed,
  cw.eth_exposed
from md_wallets.int_cover_agg c
  left join md_wallets.int_cover_protocol_wallet_diff_agg cw on c.cover_id = cw.cover_id
where c.cover_id = '${inputs.cover_id.value}'
order by 2, 3
```

## Cover Overview
<DataTable data={cover_list}>
  <Column id=cover_id title="cover id"/>
  <Column id=plan title="plan"/>
  <Column id=cnt_wallet title="# wallets" />
  <Column id=usd_cover title="cover ($)" fmt=num2 />
  <Column id=eth_cover title="cover (Ξ)" fmt=num2 />
  <Column id=usd_exposed title="funds exposed ($)" fmt=num2 />
  <Column id=eth_exposed title="funds exposed (Ξ)" fmt=num2 />
</DataTable>

## Cover Funds Exposed within <Value data={cover_list} column=plan/>
<DataTable data={cover_wallet_protocol_list} totalRow=true search=true>
  <Column id=cover_id title="cover id" totalAgg="grand total"/>
  <Column id=wallet title="wallet"/>
  <Column id=protocol title="protocol" />
  <Column id=usd_exposed title="funds exposed ($)" fmt=num2 totalAgg=sum />
  <Column id=eth_exposed title="funds exposed (Ξ)" fmt=num4 totalAgg=sum />
</DataTable>

```sql cover_wallet_protocol_usd_treemap
select protocol as name, usd_exposed as value
from ${cover_wallet_protocol_list}
```

```sql cover_wallet_protocol_eth_treemap
select protocol as name, eth_exposed as value
from ${cover_wallet_protocol_list}
```

<Tabs>
  <Tab label='USD'>
    <ECharts config={
      {
        title: {
          left: 'center'
        },
        tooltip: {
          formatter: '{b}: {c}'
        },
        series: [
          {
            type: 'treemap',
            visibleMin: 300,
            label: {
              show: true,
              formatter: '{b}'
            },
            itemStyle: {
              borderColor: '#fff'
            },
            roam: false,
            nodeClick: false,
            data: [...cover_wallet_protocol_usd_treemap],
            breadcrumb: {
              show: false
            }
          }
        ]
        }
      }
    />
  </Tab>
  <Tab label='ETH'>
    <ECharts config={
      {
        title: {
          left: 'center'
        },
        tooltip: {
          formatter: '{b}: {c}'
        },
        series: [
          {
            type: 'treemap',
            visibleMin: 300,
            label: {
              show: true,
              formatter: '{b}'
            },
            itemStyle: {
              borderColor: '#fff'
            },
            roam: false,
            nodeClick: false,
            data: [...cover_wallet_protocol_eth_treemap],
            breadcrumb: {
              show: false
            }
          }
        ]
        }
      }
    />
  </Tab>
</Tabs>

## Cover Funds Exposed outside <Value data={cover_list} column=plan/>
<DataTable data={cover_wallet_protocol_diff_list} totalRow=true search=true>
  <Column id=cover_id title="cover id" totalAgg="grand total"/>
  <Column id=wallet title="wallet"/>
  <Column id=protocol title="protocol" />
  <Column id=usd_exposed title="funds exposed ($)" fmt=num2 totalAgg=sum />
  <Column id=eth_exposed title="funds exposed (Ξ)" fmt=num4 totalAgg=sum />
</DataTable>
