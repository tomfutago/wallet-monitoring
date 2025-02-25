select 1 as id, 'Deductible' as name, '5%' as usd_value, '5%' as eth_value
union all
select 2, 'Total Wallets', format('{:,}', sum(cnt_wallet)), format('{:,}', sum(cnt_wallet)) 
from prod.listing_agg where is_plan
union all
select 3, 'Cover Amount', format('${:,.2f}', sum(usd_cover)), format('Ξ{:,.2f}', sum(eth_cover))
from prod.listing_agg where is_plan 
union all
select 4, 'Max Liability', format('${:,.2f}', sum(usd_cover) * 0.95), format('Ξ{:,.2f}', sum(eth_cover) * 0.95)
from prod.listing_agg where is_plan
union all
select 5, 'Exposed Funds', format('${:,.2f}', sum(usd_exposed)), format('Ξ{:,.2f}', sum(eth_exposed))
from prod.listing_totals_all where is_plan
union all
select 6, 'Coverage Ratio', format('{:,.2f}%', sum(usd_cover) / sum(usd_exposed) * 100), format('{:,.2f}%', sum(eth_cover) / sum(eth_exposed) * 100)
from prod.listing_totals_all where is_plan
order by 1
