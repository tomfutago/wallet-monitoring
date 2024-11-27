import os
import json
import base64
import requests
import pandas as pd
import duckdb
from dotenv import load_dotenv

# load .env file
load_dotenv()
zerion_api_key = os.getenv("ZERION_API_KEY")
zapper_api_key = os.getenv("ZAPPER_API_KEY")
test_wallet = os.getenv("TEST_WALLET")

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

def pull_zerion_positions(api_key):
  # API call
  auth_str = f"{api_key}:"
  encoded_auth_str = base64.b64encode(auth_str.encode("utf-8")).decode("utf-8")
  headers = {
      "accept": "application/json",
      "authorization": f"Basic {encoded_auth_str}"
  }

  api_url_base = (
      f"https://api.zerion.io/v1/wallets/{test_wallet}/positions/"
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

  # flatten JSON response to df
  df = pd.DataFrame([
      {
          "parent": safe_get(item, "attributes", "parent"),
          "protocol": safe_get(item, "attributes", "protocol"),
          "name": safe_get(item, "attributes", "name"),
          "position_type": safe_get(item, "attributes", "position_type"),
          "quantity_int": safe_get(item, "attributes", "quantity", "int"),
          "quantity_decimals": safe_get(item, "attributes", "quantity", "decimals"),
          "quantity_float": safe_get(item, "attributes", "quantity", "float"),
          "quantity_numeric": safe_get(item, "attributes", "quantity", "numeric"),
          "value": safe_get(item, "attributes", "value"),
          "price": safe_get(item, "attributes", "price"),
          "changes_absolute_1d": safe_get(item, "attributes", "changes", "absolute_1d"),
          "changes_percent_1d": safe_get(item, "attributes", "changes", "percent_1d"),
          "fungible_info_name": safe_get(item, "attributes", "fungible_info", "name"),
          "fungible_info_symbol": safe_get(item, "attributes", "fungible_info", "symbol"),
          "fungible_info_icon_url": safe_get(item, "attributes", "fungible_info", "icon", "url"),
          "fungible_info_flags_verified": safe_get(item, "attributes", "fungible_info", "flags", "verified"),
          #"fungible_info_implementations": safe_get(item, "attributes", "fungible_info", "implementations"),
          #"flags_displayable": safe_get(item, "attributes", "flags", "displayable"),
          #"flags_is_trash": safe_get(item, "attributes", "flags", "is_trash"),
          "app_metadata_name": safe_get(item, "attributes", "application_metadata", "name"),
          "app_metadata_icon_url": safe_get(item, "attributes", "application_metadata", "icon", "url"),
          "app_metadata_url": safe_get(item, "attributes", "application_metadata", "url"),
          "updated_at": safe_get(item, "attributes", "updated_at"),
          "updated_at_block": safe_get(item, "attributes", "updated_at_block"),
      }
      for item in safe_get(json_data, "data", default=[])
  ])

  # rename index
  df.index.name = "id"

  # store results as csv
  df.to_csv("./data/zerion_positions.csv")

############################################
pull_zerion_positions(zerion_api_key)
