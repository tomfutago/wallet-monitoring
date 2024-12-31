select
  c.cover_id,
  concat(left(api.wallet, 6), '..', right(api.wallet, 4)) as wallet,
  api.protocol,
  sum(api.net_usd_value) as usd_exposed,
  sum(api.net_eth_value) as eth_exposed
from wallets.prod.cover_wallet c
  inner join wallets.prod.debank_data_latest_diff api on c.monitored_wallet = api.wallet
group by 1, 2, 3
having sum(api.net_usd_value) >= 0.01
order by 1, 2, 3
