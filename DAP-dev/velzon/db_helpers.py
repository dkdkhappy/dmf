import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

PORT = 5432
ENDPOINT = 'derma-dap-db.cuwldr2bamdp.ap-northeast-2.rds.amazonaws.com'
USER = 'postgres'


class Databases():
    def __init__(self):
        self.db = psycopg2.connect(host=ENDPOINT, user='postgres', dbname='postgres',
                                   password='dapderma0220', port=PORT)
        self.db.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        self.cursor = self.db.cursor()

    def __del__(self):
        self.db.close()
        self.cursor.close()

    def execute(self, query, args={}):
        self.cursor.execute(query, args)
        row = self.cursor.fetchall()
        return row

    def commit(self):
        self.cursor.commit()
