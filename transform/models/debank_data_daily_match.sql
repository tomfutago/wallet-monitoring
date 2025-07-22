model (
  name prod.debank_data_daily_match,
  kind incremental_by_time_range (
    time_column load_dt
  ),
  cron '@daily',
  audits (
    not_null(columns := (load_dt, wallet, protocol, chain)),
    unique_combination_of_columns(columns := (load_dt, wallet, protocol, chain))
  )
);

with

mapping_unique_procols as (
  select distinct protocol, debank_name
  from wallets.prod.listing_mapping
)

select
  d.load_dt::date as load_dt,
  d.wallet::varchar as wallet,
  m.protocol::varchar as protocol,
  d.chain::varchar as chain,
  d.net_usd_value::double as net_usd_value,
  d.asset_usd_value::double as asset_usd_value,
  d.debt_usd_value::double as debt_usd_value,
  d.net_eth_value::double as net_eth_value,
  d.asset_eth_value::double as asset_eth_value,
  d.debt_eth_value::double as debt_eth_value,
  d.is_latest::boolean as is_latest
from wallets.prod.debank_data_daily d
  inner join mapping_unique_procols m on d.debank_name = m.debank_name
where d.load_dt between @start_dt and @end_dt;
