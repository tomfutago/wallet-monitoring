import dlt
from dune_client.client import DuneClient
from dune_client.query import QueryBase

dune_api_key = dlt.secrets["sources.dune.api_key"]
duckdb_destination = "../data/wallets.duckdb"

dune = DuneClient(dune_api_key)

def load_capital_pool():
  df = dune.run_query_dataframe(QueryBase(query_id=4391959))

  if not df.empty:
    pipeline = dlt.pipeline(
      pipeline_name="dune_capital_pool",
      destination=dlt.destinations.duckdb(duckdb_destination),
      dataset_name="main"
    )

    load_info = pipeline.run(
      df,
      table_name="capital_pool",
      write_disposition="replace"
    )
    print(load_info)

def load_cover_wallets():
  df = dune.run_query_dataframe(QueryBase(query_id=4340708))
  
  if not df.empty:
    pipeline = dlt.pipeline(
      pipeline_name="dune_cover_wallets",
      destination=dlt.destinations.duckdb(duckdb_destination),
      dataset_name="main"
    )

    load_info = pipeline.run(
      df,
      table_name="cover_wallets",
      write_disposition="replace"
    )
    print(load_info)

if __name__ == "__main__":
  #load_capital_pool()
  load_cover_wallets()