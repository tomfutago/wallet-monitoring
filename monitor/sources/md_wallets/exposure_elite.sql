select
  1 as id,
  'Elite Cover Exposure' as name,
  format('${:,.2f}', sum(usd_protocol_exposed)) as usd_value,
  format('Ξ{:,.2f}', sum(eth_protocol_exposed)) as eth_value
from prod.cover_wallet_protocol_totals
where listing = 'Elite Cover'

union all

select
  2,
  'Coverage Ratio 1>',
  format('${:,.2f}', sum(usd_protocol_exposed)),
  format('Ξ{:,.2f}', sum(eth_protocol_exposed))
from prod.cover_wallet_protocol_totals
where listing = 'Elite Cover'
  and coverage_cover_ratio > 1

union all

select
  3,
  'Coverage Ratio 1<',
  format('${:,.2f}', sum(usd_protocol_exposed)),
  format('Ξ{:,.2f}', sum(eth_protocol_exposed))
from prod.cover_wallet_protocol_totals
where listing = 'Elite Cover'
  and coverage_cover_ratio <= 1

union all

select
  4,
  'Percentage of Covered Users',
  format('{:,.2f}%',
    sum(case when coverage_cover_ratio > 1 then usd_protocol_exposed end) / sum(usd_protocol_exposed) * 100
  ),
  format('{:,.2f}%',
    sum(case when coverage_cover_ratio > 1 then eth_protocol_exposed end) / sum(eth_protocol_exposed) * 100
  )
from prod.cover_wallet_protocol_totals
where listing = 'Elite Cover'

union all

select
  5,
  'Annual Cost',
  format('${:,.2f}', sum(usd_annual_cost)),
  format('Ξ{:,.2f}', sum(eth_annual_cost))
from prod.exposure_pricing
where listing = 'Elite Cover'

union all

select
  6,
  'Min Base Price',
  format('{:,.2f}%', sum(ep.usd_annual_cost) / sum(la.usd_cover) * 100),
  format('{:,.2f}%', sum(ep.eth_annual_cost) / sum(la.eth_cover) * 100)
from prod.exposure_pricing ep
  inner join prod.listing_agg la on ep.product_id = la.product_id
where ep.listing = 'Elite Cover'

order by 1
