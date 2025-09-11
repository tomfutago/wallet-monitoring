import os
from pathlib import Path
import duckdb
from dotenv import load_dotenv

# connect to md wallets db
load_dotenv()
md_token = os.getenv("MD_TOKEN")

con = duckdb.connect(f"md:wallets?motherduck_token={md_token}")

# output dir (only main schema)
out_dir = Path("./archived/data/parquet/wallets/main")
out_dir.mkdir(parents=True, exist_ok=True)

# list base tables in main
tables = [r[0] for r in con.execute("""
  select table_name
  from information_schema.tables
  where table_catalog='wallets' and table_schema='main' and table_type='BASE TABLE'
  order by 1
""").fetchall()]

def quote_ident(name: str) -> str:
  # double any existing quotes and wrap in double quotes
  return '"' + name.replace('"', '""') + '"'

# export each table as parquet
for t in tables:
  qname = quote_ident(t)
  outfile = out_dir / f"{t}.parquet"
  con.execute(f"copy main.{qname} to '{outfile.as_posix()}' (format parquet)")
