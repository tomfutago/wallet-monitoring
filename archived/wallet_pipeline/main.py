import os
import json
import base64
import requests
import pandas as pd
import duckdb
from dotenv import load_dotenv
from dune_client.client import DuneClient
from dune_client.query import QueryBase
from dune_client.types import QueryParameter

# load .env file
load_dotenv()
dune = DuneClient.from_env()
zerion_api_key = os.getenv("ZERION_API_KEY")
zapper_api_key = os.getenv("ZAPPER_API_KEY")

# create duckdb connection
duckdb_con = duckdb.connect("../data/wallets.duckdb")

def clean_up_db(table_name: str, drop_table: bool=False, truncate_table: bool=False):
  if drop_table:
    duckdb_con.execute(f"DROP TABLE IF EXISTS {table_name}")
  elif truncate_table:
    duckdb_con.execute(f"TRUNCATE TABLE {table_name}")

def safe_get(d, *keys, default=None):
  """
  Safely retrieve nested dictionary values.
  :param d: The dictionary to retrieve the value from.
  :param keys: Keys for the nested dictionary.
  :param default: Default value if any key is missing or the value is None.
  :return: The value if found, otherwise the default.
  """
  for key in keys:
    if isinstance(d, dict):
      d = d.get(key, default)
    else:
      return default
  return d

def pull_zerion_positions(api_key: str, cover_id: int, address: str):
  # API call
  auth_str = f"{api_key}:"
  encoded_auth_str = base64.b64encode(auth_str.encode("utf-8")).decode("utf-8")
  headers = {
    "accept": "application/json",
    "authorization": f"Basic {encoded_auth_str}"
  }

  api_url_base = (
    f"https://api.zerion.io/v1/wallets/{address}/positions/"
    f"?filter[positions]=no_filter"
    f"&currency=usd"
    #f"&filter[chain_ids]=ethereum,binance-smart-chain,base,arbitrum,avalanche,polygon,optimism,xdai"
    f"&filter[trash]=only_non_trash"
    f"&sort=value"
  )

  response = requests.get(api_url_base, headers=headers)
  response.raise_for_status()
  json_data = response.json()
  #print(json.dumps(json_data, indent=4))

  # define key paths to extract from json
  key_paths = [
    ("chain_id", ["relationships", "chain", "data", "id"]),
    #("parent", ["attributes", "parent"]),
    ("app_id", ["relationships", "dapp", "data", "id"]),
    ("protocol", ["attributes", "protocol"]),
    ("name", ["attributes", "name"]),
    ("position_type", ["attributes", "position_type"]),
    ("quantity_int", ["attributes", "quantity", "int"]),
    ("quantity_decimals", ["attributes", "quantity", "decimals"]),
    ("quantity_float", ["attributes", "quantity", "float"]),
    ("quantity_numeric", ["attributes", "quantity", "numeric"]),
    ("value", ["attributes", "value"]),
    ("price", ["attributes", "price"]),
    ("changes_absolute_1d", ["attributes", "changes", "absolute_1d"]),
    ("changes_percent_1d", ["attributes", "changes", "percent_1d"]),
    ("fungible_info_name", ["attributes", "fungible_info", "name"]),
    ("fungible_info_symbol", ["attributes", "fungible_info", "symbol"]),
    ("fungible_info_icon_url", ["attributes", "fungible_info", "icon", "url"]),
    ("fungible_info_flags_verified", ["attributes", "fungible_info", "flags", "verified"]),
    ("app_metadata_name", ["attributes", "application_metadata", "name"]),
    ("app_metadata_icon_url", ["attributes", "application_metadata", "icon", "url"]),
    ("app_metadata_url", ["attributes", "application_metadata", "url"]),
    ("updated_at", ["attributes", "updated_at"]),
    ("updated_at_block", ["attributes", "updated_at_block"]),
  ]

  # build df using key paths
  df = pd.DataFrame([
    {
      "address": address,  # static column
      **{key: safe_get(item, *path) for key, path in key_paths}  # dynamically extracted columns
    }
    for item in safe_get(json_data, "data", default=[])
  ])

  if not df.empty:
    # rename index
    df.index.name = "id"

    # store results as csv
    #df.to_csv("./data/zerion_positions.csv")
    #print(df.columns.to_list())

    # check if table exists
    query = f"SELECT COUNT(*)::BOOLEAN AS cnt FROM duckdb_tables() WHERE table_name = 'zerion_positions'"
    table_exists = duckdb_con.execute(query).fetchone()[0]
    # prep main query
    query = f"SELECT {cover_id} as cover_id, *, current_timestamp AS inserted_at FROM df"

    if table_exists:
      # insert contents of df
      duckdb_con.execute(f"INSERT INTO zerion_positions {query}")
    else:
      # create table based on df + inserted_at column
      duckdb_con.execute(f"CREATE TABLE IF NOT EXISTS zerion_positions AS {query}")

