select
  product_id,
  listing as plan,
  sum(usd_exposed) as usd_exposed,
  sum(eth_exposed) as eth_exposed
from wallets.prod.cover_wallet_enriched
where is_active
  and is_plan
group by 1, 2
having sum(usd_exposed) >= 0.01
order by 1
