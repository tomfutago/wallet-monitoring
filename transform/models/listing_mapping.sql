model (
  name prod.listing_mapping,
  kind full,
  audits (
    not_null(columns := (product_id, product_type, product_name, protocol)),
    unique_combination_of_columns(columns := (product_id, product_type, product_name, protocol, debank_name))
  )
);

select
  product_id::int as product_id,
  product_type::varchar as product_type,
  product_name::varchar as product_name,
  null::varchar as plan,
  coalesce(included_protocol, product_name)::varchar as protocol,
  null::double as base_pricing,
  debank_id::varchar as debank_id,
  debank_name::varchar as debank_name,
  '0.09' as version
from wallets.main.listing_mapping
union all
select
  case plan
    when 'Entry Cover' then 245
    when 'Essential Cover' then 246
    when 'Elite Cover' then 247
    when 'L1 Advisors Cover' then 273
    when 'Brava Conservative Cover' then 296
    when 'Brava Balanced Cover' then 297
    when 'Brava Advanced Cover' then 298
  end::int as product_id,
  'Nexus Mutual Cover'::varchar as product_type,
  plan::varchar as product_name,
  plan::varchar as plan,
  protocol::varchar as protocol,
  replace(base_pricing, '%', '')::double / 100 as base_pricing,
  debank_id::varchar as debank_id,
  debank_name::varchar as debank_name,
  '0.09' as version
from wallets.main.plan_mapping
where is_subprotocol = false;
