model (
  name prod.duped_wallets,
  kind view
);

select
  wallet_short::varchar as wallet,
  string_agg(distinct listing, ', ' order by listing)::varchar as listings,
  string_agg(distinct cover_id, ', ' order by cover_id)::varchar as covers,
  count(*)::int as count
from wallets.prod.cover_wallet
where is_active
  and wallet <> '0x40329f3e27dd3fe228799b4a665f6f104c2ab6b4' -- OpenCover
  and wallet in (
    select wallet from wallets.prod.cover_wallet group by 1 having count(*) > 1
  )
group by 1;
