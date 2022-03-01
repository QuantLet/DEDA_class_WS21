from databaseReader import DatabaseReader
from analyzer import Analyzer
import matplotlib.pyplot as plt
import numpy as np

api = DatabaseReader()
analyzer = Analyzer(api)

vol_by_day = list(analyzer.get_volume_by_day())


dates = [str(x[1])+'-'+str(x[2]) for x in vol_by_day][1:-1]
vols = [np.log10(int(x[3])-8) for x in vol_by_day][1:-1]

x = np.arange(len(dates))

fig = plt.figure()
ax = fig.add_subplot()
ax.plot(x, vols)
plt.xticks(x, dates, rotation='vertical')
ax.set_title('Output volume per day in a short period of 2021')
ax.set_xlabel('Date in 2021 (Month-Day)')
ax.set_ylabel('$\log_{10}$ of the volume per day in BTC')
plt.show()
fig.savefig('volume_per_day.png', transparent=True)
