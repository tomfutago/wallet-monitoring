---
title: Cover List
---

```duped_wallets
select * from md_wallets.duped_wallets order by 1
```

## Wallets with Multiple Covers
<DataTable data={duped_wallets} totalRow=true>
  <Column id=wallet title=wallet totalAgg="grand total"/>
  <Column id=listings title=listings/>
  <Column id=covers title=covers/>
  <Column id=count title="# wallets" totalAgg=sum />
</DataTable>

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
  c.eth_cover * 0.05 as eth_deductible,
  c.cover_start_date,
  c.cover_end_date
from md_wallets.cover_agg c
  left join md_wallets.int_cover_wallet_agg cw on c.cover_id = cw.cover_id
```

## Nexus Mutual Cover List

<DataTable data={cover_list}>
  <Column id=cover_id title="cover id" />
  <Column id=plan title="plan" />
  <Column id=cnt_wallet title="# wallets" />
  <Column id=usd_cover title="cover ($)" fmt=num2 />
  <Column id=eth_cover title="cover (Ξ)" fmt=num2 />
  <Column id=usd_exposed title="funds exposed ($)" fmt=num2 />
  <Column id=eth_exposed title="funds exposed (Ξ)" fmt=num2 />
  <Column id=coverage_ratio title="coverage (%)" fmt=pct2 />
  <Column id=usd_deductible title="deductible ($)" fmt=num2 />
  <Column id=eth_deductible title="deductible (Ξ)" fmt=num2 />
  <Column id=cover_start_date title="start date" fmt='yyyy-mm-dd' />
  <Column id=cover_end_date title="end date" fmt='yyyy-mm-dd' />
</DataTable>
