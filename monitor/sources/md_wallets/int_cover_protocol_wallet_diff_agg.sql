select
  c.cover_id,
  c.wallet_short as wallet,
  api.protocol,
  sum(api.net_usd_value) as usd_exposed,
  sum(api.net_eth_value) as eth_exposed
from prod.cover_wallet c
  inner join prod.debank_data_latest_diff api on c.wallet = api.wallet
where c.is_active
  and c.is_plan
group by 1, 2, 3
having sum(api.net_usd_value) >= 0.01
order by 1, 2, 3
