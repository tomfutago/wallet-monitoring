model (
  name prod.cover_totals,
  kind view
);

with cover_exposed_agg as (
  select
    cover_id,
    listing,
    sum(usd_exposed) as usd_exposed,
    sum(eth_exposed) as eth_exposed
  from wallets.prod.cover_wallet_enriched
  where is_active
  group by 1, 2
  having sum(usd_exposed) >= 0.01
)

select
  c.cover_id::bigint as cover_id,
  c.listing::varchar as listing,
  c.is_plan::boolean as is_plan,
  c.cnt_wallet::int as cnt_wallet,
  c.usd_cover::double as usd_cover,
  c.eth_cover::double as eth_cover,
  cw.usd_exposed::double as usd_exposed,
  cw.eth_exposed::double as eth_exposed,
  (c.usd_cover / cw.usd_exposed)::double as coverage_ratio,
  (c.usd_cover * 0.05)::double as usd_deductible,
  (c.eth_cover * 0.05)::double as eth_deductible,
  c.cover_start_date::date as cover_start_date,
  c.cover_end_date::date as cover_end_date
from wallets.prod.cover_agg c
  left join cover_exposed_agg cw on c.cover_id = cw.cover_id;
