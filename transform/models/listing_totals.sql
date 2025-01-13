model (
  name prod.listing_totals,
  kind view
);

with listing_exposed_agg as (
  select
    product_id,
    listing,
    sum(usd_exposed) as usd_exposed,
    sum(eth_exposed) as eth_exposed
  from wallets.prod.cover_wallet_enriched
  where is_active
  group by 1, 2
  having sum(usd_exposed) >= 0.01
)

select
  pc.product_id::int as product_id,
  pc.listing::varchar as listing,
  pc.is_plan::boolean as is_plan,
  pc.cnt_cover::int as cnt_cover,
  pc.cnt_wallet::int as cnt_wallet,
  pc.usd_cover::double as usd_cover,
  pc.eth_cover::double as eth_cover,
  pw.usd_exposed::double as usd_exposed,
  pw.eth_exposed::double as eth_exposed
from wallets.prod.listing_agg pc
  left join listing_exposed_agg pw on pc.product_id = pw.product_id;
