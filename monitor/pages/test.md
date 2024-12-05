## Hello Evidence

### Orders Table

```my_query_summary_top100
select
   order_datetime,
   first_name,
   last_name,
   email
from needful_things.test
order by order_datetime desc
limit 100
```

<DataTable data={my_query_summary_top100}>
   <Column id=order_datetime title="Order Date"/>
   <Column id=first_name title="huzzzaaa" />
   <Column id=email />
</DataTable>

### Orders by Month

```orders_by_month
select order_month, count(*) as orders from needful_things.test
group by order_month order by order_month desc
limit 12
```
<BarChart
    data={orders_by_month}
    x=order_month
    y=orders
	xFmt="mmm yyyy"
	xAxisTitle="Month"
	yAxisTitle="Orders"
/>
