model (
  name prod.exposure_pricing,
  kind view
);

with listing_exposure as (
  select
    m.product_id,
    m.plan as listing,
    m.protocol,
    m.base_pricing,
    pt.usd_exposed,
    pt.eth_exposed,
    pt.usd_exposed * m.base_pricing as usd_annual_cost,
    pt.eth_exposed * m.base_pricing as eth_annual_cost
  from prod.listing_mapping m
    left join (
      select
        product_id,
        protocol,
        sum(usd_protocol_exposed) as usd_exposed,
        sum(eth_protocol_exposed) as eth_exposed
      from prod.cover_wallet_protocol_totals
      group by 1, 2
    ) pt on m.product_id = pt.product_id and m.protocol = pt.protocol
  where m.plan is not null
)

select
  product_id::int as product_id,
  listing::varchar as listing,
  protocol::varchar as protocol,
  base_pricing::varchar as base_pricing,
  usd_exposed::double as usd_exposed,
  eth_exposed::double as eth_exposed,
  usd_annual_cost::double as usd_annual_cost,
  eth_annual_cost::double as eth_annual_cost
from listing_exposure;
