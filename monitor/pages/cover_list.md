---
title: Cover List
---

```duped_wallets
select wallet, listings, covers, count
from md_wallets.duped_wallets
order by 1
```

## Wallets with Multiple Covers
<DataTable data={duped_wallets} totalRow=true>
  <Column id=wallet title=wallet totalAgg="grand total"/>
  <Column id=listings title=listings/>
  <Column id=covers title=covers/>
  <Column id=count title="# covers" totalAgg=sum />
</DataTable>

```cover_list
select
  cover_id,
  listing,
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
order by 1
```

## Nexus Mutual Cover List

<DataTable data={cover_list} totalRow=true search=true >
  <Column id=cover_id title="cover id" totalAgg="grand total" />
  <Column id=listing title="plan" />
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

```listing_list
select
  cover_id,
  listing,
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
where is_plan = false
order by 1
```

## Non-Nexus Mutual Cover List

<DataTable data={listing_list} totalRow=true search=true >
  <Column id=cover_id title="cover id" totalAgg="grand total" />
  <Column id=listing title="listing" />
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

<LastRefreshed prefix="Data last updated"/>
