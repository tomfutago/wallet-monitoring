model (
  name prod.listing_mapping,
  kind full,
  audits (
    not_null(columns := (product_id, product_type, product_name, protocol)),
    unique_combination_of_columns(columns := (product_id, product_type, protocol, debank_name))
  )
);

select
  product_id::int as product_id,
  product_type::varchar as product_type,
  product_name::varchar as product_name,
  null::int as plan_id,
  null::varchar as plan,
  coalesce(included_protocol, product_name)::varchar as protocol,
  debank_id::varchar as debank_id,
  debank_name::varchar as debank_name
from wallets.main.listing_mapping
union all
select
  case plan
    when 'Entry Cover' then 245
    when 'Essential Cover' then 246
    when 'Elite Cover' then 247
  end::int as product_id,
  'Nexus Mutual Cover'::varchar as product_type,
  plan::varchar as product_name,
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