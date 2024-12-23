select
  cu.plan_id,
  cu.plan,
  count(distinct cu.cover_id) as cnt_cover,
  sum(cw.cnt_wallet) as cnt_wallet,
  sum(cu.usd_cover_amount) as usd_cover,
  sum(cu.eth_cover_amount) as eth_cover
from wallets.vw_cover cu
  inner join (
    select
      cover_id,
      count(distinct monitored_wallet) as cnt_wallet
    from wallets.vw_cover_wallet
    group by 1
  ) cw on cu.cover_id = cw.cover_id
group by 1, 2
order by 1
