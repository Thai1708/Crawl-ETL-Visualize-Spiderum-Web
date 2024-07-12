import pandas as pd
from sqlalchemy import create_engine

conn_string = 'postgresql://postgres:pthai332277@localhost/painting'
db = create_engine(conn_string)
conn = db.connect()

# df order by detail, info, comment table
df = pd.read_csv("data.csv")


df.to_sql("stg_spiderum_", con=conn, if_exists='append', index=False)