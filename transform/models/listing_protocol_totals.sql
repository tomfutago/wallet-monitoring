model (
  name prod.listing_protocol_totals,
  kind view
);

with listing_exposed_agg as (
  select
    product_id,
    listing,
    protocol,
    sum(usd_exposed) as usd_exposed,
    sum(eth_exposed) as eth_exposed
  from (
    select distinct wallet, product_id, listing, protocol, usd_exposed, eth_exposed
    from wallets.prod.cover_wallet_enriched
    where is_active
  ) t
  group by 1, 2, 3
  having sum(usd_exposed) >= 0.01
)

select
  la.product_id::int as product_id,
  la.listing::varchar as listing,
  lea.protocol::varchar as protocol,
  la.is_plan::boolean as is_plan,
  la.cnt_cover::int as cnt_cover,
  la.cnt_wallet::int as cnt_wallet,
  la.usd_cover::double as usd_cover,
  la.eth_cover::double as eth_cover,
  lea.usd_exposed::double as usd_exposed,
  lea.eth_exposed::double as eth_exposed
from wallets.prod.listing_agg la
  left join listing_exposed_agg lea on la.product_id = lea.product_id;
