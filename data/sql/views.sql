create or replace view vw_plan_mapping as
select
  case plan
    when 'Entry Cover' then 1
    when 'Essential Cover' then 2
    when 'Elite Cover' then 3
  end plan_id,
  plan,
  protocol,
  debank_id,
  debank_name
from wallets.plan_mapping;

create or replace view vw_cover as
select distinct
  cover_id,
  case plan
    when 'Entry Cover' then 1
    when 'Essential Cover' then 2
    when 'Elite Cover' then 3
  end plan_id,
  plan,
  cover_start_date,
  cover_end_date,
  cover_asset,
  native_cover_amount,
  usd_cover_amount,
  eth_cover_amount,
  cover_owner
from wallets.cover_wallets;

create or replace view vw_cover_wallet as
select
  cover_id,
  case plan
    when 'Entry Cover' then 1
    when 'Essential Cover' then 2
    when 'Elite Cover' then 3
  end plan_id,
  plan,
  cover_start_date,
  cover_end_date,
  cover_asset,
  native_cover_amount,
  usd_cover_amount,
  eth_cover_amount,
  cover_owner,
  monitored_wallet
from wallets.cover_wallets;

create or replace view vw_debank_data as
select
  wallet,
  name as debank_name,
  chain,
  net_usd_value,
  asset_usd_value,
  coalesce(debt_usd_value__v_double, debt_usd_value) as debt_usd_value,
  to_timestamp(cast(_dlt_load_id as double)) as load_dt
from wallets.debank_wallet_protocol_balance;

create or replace view vw_debank_data_latest as
with

latest_prices as (
  select max_by(avg_eth_usd_price, block_date) as avg_eth_usd_price
  from wallets.capital_pool
),

debank_data_latest as (
  select
    d.wallet,
    d.debank_name,
    d.chain,
    max_by(d.net_usd_value, d.load_dt) as net_usd_value,
    max_by(d.asset_usd_value, d.load_dt) as asset_usd_value,
    max_by(d.debt_usd_value, d.load_dt) as debt_usd_value,
    max_by(d.net_usd_value / p.avg_eth_usd_price, d.load_dt) as net_eth_value,
    max_by(d.asset_usd_value / p.avg_eth_usd_price, d.load_dt) as asset_eth_value,
    max_by(d.debt_usd_value / p.avg_eth_usd_price, d.load_dt) as debt_eth_value,
    max(d.load_dt) as load_dt
  from wallets.vw_debank_data d
    cross join latest_prices p
  group by 1, 2, 3
)

select
  wallet,
  debank_name,
  chain,
  net_usd_value,
  asset_usd_value,
  debt_usd_value,
  net_eth_value,
  asset_eth_value,
  debt_eth_value,
  load_dt
from debank_data_latest;

create or replace view vw_debank_data_latest_match as
with

mapping_unique_procols as (
  select distinct protocol, debank_id, debank_name
  from wallets.plan_mapping
)

select
  d.wallet,
  m.protocol,
  d.chain,
  d.net_usd_value,
  d.asset_usd_value,
  d.debt_usd_value,
  d.net_eth_value,
  d.asset_eth_value,
  d.debt_eth_value,
  d.load_dt
from wallets.vw_debank_data_latest d
  inner join mapping_unique_procols m on d.debank_name = m.debank_name;

create or replace view vw_debank_data_latest_diff as
with

mapping_unique_procols as (
  select distinct protocol, debank_id, debank_name
  from wallets.plan_mapping
)

select
  d.wallet,
  m.protocol,
  d.chain,
  d.net_usd_value,
  d.asset_usd_value,
  d.debt_usd_value,
  d.net_eth_value,
  d.asset_eth_value,
  d.debt_eth_value,
  d.load_dt
from wallets.vw_debank_data_latest d
  left join mapping_unique_procols m on d.debank_name = m.debank_name
where m.protocol is null;

create or replace view vw_cover_wallet_enriched as
select
  c.plan_id,
  c.plan,
  c.cover_id,
  api.protocol,
  api.wallet,
  concat(left(api.wallet, 6), '..', right(api.wallet, 4)) as wallet_short,
  api.net_usd_value as usd_exposed,
  api.net_eth_value as eth_exposed
from wallets.vw_cover_wallet c
  inner join wallets.vw_debank_data_latest_match api on c.monitored_wallet = api.wallet
  inner join wallets.vw_plan_mapping m on c.plan_id = m.plan_id and api.protocol = m.protocol;
