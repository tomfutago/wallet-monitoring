import dlt
import requests
from dlt.sources.rest_api import rest_api_source

duckdb_destination = "../data/wallets.duckdb"

@dlt.resource(name="debank_chains", write_disposition="replace")
def fetch_chains():
  client = {
    "base_url": "https://pro-openapi.debank.com/",
    "headers": {
      "accept": "application/json",
      "AccessKey": dlt.secrets["sources.debank.access_key"]
    }
  }
  endpoint = "v1/chain/list"
  
  response = requests.get(client["base_url"] + endpoint, headers=client["headers"])
  response.raise_for_status()
  for item in response.json():
    yield item

@dlt.resource(name="debank_protocols", write_disposition="replace")
def fetch_protocols():
  client = {
    "base_url": "https://pro-openapi.debank.com/",
    "headers": {
      "accept": "application/json",
      "AccessKey": dlt.secrets["sources.debank.access_key"]
    }
  }
  endpoint = "v1/protocol/all_list"
  
  response = requests.get(client["base_url"] + endpoint, headers=client["headers"])
  response.raise_for_status()
  for item in response.json():
    yield item

@dlt.resource(name="debank_wallet_protocol_balance", write_disposition="replace")
def fetch_wallet_data(wallet: str):
  client = {
    "base_url": "https://pro-openapi.debank.com/",
    "headers": {
      "accept": "application/json",
      "AccessKey": dlt.secrets["sources.debank.access_key"]
    }
  }
  endpoint = f"/v1/user/all_simple_protocol_list?id={wallet}"
  
  response = requests.get(client["base_url"] + endpoint, headers=client["headers"])
  response.raise_for_status()
  for item in response.json():
    yield {**item, "wallet": wallet}

def load_chains():
  pipeline = dlt.pipeline(
    pipeline_name="debank_chains",
    destination=dlt.destinations.duckdb(duckdb_destination),
    dataset_name="main"
  )

  load_info = pipeline.run(fetch_chains())
  print(load_info)

def load_protocols():
  pipeline = dlt.pipeline(
    pipeline_name="debank_protocols",
    destination=dlt.destinations.duckdb(duckdb_destination),
    dataset_name="main"
  )

  load_info = pipeline.run(fetch_protocols())
  print(load_info)

def load_user_all_simple_protocol_list(wallet: str):
  pipeline = dlt.pipeline(
    pipeline_name="debank_wallet_protocol_balance",
    destination=dlt.destinations.duckdb(duckdb_destination),
    dataset_name="main"
  )

  load_info = pipeline.run(fetch_wallet_data(wallet))
  print(load_info)

if __name__ == "__main__":
  #load_chains()
  #load_protocols()
  load_user_all_simple_protocol_list(wallet="0x4fdb601aebf2c6ad947d97a00b7eeaf71cc5bf93")
