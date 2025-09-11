import dlt
from dlt.sources.rest_api import rest_api_source

debank_access_key = dlt.secrets["sources.debank.access_key"]

def load_chains():
  api_source = rest_api_source({
    "client": {
      "base_url": "https://pro-openapi.debank.com/",
      "headers": {
        "accept": "application/json",
        "AccessKey": debank_access_key
      },
      "paginator": "single_page",
    },
    "resources": [
      {
        "name": "debank_chains",
        "endpoint": {
          "path": "/v1/chain/list",
        },
        "write_disposition": "replace"
      }
    ]
  })

  pipeline = dlt.pipeline(
    pipeline_name="debank_chains",
    destination="motherduck",
    dataset_name="main"
  )

  load_info = pipeline.run(api_source)
  print(load_info)

def load_protocols():
  api_source = rest_api_source({
    "client": {
      "base_url": "https://pro-openapi.debank.com/",
      "headers": {
        "accept": "application/json",
        "AccessKey": debank_access_key
      },
      "paginator": "single_page",
    },
    "resources": [
      {
        "name": "debank_protocols",
        "endpoint": {
          "path": "/v1/protocol/all_list",
        },
        "write_disposition": "replace"
      }
    ]
  })

  pipeline = dlt.pipeline(
    pipeline_name="debank_protocols",
    destination="motherduck",
    dataset_name="main"
  )

  load_info = pipeline.run(api_source)
  print(load_info)

def load_user_all_simple_protocol_list(wallet: str):
  api_source = rest_api_source({
    "client": {
      "base_url": "https://pro-openapi.debank.com/",
      "headers": {
        "accept": "application/json",
        "AccessKey": debank_access_key
      },
      "paginator": "single_page",
    },
    "resources": [
      {
        "name": "debank_wallet_protocol_balance",
        "endpoint": {
          "path": "/v1/user/all_simple_protocol_list",
          "params": {"id": wallet},
        },
      }
    ]
  })

  pipeline = dlt.pipeline(
    pipeline_name="debank_wallet_protocol_balance_updated",
    destination="motherduck",
    dataset_name="main"
  )

  # transform data to include wallet as static column
  def transformed_data():
    for row in api_source.resources["debank_wallet_protocol_balance"]:
      yield {**row, "wallet": wallet}

  load_info = pipeline.run([
    dlt.resource(
      name="debank_wallet_protocol_balance", 
      write_disposition="append",
      table_name="debank_wallet_protocol_balance"
    )(transformed_data)
  ])
  print(load_info)

if __name__ == "__main__":
  load_chains()
  load_protocols()
  #load_user_all_simple_protocol_list(wallet="0x4fdb601aebf2c6ad947d97a00b7eeaf71cc5bf93") #test
