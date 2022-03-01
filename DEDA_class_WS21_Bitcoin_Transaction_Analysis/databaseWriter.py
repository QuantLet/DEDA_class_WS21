import mysql.connector
from transaction_objects import Transaction
from login_data import LOGIN_DATA


# TABLES = ['blocks', 'transactions', 'outputs', 'inputs']
TABLES = {'blocks':         ['block_id BINARY(32) PRIMARY KEY',
                            'n_transactions SMALLINT UNSIGNED NOT NULL',
                            'timestamp DATETIME NOT NULL'],

          'transactions':   ['tx_id BINARY(32) PRIMARY KEY',
                             'block_id BINARY(32) NOT NULL',
                             'n_inputs SMALLINT UNSIGNED NOT NULL',
                             'n_outputs SMALLINT UNSIGNED NOT NULL'],

          'inputs':         ['tx_from_id BINARY(32) NOT NULL',
                             'tx_to_id BINARY(32) NOT NULL',
                             'output_no SMALLINT UNSIGNED NOT NULL',
                             'PRIMARY KEY (tx_from_id, output_no)'],

          'outputs':        ['tx_from_id BINARY(32) NOT NULL',
                             'output_no SMALLINT UNSIGNED NOT NULL',
                             'wallet_id VARCHAR(46) NOT NULL',
                             'value BIGINT UNSIGNED NOT NULL',
                             'PRIMARY KEY (tx_from_id, output_no)']}

VIEWS = {'inputs_connected': 'CREATE OR REPLACE VIEW inputs_connected AS '
                             'SELECT tx_from_id, tx_to_id, wallet_id, value FROM inputs LEFT JOIN outputs USING(tx_from_id, output_no)',
         'outputs_connected': 'CREATE OR REPLACE VIEW outputs_connected AS '
                             'SELECT tx_from_id, tx_to_id, wallet_id, value FROM inputs RIGHT JOIN outputs USING(tx_from_id, output_no)'}


class DatabaseWriter:

    def __init__(self):
        self.db = mysql.connector.connect(**LOGIN_DATA)
        self.cursor = self.db.cursor()

    def create_tables(self):

        for table_name, table_attributes in TABLES.items():
            attributes_str = ', '.join(table_attributes)
            self.cursor.execute(f'CREATE TABLE IF NOT EXISTS {table_name} ({attributes_str})')

        self.db.commit()

    def create_views(self):

        for view_name, view_query in VIEWS.items():
            self.cursor.execute(view_query)

        self.db.commit()

    def reset_database(self):
        confirmation = input("Are you sure that you want to reset the database? \n"
                             "This will delete everything. (Y/n)")
        if confirmation == "Y":
            self.drop_tables()
            self.create_tables()
            self.create_views()
            print("Database reset complete")
        else:
            print("Database reset aborted")

    def drop_tables(self):
        for t in TABLES.keys():
            self.cursor.execute('DROP TABLE IF EXISTS {}'.format(t))

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

    def add_block(self, block):
        self.cursor.execute(f'''
                                INSERT IGNORE INTO blocks (block_id, n_transactions, timestamp) VALUES
                                (UNHEX('{block.hash}'), {block.n_transactions}, '{str(block.header.timestamp)}')''')

        txs_dict = {'tx_id': [], 'block_id': [], 'n_inputs': [], 'n_outputs': []}
        inputs_dict = {'tx_to_id': [], 'tx_from_id': [], 'output_no': []}
        outputs_dict = {'tx_from_id': [], 'output_no': [], 'wallet_id': [], 'value': []}

        for parser_tx in block.transactions:
            tx = Transaction(parser_tx)

            if tx.is_standard:
                txs_dict['tx_id'].append(tx.id)
                txs_dict['block_id'].append(block.hash)
                txs_dict['n_inputs'].append(tx.n_inputs)
                txs_dict['n_outputs'].append(tx.n_outputs)

                for input_ in tx.inputs:
                    inputs_dict['tx_from_id'].append(input_.tx_from_id)
                    inputs_dict['tx_to_id'].append(input_.tx_to_id)
                    inputs_dict['output_no'].append(input_.output_no)

                for output in tx.outputs:
                    outputs_dict['tx_from_id'].append(output.tx_from_id)
                    outputs_dict['output_no'].append(output.output_no)
                    outputs_dict['wallet_id'].append(output.wallet_id)
                    outputs_dict['value'].append(output.value)

        txs_query_str = '''INSERT IGNORE INTO transactions (tx_id, block_id, n_inputs, n_outputs) VALUES
                        (UNHEX(%s), UNHEX(%s), %s, %s)'''
        txs_data = list(zip(txs_dict['tx_id'], txs_dict['block_id'], txs_dict['n_inputs'], txs_dict['n_outputs']))
        self.cursor.executemany(txs_query_str, txs_data)

        inputs_query_str = '''INSERT IGNORE INTO inputs (tx_from_id, tx_to_id, output_no) VALUES
                            (UNHEX(%s), UNHEX(%s), %s)'''
        inputs_data = list(zip(inputs_dict['tx_from_id'], inputs_dict['tx_to_id'], inputs_dict['output_no']))
        self.cursor.executemany(inputs_query_str, inputs_data)

        outputs_query_str = '''INSERT IGNORE INTO outputs (tx_from_id, output_no, wallet_id, value) VALUES
                        (UNHEX(%s), %s, %s, %s)'''
        outputs_data = list(zip(outputs_dict['tx_from_id'], outputs_dict['output_no'], outputs_dict['wallet_id'], outputs_dict['value']))
        self.cursor.executemany(outputs_query_str, outputs_data)

        self.db.commit()

    def add_transaction(self, parser_tx, block_hash):
        tx = Transaction(parser_tx)

        if not tx.is_standard:
            return

        self.cursor.execute(f'''
                        INSERT IGNORE INTO transactions (tx_id, block_id, n_inputs, n_outputs) VALUES
                        (UNHEX('{tx.id}'), UNHEX('{block_hash}'), {tx.n_inputs}, {tx.n_outputs})''')

        for input_ in tx.inputs:
            self.cursor.execute(f'''
                        INSERT IGNORE INTO inputs (tx_to_id, tx_from_id, tx_output_no) VALUES
                        (0x{input_.tx_id}, 0x{input_.tx_from}, {input_.tx_output_no})''')

        for output in tx.outputs:
            self.cursor.execute(f'''
                        INSERT IGNORE INTO outputs (tx_from_id, tx_output_no, wallet, value) VALUES
                        (UNHEX('{output.tx_id}'), {output.output_no}, '{output.wallet}', {output.value})''')

        self.db.commit()



# SELECT i.wallet_id AS ip, o.wallet_id AS op, i.value AS ipv, o.value AS opv FROM (SELECT * FROM outputs_connected ORDER BY value DESC LIMIT 5) AS o INNER JOIN transactions AS t ON o.tx_from_id=t.tx_id INNER JOIN inputs_connected AS i ON t.tx_id=i.tx_to_id;