def pull_zapper_positions(api_key: str, cover_id: int, address: str):
  # API call
  auth_str = f"{api_key}:"
  encoded_auth_str = base64.b64encode(auth_str.encode("utf-8")).decode("utf-8")
  headers = {
    "accept": "application/json",
    "authorization": f"Basic {encoded_auth_str}"
  }

  api_url_base = (
    f"https://api.zapper.xyz/v2/balances/apps?addresses%5B%5D={address}"
    #f"&networks%5B%5D=ethereum&networks%5B%5D=polygon&networks%5B%5D=optimism&networks%5B%5D=gnosis"
    #f"&networks%5B%5D=binance-smart-chain&networks%5B%5D=avalanche&networks%5B%5D=arbitrum&networks%5B%5D=base"
  )

  response = requests.get(api_url_base, headers=headers)
  response.raise_for_status()
  json_data = response.json()
  #print(json.dumps(json_data, indent=4))

  # define key paths to extract from json
  key_paths = [
    #("key", ["key"]),
    ("address", ["address"]),
    ("app_id", ["appId"]),
    ("app_name", ["appName"]),
    ("app_image_url", ["appImage"]),
    ("network", ["network"]),
    ("balance_usd", ["balanceUSD"]),
    ("product_label", ["label"], "product"),
    ("asset_type", ["type"], "asset"),
    ("asset_address", ["address"], "asset"),
    #("asset_key", ["key"], "asset"),
    ("token_meta_type", ["metaType"], "token"),
    ("token_symbol", ["symbol"], "token"),
    ("token_price", ["price"], "token"),
    ("token_balance", ["balance"], "token"),
    ("token_balance_usd", ["balanceUSD"], "token"),
    ("display_label", ["displayProps", "label"], "asset"),
    ("display_image", ["displayProps", "images"], "asset"),
    ("updated_at", ["updatedAt"]),
  ]

  # build df using key paths
  df = pd.DataFrame([
    {
      key: (
        safe_get(item, *path) if context == "item" else
        safe_get(product, *path) if context == "product" else
        safe_get(asset, *path) if context == "asset" else
        safe_get(token, *path)
      )
      for key, path, *context_list in key_paths
      for context in (context_list[0] if context_list else "item",)
    }
    for item in json_data
    for product in safe_get(item, "products", default=[])
    for asset in safe_get(product, "assets", default=[])
    for token in safe_get(asset, "tokens", default=[])
  ])

  if not df.empty:
    # rename index
    df.index.name = "id"

    # store results as csv
    #df.to_csv("./data/zapper_positions.csv")

    # check if table exists
    query = f"SELECT COUNT(*)::BOOLEAN AS cnt FROM duckdb_tables() WHERE table_name = 'zapper_positions'"
    table_exists = duckdb_con.execute(query).fetchone()[0]
    # prep main query
    query = f"SELECT {cover_id} as cover_id, *, current_timestamp AS inserted_at FROM df"

    if table_exists:
      # insert contents of df
      duckdb_con.execute(f"INSERT INTO zapper_positions {query}")
    else:
      # create table based on df + inserted_at column
      duckdb_con.execute(f"CREATE TABLE IF NOT EXISTS zapper_positions AS {query}")

