model (
  name prod.debank_data,
  kind incremental_by_time_range (
    time_column load_dt
  ),
);

with api_data as (
  select
    b.wallet,
    b.name as protocol,
    c.name as chain,
    b.net_usd_value,
    b.asset_usd_value,
    coalesce(b.debt_usd_value__v_double, b.debt_usd_value) as debt_usd_value,
    to_timestamp(cast(b._dlt_load_id as double))::timestamp as load_dt
  from wallets.main.debank_wallet_protocol_balance b
    inner join wallets.main.debank_chains c on b.chain = c.id
  where to_timestamp(cast(b._dlt_load_id as double))::timestamp between @start_ts and @end_ts
)

select
  wallet,
  protocol,
  chain,
  net_usd_value,
  asset_usd_value,
  debt_usd_value,
  load_dt
from api_data;
