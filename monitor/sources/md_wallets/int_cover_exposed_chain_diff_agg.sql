select
  c.cover_id,
  api.chain,
  sum(api.net_usd_value) as usd_exposed,
  sum(api.net_eth_value) as eth_exposed
from wallets.vw_cover_wallet c
  inner join wallets.vw_debank_data_latest_diff api on c.monitored_wallet = api.wallet
group by 1, 2
having sum(api.net_usd_value) >= 0.01
order by 1, 2