model (
  name prod.capital_pool,
  kind incremental_by_time_range (
    time_column block_date
  ),
  cron '@daily',
  grain block_date,
  audits (
    not_null(columns := (block_date, avg_eth_usd_price, avg_capital_pool_eth_total, avg_capital_pool_usd_total)),
    unique_values(columns := (block_date))
  )
);

select
  block_date::date as block_date,
  avg_eth_usd_price::double as avg_eth_usd_price,
  avg_capital_pool_eth_total::double as avg_capital_pool_eth_total,
  avg_capital_pool_usd_total::double as avg_capital_pool_usd_total
from wallets.main.capital_pool
where block_date::date between @start_dt and @end_dt;
