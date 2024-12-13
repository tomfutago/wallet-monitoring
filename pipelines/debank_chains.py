import dlt
from dlt.sources.rest_api import rest_api_source

api_source = rest_api_source({
    "client": {
        "base_url": "https://pro-openapi.debank.com/v1/chain/",
        "headers": {
            "accept": "application/json",
            "AccessKey": dlt.secrets["sources.debank.access_key"]
        }
    },
    "resources": ["list"]
})

pipeline = dlt.pipeline(
    pipeline_name="debank_chains",
    destination=dlt.destinations.duckdb("../data/wallets.duckdb"),
    dataset_name="debank_chains"
)

load_info = pipeline.run(api_source)
print(load_info)
