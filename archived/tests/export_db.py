import os
import duckdb
from dotenv import load_dotenv

"""
# connect to local db
con = duckdb.connect('./data/wallets.duckdb')

# export tables to parquet
con.execute("COPY _dlt_loads TO './data/parquet/_dlt_loads.parquet' (FORMAT 'parquet')")
con.execute("COPY _dlt_pipeline_state TO './data/parquet/_dlt_pipeline_state.parquet' (FORMAT 'parquet')")
con.execute("COPY _dlt_version TO './data/parquet/_dlt_version.parquet' (FORMAT 'parquet')")
con.execute("COPY capital_pool TO './data/parquet/capital_pool.parquet' (FORMAT 'parquet')")
con.execute("COPY cover_wallets TO './data/parquet/cover_wallets.parquet' (FORMAT 'parquet')")
con.execute("COPY debank_chains TO './data/parquet/debank_chains.parquet' (FORMAT 'parquet')")
con.execute("COPY debank_protocols TO './data/parquet/debank_protocols.parquet' (FORMAT 'parquet')")
con.execute("COPY debank_wallet_protocol_balance TO './data/parquet/debank_wallet_protocol_balance.parquet' (FORMAT 'parquet')")
con.execute("COPY plan_mapping TO './data/parquet/plan_mapping.parquet' (FORMAT 'parquet')")
"""

# connect to md db
load_dotenv()
md_token = os.getenv("MD_TOKEN")

con = duckdb.connect(f"md:?motherduck_token={md_token}")
con.execute("EXPORT DATABASE './archived/data/parquet' (FORMAT PARQUET);")
