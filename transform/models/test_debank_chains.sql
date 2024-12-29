model (
  name prod.test_debank_chains,
  kind view,
);

select
  id,
  community_id,
  name
from main.debank_chains
