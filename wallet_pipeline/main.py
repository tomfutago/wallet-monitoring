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
test_wallet = os.getenv("TEST_WALLET")

# create duckdb connection
duckdb_con = duckdb.connect("./data/wallets.duckdb")

def clean_up_db():
  # drop table and start again
  duckdb_con.execute("DROP TABLE zerion_positions")

  # drop table and start again
  duckdb_con.execute("DROP TABLE zapper_positions")

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

def pull_zerion_positions(api_key: str, address: str):
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
    f"&filter[chain_ids]=ethereum,binance-smart-chain,base,arbitrum,avalanche,polygon,optimism,xdai"
    f"&filter[trash]=only_non_trash"
    f"&sort=value"
  )

  response = requests.get(api_url_base, headers=headers)
  response.raise_for_status()
  json_data = response.json()
  #print(json.dumps(json_data, indent=4))

  # Define key paths to extract from JSON
  key_paths = [
    ("chain_id", ["relationships", "chain", "data", "id"]),
    ("parent", ["attributes", "parent"]),
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

  # build df
  df = pd.DataFrame([
    {
      "address": address,  # static column
      **{key: safe_get(item, *path) for key, path in key_paths}  # dynamically extracted columns
    }
    for item in safe_get(json_data, "data", default=[])
  ])

  # rename index
  df.index.name = "id"

  # store results as csv
  #df.to_csv("./data/zerion_positions.csv")

  # create empty table based on df + inserted_at column
  duckdb_con.execute("CREATE TABLE IF NOT EXISTS zerion_positions AS SELECT *, current_timestamp AS inserted_at FROM df WHERE 1=0")

  # insert contents of df
  duckdb_con.execute("INSERT INTO zerion_positions SELECT *, current_timestamp AS inserted_at FROM df")

def pull_zapper_positions(api_key):
  # API call
  auth_str = f"{api_key}:"
  encoded_auth_str = base64.b64encode(auth_str.encode("utf-8")).decode("utf-8")
  headers = {
    "accept": "application/json",
    "authorization": f"Basic {encoded_auth_str}"
  }

  api_url_base = (
    f"https://api.zapper.xyz/v2/balances/apps?addresses%5B%5D={address}"
    f"&networks%5B%5D=ethereum&networks%5B%5D=polygon&networks%5B%5D=optimism&networks%5B%5D=gnosis"
    f"&networks%5B%5D=binance-smart-chain&networks%5B%5D=avalanche&networks%5B%5D=arbitrum&networks%5B%5D=base"
  )

  response = requests.get(api_url_base, headers=headers)
  response.raise_for_status()
  json_data = response.json()
  #print(json.dumps(json_data, indent=4))

  # Define key paths
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

  # Build DataFrame using key_paths
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

  # rename index
  df.index.name = "id"

  # store results as csv
  #df.to_csv("./data/zapper_positions.csv")

  # create empty table based on df + inserted_at column
  duckdb_con.execute("CREATE TABLE IF NOT EXISTS zapper_positions AS SELECT *, current_timestamp AS inserted_at FROM df WHERE 1=0")

  # insert contents of df
  duckdb_con.execute("INSERT INTO zapper_positions SELECT *, current_timestamp AS inserted_at FROM df")

def pull_cover_wallets():
  df = dune.run_query_dataframe(QueryBase(query_id=4340708))

  # create empty table based on df + inserted_at column
  duckdb_con.execute("CREATE TABLE IF NOT EXISTS cover_wallets AS SELECT *, current_timestamp AS inserted_at FROM df WHERE 1=0")

  # insert contents of df
  duckdb_con.execute("INSERT INTO cover_wallets SELECT *, current_timestamp AS inserted_at FROM df")

############################################
#clean_up_db()
#pull_zerion_positions(zerion_api_key, test_wallet)
#pull_zapper_positions(zapper_api_key, test_wallet)

pull_cover_wallets()

# close duckdb connection
duckdb_con.close()