def pull_cover_wallets():
  df = dune.run_query_dataframe(QueryBase(query_id=4340708))

  if not df.empty:
    # check if table exists
    query = f"SELECT COUNT(*)::BOOLEAN AS cnt FROM duckdb_tables() WHERE table_name = 'cover_wallets'"
    table_exists = duckdb_con.execute(query).fetchone()[0]
    # prep main query
    query = f"SELECT *, current_timestamp AS inserted_at FROM df"

    if table_exists:
      # flush & fill load
      clean_up_db(table_name="cover_wallets", truncate_table=True)
      # insert contents of df
      duckdb_con.execute(f"INSERT INTO cover_wallets {query}")
    else:
      # create table based on df + inserted_at column
      duckdb_con.execute(f"CREATE TABLE IF NOT EXISTS cover_wallets AS {query}")

def pull_capital_pool():
  df = dune.run_query_dataframe(QueryBase(query_id=4391959))

  if not df.empty:
    # check if table exists
    query = f"SELECT COUNT(*)::BOOLEAN AS cnt FROM duckdb_tables() WHERE table_name = 'capital_pool'"
    table_exists = duckdb_con.execute(query).fetchone()[0]
    # prep main query
    query = f"SELECT *, current_timestamp AS inserted_at FROM df"

    if table_exists:
      # flush & fill load
      clean_up_db(table_name="capital_pool", truncate_table=True)
      # insert contents of df
      duckdb_con.execute(f"INSERT INTO capital_pool {query}")
    else:
      # create table based on df + inserted_at column
      duckdb_con.execute(f"CREATE TABLE IF NOT EXISTS capital_pool AS {query}")

def loop_through_cover_wallets():
  address = "0xbad"
  current_api = ""

  try:
    # execute query and fetch results as df
    result_df = duckdb_con.execute("SELECT DISTINCT cover_id, monitored_wallet FROM cover_wallets").fetchdf()    
    for _, row in result_df.iterrows():
      cover_id = row["cover_id"]
      address = row["monitored_wallet"]
      current_api = "zerion"
      pull_zerion_positions(api_key=zerion_api_key, cover_id=cover_id, address=address)
      #current_api = "zapper"
      #pull_zapper_positions(api_key=zapper_api_key, cover_id=cover_id, address=address)

  except Exception as e:
    print(f"error for {current_api} and {address}: {e}")

############################################
# tests
#clean_up_db(table_name="zerion_positions", drop_table=True, truncate_table=False)
#pull_zerion_positions(api_key=zerion_api_key, cover_id=-1, address="0x036d6e8b88e21760f6759a31dabc8bdf3f026b98")
#clean_up_db(table_name="zapper_positions", drop_table=True, truncate_table=False)
#pull_zapper_positions(api_key=zapper_api_key, cover_id=-1, address="0x036d6e8b88e21760f6759a31dabc8bdf3f026b98")

clean_up_db(table_name="plan_mapping", drop_table=True, truncate_table=False)
duckdb_con.execute("CREATE TABLE plan_mapping AS FROM '../data/plan_mapping.csv'")

# refresh base Dune data (flush & fill)
#pull_capital_pool()
#pull_cover_wallets()

# load wallets data
#clean_up_db(table_name="zerion_positions", drop_table=False, truncate_table=True)
#clean_up_db(table_name="zapper_positions", drop_table=False, truncate_table=True)
#loop_through_cover_wallets()

#duckdb_con.execute("COPY debank_protocols TO 'debank_protocols.csv' (HEADER, DELIMITER ',');")

# close duckdb connection
duckdb_con.close()
