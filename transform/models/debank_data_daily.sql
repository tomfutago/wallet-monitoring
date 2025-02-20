model (
  name prod.debank_data_daily,
  kind incremental_by_time_range (
    time_column load_dt
  ),
  cron '@daily',
  audits (
    not_null(columns := (load_dt, wallet, debank_name, chain)),
    unique_combination_of_columns(columns := (load_dt, wallet, debank_name, chain))
  )
);

with

prices as (
  select
    block_date,
    avg_eth_usd_price,
    row_number() over (order by block_date desc) as block_date_rn
  from wallets.prod.capital_pool
),

debank_data_daily as (
  select
    d.load_dt,
    d.wallet,
    d.debank_name,
    d.chain,
    if(p.block_date_rn = 1, true, false) as is_latest,
    max_by(d.net_usd_value, d.load_dt) as net_usd_value,
    max_by(d.asset_usd_value, d.load_dt) as asset_usd_value,
    max_by(d.debt_usd_value, d.load_dt) as debt_usd_value,
    max_by(d.net_usd_value / p.avg_eth_usd_price, d.load_dt) as net_eth_value,
    max_by(d.asset_usd_value / p.avg_eth_usd_price, d.load_dt) as asset_eth_value,
    max_by(d.debt_usd_value / p.avg_eth_usd_price, d.load_dt) as debt_eth_value
  from wallets.prod.debank_data d
    inner join prices p on d.load_dt = p.block_date
  where d.load_dt between @start_dt and @end_dt
  group by 1, 2, 3, 4, 5
)

select
  load_dt::date as load_dt,
  wallet::varchar as wallet,
  debank_name::varchar as debank_name,
  chain::varchar as chain,
  net_usd_value::double as net_usd_value,
  asset_usd_value::double as asset_usd_value,
  debt_usd_value::double as debt_usd_value,
  net_eth_value::double as net_eth_value,
  asset_eth_value::double as asset_eth_value,
  debt_eth_value::double as debt_eth_value,
  is_latest::boolean as is_latest
from debank_data_daily
where 1=1;
