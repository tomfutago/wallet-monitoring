model (
  name prod.duped_plan_wallets,
  kind view
);

select
  cw.wallet_short::varchar as wallet,
  string_agg(distinct c.listing, ', ' order by c.listing)::varchar as listings,
  string_agg(distinct c.cover_id, ', ' order by c.cover_id)::varchar as covers,
  count(*)::int as count
from wallets.prod.cover c
  inner join wallets.prod.cover_wallet cw on c.cover_id = cw.cover_id
where c.is_active
  and c.is_plan
  and cw.wallet not in (
    '0x40329f3e27dd3fe228799b4a665f6f104c2ab6b4', -- OpenCover
    '0xe4994082a0e7f38b565e6c5f4afd608de5eddfbb', -- OpenCover
    '0x5f2b6e70aa6a217e9ecd1ed7d0f8f38ce9a348a2', -- OpenCover
    '0x8b86cf2684a3af9dd34defc62a18a96deadc40ff', -- TRM
    '0x666b8ebfbf4d5f0ce56962a25635cff563f13161', -- Sherlock
    '0x5b453a19845e7492ee3a0df4ef085d4c75e5752b', -- Liquid Collective
    '0x2557fe0959934f3814c6ee72ab46e6687b81b8ca'  -- Ensuro
  )
  and cw.wallet in (
    select wallet from wallets.prod.cover_wallet where is_active group by 1 having count(*) > 1
  )
group by 1;
