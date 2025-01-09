model (
  name prod.listing_mapping,
  kind full,
  audits (
    not_null(columns := (product_id, product_type, product_name)),
    unique_combination_of_columns(columns := (product_id, product_type, product_name, included_protocol, debank_name))
  )
);

select
  product_id::int as product_id,
  product_type::varchar as product_type,
  product_name::varchar as product_name,
  included_protocol::varchar as included_protocol,
  debank_id::varchar as debank_id,
  debank_name::varchar as debank_name
from wallets.main.listing_mapping;
