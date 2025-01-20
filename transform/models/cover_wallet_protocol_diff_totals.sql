model (
  name prod.cover_wallet_protocol_diff_totals,
  kind view
);

with cover_wallet_protocol_diff_totals_daily_ext as (
  select *, row_number() over (partition by cover_id, wallet, protocol order by load_dt desc) as load_dt_rn
  from wallets.prod.cover_wallet_protocol_diff_totals_daily
)

select
  cover_id::bigint as cover_id,
  listing::varchar as listing,
  is_plan::boolean as is_plan,
  wallet::varchar as wallet,
  wallet_short::varchar as wallet_short,
  protocol::varchar as protocol,
  usd_cover::double as usd_cover,
  eth_cover::double as eth_cover,
  usd_exposed::double as usd_exposed,
  eth_exposed::double as eth_exposed,
  cover_start_date::date as cover_start_date,
  cover_end_date::date as cover_end_date
from cover_wallet_protocol_diff_totals_daily_ext
where load_dt_rn = 1;
