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


```mapping
select * from mapping.plan_mapping
```

```cover_wallets
select * from wallets.cover_wallets order by 1
```

```zerion_data
select * from wallets.zerion_data order by 1
```

```zapper_data
select * from wallets.zapper_data order by 1
```

```wallet_positions
select * from ${wallet_positions}
```
