import dlt
from dune_client.client import DuneClient
from dune_client.query import QueryBase
from dune_client.types import QueryParameter

dune_api_key = dlt.secrets["sources.dune.api_key"]
dune = DuneClient(dune_api_key)

def load_capital_pool():
  df = dune.run_query_dataframe(QueryBase(query_id=4391959))

  if not df.empty:
    pipeline = dlt.pipeline(
      pipeline_name="dune_capital_pool",
      destination="motherduck",
      dataset_name="main"
    )

    load_info = pipeline.run(
      df,
      table_name="capital_pool",
      write_disposition="replace"
    )
    print(load_info)

def load_cover_wallets(max_cover_id: int):
  cover_list_query = QueryBase(
    query_id=4340708,
    params=[
      QueryParameter.text_type(name="max_cover_id", value=max_cover_id),
    ],
  )
  df = dune.run_query_dataframe(query=cover_list_query)
  
  if not df.empty:
    pipeline = dlt.pipeline(
      pipeline_name="dune_cover_wallets",
      destination="motherduck",
      dataset_name="main"
    )

    load_info = pipeline.run(
      df,
      table_name="cover_wallets",
      write_disposition="append"
    )
    print(load_info)

if __name__ == "__main__":
  load_capital_pool()
  #load_cover_wallets(max_cover_id=1600) # test
