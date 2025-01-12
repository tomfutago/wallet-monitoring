select
  cover_id,
  wallet,
  wallet_short,
  protocol,
  sum(usd_exposed) as usd_exposed,
  sum(eth_exposed) as eth_exposed
from prod.cover_wallet_enriched
where is_active
  and is_plan
group by 1, 2, 3, 4
having sum(usd_exposed) >= 0.01
order by 1, 2, 4
