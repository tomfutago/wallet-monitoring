model (
  name prod.plan_mapping,
  kind full,
  audits (
    not_null(columns := (plan_id, plan, protocol)),
    unique_combination_of_columns(columns := (plan_id, protocol, debank_name))
  )
);

select
  case plan
    when 'Entry Cover' then 1
    when 'Essential Cover' then 2
    when 'Elite Cover' then 3
  end::int as plan_id,
  plan::varchar as plan,
  protocol::varchar as protocol,
  debank_id::varchar as debank_id,
  debank_name::varchar as debank_name
from wallets.main.plan_mapping;
