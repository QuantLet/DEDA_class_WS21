from databaseReader import DatabaseReader
from analyzer import Analyzer
import matplotlib.pyplot as plt


api = DatabaseReader()
analyzer = Analyzer(api)

holding_distr = [x[0] for x in analyzer.estimate_holding_distribution(10000)]


fig = plt.figure()
ax = fig.add_subplot()
ax.hist(holding_distr, bins=100)
ax.set_title('Estimate of holding time distribution')
ax.set_xlabel('Holding time in hours')
ax.set_ylabel('Number of spent inputs')
plt.show()
fig.savefig('holding_estimate.png', transparent=True)
