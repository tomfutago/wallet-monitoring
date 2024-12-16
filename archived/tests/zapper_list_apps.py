import os
import json
import base64
import requests
import pandas as pd
import csv
from dotenv import load_dotenv

# load .env file
load_dotenv()
api_key = os.getenv("ZAPPER_API_KEY")
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
api_url_base = f"https://api.zapper.xyz/v2/apps"
response = requests.get(api_url_base, headers=headers)
response.raise_for_status()
json_data = response.json()

#output_file = "./data/zapper_apps.json"
#with open(output_file, "w") as file:
#  json.dump(json_data, file, indent=4)

# Extract data according to requirements
csv_data = []
for item in json_data:
    csv_row = {
        "id": item["id"],
        "slug": item["slug"],
        "name": item["name"],
        "url": item["url"],
        "tags": ", ".join(item.get("tags", [])),
        "supportedNetworks": ", ".join(network["network"] for network in item.get("supportedNetworks", []))
    }
    csv_data.append(csv_row)

# Define CSV headers
headers = ["id", "slug", "name", "url", "tags", "supportedNetworks"]

# Write to CSV
with open("./data/zapper_apps.csv", "w", newline="", encoding="utf-8") as csv_file:
    writer = csv.DictWriter(csv_file, fieldnames=headers)
    writer.writeheader()
    writer.writerows(csv_data)

print("CSV file has been created successfully.")
