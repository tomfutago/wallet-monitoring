import dlt

pipeline = dlt.pipeline(
  pipeline_name="read_max_cover_id",
  destination="motherduck",
  dataset_name="main"
)

with pipeline.sql_client() as client:
  with client.execute_query("SELECT MAX(cover_id) FROM cover_wallets") as cursor:
    max_cover_id = cursor.fetchone()[0]

print(max_cover_id)
