model (
  name prod.cover_agg,
  kind view
);

select
  cu.cover_id::bigint as cover_id,
  cu.product_id::int as product_id,
  cu.listing::varchar as listing,
  min(cu.is_plan)::boolean as is_plan,
  min(cu.cover_start_date)::date as cover_start_date,
  min(cu.cover_end_date)::date as cover_end_date,
  min(cu.is_active)::boolean as is_active,
  sum(cw.cnt_wallet)::int as cnt_wallet,
  sum(cu.usd_cover_amount)::double as usd_cover,
  sum(cu.eth_cover_amount)::double as eth_cover
from wallets.prod.cover cu
  inner join (
    select
      cover_id,
      count(distinct wallet) as cnt_wallet
    from wallets.prod.cover_wallet
    where is_active
    group by 1
  ) cw on cu.cover_id = cw.cover_id
where cu.is_active
group by 1, 2, 3;
