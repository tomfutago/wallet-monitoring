select
  concat(left(monitored_wallet, 6), '..', right(monitored_wallet, 4)) as wallet,
  string_agg(distinct plan, ', ' order by plan) as plans,
  string_agg(distinct cover_id, ', ' order by cover_id) as covers,
  count(*) as count
from wallets.prod.cover_wallet
where monitored_wallet in (
  select monitored_wallet from wallets.prod.cover_wallet group by 1 having count(*) > 1
)
group by 1
order by 1
