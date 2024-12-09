---
queries:
  - wallet_positions: wallet_positions.sql
---

## Wallet Monitoring

### Capital Pool

```capital_pool
select * from wallets.capital_pool order by 1
```

<DataTable data={capital_pool}>
  <Column id=block_date title="Date"/>
  <Column id=avg_eth_usd_price title="ETH/USD price" />
  <Column id=avg_capital_pool_eth_total title="ETH total" />
  <Column id=avg_capital_pool_usd_total title="USD total" />
</DataTable>


```plans
with agg_wallet_positions as (
  select
    plan_id,
    plan,
    count(distinct cover_id) as cnt_cover,
    count(distinct monitored_wallet) as cnt_wallet,
    sum(sum_assured) as total_cover,
    sum(amount_usd) as total_exposed_usd,
    sum(amount_eth) as total_exposed_eth
  from ${wallet_positions}
  group by 1, 2
)
select
  plan,
  cnt_cover,
  cnt_wallet,
  total_cover,
  total_exposed_usd,
  total_exposed_eth
from agg_wallet_positions
order by plan_id
```
