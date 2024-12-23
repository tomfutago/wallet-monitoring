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
from wallets.plan_mapping
order by plan_id, protocol;

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
from wallets.cover_wallets
order by 1;

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
from wallets.cover_wallets
order by cover_id, monitored_wallet;

create or replace view vw_debank_data as
select
  wallet,
  name as protocol,
  chain,
  net_usd_value,
  asset_usd_value,
  debt_usd_value,
  to_timestamp(cast(_dlt_load_id as double)) as load_dt
from wallets.debank_wallet_protocol_balance
order by 1, 2, 3;
