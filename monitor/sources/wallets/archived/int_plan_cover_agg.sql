with

cover_unique as (
  select distinct
    cover_id,
    case plan
      when 'Entry Cover' then 1
      when 'Essential Cover' then 2
      when 'Elite Cover' then 3
    end plan_id,
    plan,
    cover_asset,
    native_cover_amount,
    usd_cover_amount,
    eth_cover_amount
  from wallets.cover_wallets
  --where cover_end_date >= current_date -- active cover only
),

cover_wallets as (
  select
    cover_id,
    monitored_wallet
  from wallets.cover_wallets
  --where cover_end_date >= current_date -- active cover only
)

select
  cu.plan_id,
  cu.plan,
  count(distinct cu.cover_id) as cnt_cover,
  sum(cw.cnt_wallet) as cnt_wallet,
  sum(cu.usd_cover_amount) as usd_cover,
  sum(cu.eth_cover_amount) as eth_cover
from cover_unique cu
  inner join (
    select
      cover_id,
      count(distinct monitored_wallet) as cnt_wallet
    from cover_wallets
    group by 1
  ) cw on cu.cover_id = cw.cover_id
group by 1, 2
order by 1
