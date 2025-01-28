select 1 as id, 'Elite Cover Exposure' as name, format('${:,.2f}', sum(usd_protocol_exposed)) as value
from prod.cover_wallet_protocol_totals where listing = 'Elite Cover'
union all
select 2, 'Coverage Ratio 1>', format('${:,.2f}', sum(usd_protocol_exposed)) as value
from prod.cover_wallet_protocol_totals where listing = 'Elite Cover' and coverage_cover_ratio > 1
union all
select 3, 'Coverage Ratio 1<', format('${:,.2f}', sum(usd_protocol_exposed)) as value
from prod.cover_wallet_protocol_totals where listing = 'Elite Cover' and coverage_cover_ratio <= 1
union all
select
  4,
  'Percentage of Covered Users',
  format('{:,.2f}%',
    sum(case when coverage_cover_ratio > 1 then usd_protocol_exposed end) / sum(usd_protocol_exposed) * 100
  ) as value
from prod.cover_wallet_protocol_totals where listing = 'Elite Cover'
union all
select 5, 'Min Base Price', ''
order by 1
