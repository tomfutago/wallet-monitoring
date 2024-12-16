import duckdb
from pipelines.debank_pipeline import *
from pipelines.dune_pipeline import *

def loop_through_cover_wallets():
  wallet = "0xbad"

  try:
    # execute query and fetch results as df
    result_df = duckdb_con.execute("SELECT DISTINCT cover_id, monitored_wallet FROM cover_wallets").fetchdf()
    for _, row in result_df.iterrows():
      cover_id = row["cover_id"]
      wallet = row["monitored_wallet"]
      load_user_all_simple_protocol_list(cover_id, wallet)

  except Exception as e:
    print(f"error for cover_id: {cover_id} and wallet: {wallet}: {e}")

if __name__ == "__main__":
  # create duckdb connection
  duckdb_con = duckdb.connect("../data/wallets.duckdb")
  
  loop_through_cover_wallets()

  # close duckdb connection
  duckdb_con.close()
