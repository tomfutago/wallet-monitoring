model (
  name prod.cover_wallet,
  kind incremental_by_unique_key (
    unique_key (cover_id, wallet)
  ),
  cron '@daily',
  grain (columns := (cover_id, wallet)),
  audits (
    not_null(columns := (cover_id, wallet)),
    unique_combination_of_columns(columns := (cover_id, wallet))
  )
);

select
  cover_id::bigint as cover_id,
  monitored_wallet::varchar as wallet,
  concat(left(monitored_wallet, 6), '..', right(monitored_wallet, 4))::varchar as wallet_short,
  if(cover_end_date::date >= current_date, true, false)::boolean as is_active
from wallets.main.cover_wallets
where 1=1;
