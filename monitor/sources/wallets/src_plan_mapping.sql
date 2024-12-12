select
  case plan
    when 'Entry Cover' then 1
    when 'Essential Cover' then 2
    when 'Elite Cover' then 3
  end plan_id,
  plan,
  protocol,
  zapper_id,
  zapper_name,
  zerion_id,
  zerion_name
from wallets.plan_mapping
order by plan_id, protocol
