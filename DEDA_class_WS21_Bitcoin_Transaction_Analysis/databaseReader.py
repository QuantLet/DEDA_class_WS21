import mysql.connector
from login_data import LOGIN_DATA

JOIN_COLUMNS = {repr(['blocks', 'transactions']): [['block_id', 'block_id']],
                repr(['inputs', 'transactions']): [['tx_to_id', 'tx_id']],
                repr(['outputs', 'transactions']): [['tx_from_id', 'tx_id']],
                repr(['inputs', 'outputs']): [2*['tx_from_id'], 2*['output_no']]}


class DatabaseReader:

    def __init__(self):
        self.db = mysql.connector.connect(**LOGIN_DATA)
        self.cursor = self.db.cursor()

    def get_query_generator(self, q):
        self.cursor.execute(q)

        for row in self.cursor.fetchall():
            yield row

    def get_query_list(self, q):
        self.cursor.execute(q)

        return self.cursor.fetchall()

    def join_tables(self, tables: list):
        join_str = tables[0]
        for i in range(len(tables)-1):
            to_connect = tables[i:i+2]
            order = sorted(range(len(to_connect)), key=lambda k: to_connect[k])
            to_connect = [to_connect[o] for o in order]
            join_cols = JOIN_COLUMNS[repr(to_connect)]
            join_str += f' INNER JOIN {tables[i+1]} ON {tables[i]}.{join_cols[0][order[0]]} = {tables[i+1]}.{join_cols[0][order[1]]}'
            if len(join_cols) == 2:
                join_str += f' AND {tables[i]}.{join_cols[1][order[0]]} = {tables[i+1]}.{join_cols[1][order[1]]}'

        return join_str

    def get_dates(self):

        return self.get_query_list('SELECT DISTINCT YEAR(timestamp), MONTH(timestamp), DAY(timestamp) FROM blocks ORDER BY timestamp;')

# SELECT i.wallet_id AS ip, o.wallet_id AS op, i.value AS ipv, o.value AS opv FROM (SELECT * FROM outputs_connected ORDER BY value DESC LIMIT 5) AS o INNER JOIN transactions AS t ON o.tx_from_id=t.tx_id INNER JOIN inputs_connected AS i ON t.tx_id=i.tx_to_id;