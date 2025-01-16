model (
  name prod.debank_data_latest_diff,
  kind view
);

select
  load_dt::date as load_dt,
  wallet::varchar as wallet,
  protocol::varchar as protocol,
  chain::varchar as chain,
  net_usd_value::double as net_usd_value,
  asset_usd_value::double as asset_usd_value,
  debt_usd_value::double as debt_usd_value,
  net_eth_value::double as net_eth_value,
  asset_eth_value::double as asset_eth_value,
  debt_eth_value::double as debt_eth_value
from wallets.prod.debank_data_daily_diff
where is_latest;
