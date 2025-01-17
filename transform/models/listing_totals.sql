model (
  name prod.listing_totals,
  kind view
);

with listing_wallet_exposed_agg as (
  select
    product_id,
    listing,
    sum(usd_exposed) as usd_exposed,
    sum(eth_exposed) as eth_exposed
  from (
    select distinct wallet, product_id, listing, usd_exposed, eth_exposed
    from wallets.prod.cover_wallet_enriched
    where is_active
  ) t
  group by 1, 2
  having sum(usd_exposed) >= 0.01
)

select
  la.product_id::int as product_id,
  la.listing::varchar as listing,
  la.is_plan::boolean as is_plan,
  la.cnt_cover::int as cnt_cover,
  la.cnt_wallet::int as cnt_wallet,
  la.usd_cover::double as usd_cover,
  la.eth_cover::double as eth_cover,
  lwa.usd_exposed::double as usd_exposed,
  lwa.eth_exposed::double as eth_exposed
from wallets.prod.listing_agg la
  left join listing_wallet_exposed_agg lwa on la.product_id = lwa.product_id;
