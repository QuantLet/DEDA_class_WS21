from databaseReader import DatabaseReader


class Analyzer:

    def __init__(self, db: DatabaseReader):
        self.db = db
        self.cursor = db.cursor

    def get_transactions_by_day(self):
        return self.db.get_query_generator(
            f'''SELECT YEAR(timestamp), MONTH(timestamp), DAY(timestamp), SUM(n_transactions) FROM blocks 
        GROUP BY YEAR(timestamp), MONTH(timestamp), DAY(timestamp) ORDER BY MONTH(timestamp), DAY(timestamp)''')

    def get_volume_by_day(self):
        return self.db.get_query_generator(
            f'''SELECT YEAR(timestamp), MONTH(timestamp), DAY(timestamp), SUM(value) FROM
        {self.db.join_tables(['blocks', 'transactions', 'outputs'])}
        GROUP BY YEAR(timestamp), MONTH(timestamp), DAY(timestamp) ORDER BY MONTH(timestamp), DAY(timestamp)''')

    def get_values(self):
        return self.db.get_query_generator(
            '''SELECT value FROM outputs ORDER BY RAND() LIMIT 10000'''
        )

    def get_volume_per_transaction(self):
        return self.db.get_query_generator(
            f'''SELECT SUM(value) FROM outputs GROUP BY tx_from_id'''
        )

    def get_tx_volume_day(self):
        pass

    def get_highest_output_per_day(self):
        return self.db.get_query_generator(
            f'''SELECT MAX(value) FROM {self.db.join_tables(['outputs', 'transactions', 'blocks'])}
            GROUP BY MONTH(timestamp), DAY(timestamp) ORDER BY MONTH(timestamp), DAY(timestamp)'''
        )

    def get_value_distribution_per_day(self, month_filter=None):

        all_values = []
        dates = self.db.get_dates()

        if isinstance(month_filter, int):
            dates = [date for date in dates if date[1] == month_filter]

        for date in dates:
            all_values.append(
               [x[0] for x in self.db.get_query_list(f'''SELECT value from {self.db.join_tables(['outputs', 'transactions', 'blocks'])}
                WHERE YEAR(timestamp)={date[0]} AND MONTH(timestamp)={date[1]} AND DAY(timestamp)={date[2]}''')]
            )

        return all_values

    def estimate_holding_distribution(self, sample_size, random_seed=42):
        return self.db.get_query_list(
            f'''SELECT TIMESTAMPDIFF(HOUR, b1.timestamp, b2.timestamp) FROM
            blocks AS b1 INNER JOIN transactions as t1 USING(block_id)
            INNER JOIN
            (SELECT * FROM inputs AS i INNER JOIN outputs AS o USING(tx_from_id, output_no)
            ORDER BY RAND({random_seed}) LIMIT {sample_size}) AS io
            ON t1.tx_id=io.tx_from_id
            INNER JOIN transactions AS t2 ON io.tx_to_id=t2.tx_id
            INNER JOIN blocks AS b2 ON t2.block_id=b2.block_id'''
        )
