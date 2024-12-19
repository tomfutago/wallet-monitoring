select
  block_date,
  avg_eth_usd_price,
  avg_capital_pool_eth_total,
  avg_capital_pool_usd_total
from wallets.capital_pool
order by 1
