select
  cover_id,
  chain,
  sum(usd_exposed) as usd_exposed,
  sum(eth_exposed) as eth_exposed
from wallets.vw_cover_wallet_enriched
group by 1, 2
having sum(usd_exposed) >= 0.01
order by 1, 2