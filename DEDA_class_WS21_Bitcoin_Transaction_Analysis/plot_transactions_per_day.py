from databaseReader import DatabaseReader
from analyzer import Analyzer
import matplotlib.pyplot as plt
import numpy as np

api = DatabaseReader()
analyzer = Analyzer(api)

txs_by_day = list(analyzer.get_transactions_by_day())


dates = [str(x[1])+'-'+str(x[2]) for x in txs_by_day][1:-1]
n_tx = [int(x[3]) for x in txs_by_day][1:-1]

x = np.arange(len(dates))

fig = plt.figure()
ax = fig.add_subplot()
ax.plot(x, n_tx)
plt.xticks(x, dates, rotation='vertical')
ax.set_title('Number of transactions per day in a short period of 2021')
ax.set_xlabel('Date in 2021 (Month-Day)')
ax.set_ylabel('Number of transactions per day')
plt.show()
fig.savefig('transactions_per_day.png', transparent=True)
