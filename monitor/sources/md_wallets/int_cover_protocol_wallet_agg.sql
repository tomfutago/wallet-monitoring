select
  cover_id,
  concat(left(wallet, 6), '..', right(wallet, 4)) as wallet,
  protocol,
  sum(net_usd_value) as usd_exposed,
  sum(net_eth_value) as eth_exposed
from wallets.vw_cover_wallet_enriched
group by 1, 2, 3
having sum(net_usd_value) >= 0.01
order by 1, 2, 3
