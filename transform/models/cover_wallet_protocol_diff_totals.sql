model (
  name prod.cover_wallet_protocol_diff_totals,
  kind view
);

with cover_wallet_protocol_diff_exposed_agg as (
  select
    c.cover_id,
    c.wallet,
    c.wallet_short,
    api.protocol,
    min(c.is_plan) as is_plan,
    sum(api.net_usd_value) as usd_exposed,
    sum(api.net_eth_value) as eth_exposed
  from wallets.prod.cover_wallet c
    inner join wallets.prod.debank_data_latest_diff api on c.wallet = api.wallet
  where c.is_active
  group by 1, 2, 3, 4
  having sum(api.net_usd_value) >= 0.01
)

select
  c.cover_id::bigint as cover_id,
  c.listing::varchar as listing,
  c.is_plan::boolean as is_plan,
  cw.wallet::varchar as wallet,
  cw.wallet_short::varchar as wallet_short,
  cw.protocol::varchar as protocol,
  c.usd_cover::double as usd_cover,
  c.eth_cover::double as eth_cover,
  cw.usd_exposed::double as usd_exposed,
  cw.eth_exposed::double as eth_exposed,
  c.cover_start_date::date as cover_start_date,
  c.cover_end_date::date as cover_end_date
from wallets.prod.cover_agg c
  left join cover_wallet_protocol_diff_exposed_agg cw on c.cover_id = cw.cover_id;
