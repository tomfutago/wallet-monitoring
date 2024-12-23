select
  c.plan_id,
  c.plan,
  sum(api.net_usd_value) as usd_exposed,
  sum(api.net_eth_value) as eth_exposed
from wallets.vw_cover_wallet c
  inner join wallets.vw_debank_data_latest_match api on c.monitored_wallet = api.wallet
  inner join wallets.vw_plan_mapping m on c.plan_id = m.plan_id and api.protocol = m.protocol
group by 1, 2
having sum(api.net_usd_value) >= 0.01
order by 1
