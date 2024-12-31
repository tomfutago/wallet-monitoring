model (
  name prod.debank_data,
  kind incremental_by_time_range (
    time_column load_ts
  ),
  cron '@daily',
  audits (
    not_null(columns := (wallet, protocol, chain, load_ts)),
    unique_combination_of_columns(columns := (wallet, protocol, chain, load_ts))
  )
);

with api_data as (
  select
    b.wallet,
    b.name as protocol,
    c.name as chain,
    b.net_usd_value,
    b.asset_usd_value,
    coalesce(b.debt_usd_value__v_double, b.debt_usd_value) as debt_usd_value,
    to_timestamp(cast(b._dlt_load_id as double))::timestamp as load_ts
  from wallets.main.debank_wallet_protocol_balance b
    inner join wallets.main.debank_chains c on b.chain = c.id
  where to_timestamp(cast(b._dlt_load_id as double))::timestamp between @start_ts and @end_ts
)

select
  wallet::varchar as wallet,
  protocol::varchar as protocol,
  chain::varchar as chain,
  net_usd_value::double as net_usd_value,
  asset_usd_value::double as asset_usd_value,
  debt_usd_value::double as debt_usd_value,
  load_ts::timestamp as load_ts
from api_data;
