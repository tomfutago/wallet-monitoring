import dlt
from dlt.sources.rest_api import rest_api_source

duckdb_destination = "../data/wallets.duckdb"

def load_chains():
  api_source = rest_api_source({
    "client": {
      "base_url": "https://pro-openapi.debank.com/v1/chain/",
      "headers": {
        "accept": "application/json",
        "AccessKey": dlt.secrets["sources.debank.access_key"]
      },
      "paginator": "single_page",
    },
    "resource_defaults": {
      "write_disposition": "replace",
    },
    "resources": [
      {
        "name": "debank_chains",
        "endpoint": {
          "path": "list",
        },
      },
    ],
  })

  pipeline = dlt.pipeline(
    pipeline_name="debank_chains",
    destination=dlt.destinations.duckdb(duckdb_destination),
    dataset_name="main"
  )

  load_info = pipeline.run(api_source)
  print(load_info)

def load_protocols():
  api_source = rest_api_source({
    "client": {
      "base_url": "https://pro-openapi.debank.com/v1/",
      "headers": {
        "accept": "application/json",
        "AccessKey": dlt.secrets["sources.debank.access_key"]
      },
      "paginator": "single_page",
    },
    "resource_defaults": {
      "write_disposition": "replace",
    },
    "resources": [
      {
        "name": "debank_protocols",
        "endpoint": {
          "path": "protocol/all_list",
        },
      },
    ],
  })

  pipeline = dlt.pipeline(
    pipeline_name="debank_protocols",
    destination=dlt.destinations.duckdb(duckdb_destination),
    dataset_name="main"
  )

  load_info = pipeline.run(api_source)
  print(load_info)

if __name__ == "__main__":
  load_chains()
  load_protocols()
