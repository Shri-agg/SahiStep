import os
from databases import Database

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:%40Radhekrishna@localhost:5432/police_rights_navigator",
)

# Single shared async connection pool for the whole app.
# Imported wherever a query needs to run.
database = Database(DATABASE_URL)


async def connect_db():
    await database.connect()


async def disconnect_db():
    await database.disconnect()
