import os
import json
import base64
import requests
import pandas as pd
from dotenv import load_dotenv

# load .env file
load_dotenv()
api_key = os.getenv("API_KEY")
test_wallet = os.getenv("TEST_WALLET")

# API key only (no secret)
auth_str = f"{api_key}:"

# encode and create authorization header
encoded_auth_str = base64.b64encode(auth_str.encode("utf-8")).decode("utf-8")
headers = {
    "accept": "application/json",
    "authorization": f"Basic {encoded_auth_str}"
}

# API call
#api_url_base = f"https://api.zerion.io/v1/wallets/{test_wallet}/portfolio?currency=usd"

api_url_base = (
    f"https://api.zerion.io/v1/wallets/{test_wallet}/positions/"
    f"?filter[positions]=only_complex"
    f"&currency=usd"
    f"&filter[chain_ids]=ethereum"
    f"&filter[trash]=only_non_trash"
    f"&sort=value"
)

response = requests.get(api_url_base, headers=headers)

# convert response to JSON format
try:
  json_response = response.json()
  print(json.dumps(json_response, indent=4))
except ValueError:
  print("Response is not in JSON format")
