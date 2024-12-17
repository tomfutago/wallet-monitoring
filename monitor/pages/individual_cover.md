---
title: Individual Cover Tracker
---

```cover_dropdown
select cover_id from wallets.src_cover order by 1
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
from wallets.int_cover_agg c
  left join wallets.int_cover_wallet_agg cw on c.cover_id = cw.cover_id
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
from wallets.int_cover_agg c
  left join wallets.int_cover_protocol_wallet_agg cw on c.cover_id = cw.cover_id
where c.cover_id = '${inputs.cover_id.value}'
order by 2, 3
```

## Cover Overview

<DataTable data={cover_list}>
  <Column id=cover_id title="cover id"/>
  <Column id=plan title="plan"/>
  <Column id=cnt_wallet title="# wallets" />
  <Column id=usd_cover title="cover ($)" />
  <Column id=eth_cover title="cover (Ξ)" />
  <Column id=usd_exposed title="funds exposed ($)" />
  <Column id=eth_exposed title="funds exposed (Ξ)" />
</DataTable>

<DataTable data={cover_wallet_protocol_list} totalRow=true search=true>
  <Column id=cover_id title="cover id" totalAgg="grand total"/>
  <Column id=wallet title="wallet"/>
  <Column id=protocol title="protocol" />
  <Column id=usd_cover title="cover ($)" totalAgg=mean />
  <Column id=eth_cover title="cover (Ξ)" totalAgg=mean />
  <Column id=usd_exposed title="funds exposed ($)" totalAgg=sum />
  <Column id=eth_exposed title="funds exposed (Ξ)" totalAgg=sum />
</DataTable>
