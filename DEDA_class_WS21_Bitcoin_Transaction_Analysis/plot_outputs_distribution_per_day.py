from analyzer import Analyzer
import matplotlib.pyplot as plt
import numpy as np
from databaseReader import DatabaseReader
import matplotlib.animation as animation

api = DatabaseReader()
analyzer = Analyzer(api)


distributions = analyzer.get_value_distribution_per_day(month_filter=9)

HIST_BINS = np.linspace(-8, 6, 1000)


def prepare_animation(bar_container):

    def animate(frame_number):
        # simulate new data coming in
        data = np.log10(np.array(distributions[frame_number]))-8
        n, _ = np.histogram(data, HIST_BINS, density=True)
        for count, rect in zip(n, bar_container.patches):
            rect.set_height(count)
        return bar_container.patches
    return animate


fig, ax = plt.subplots()
fig.patch.set_alpha(0.)
ax.set_title('Frequency density of output values for each day in September 2021')
ax.set_xlabel('$\log_{10}$ of the output values')
ax.set_ylabel('Frequency density')
_, _, bar_container = ax.hist(np.log10(np.array(distributions[0])), HIST_BINS, lw=1,
                              ec="red", fc="red", alpha=0.5)
ax.set_ylim(top=2)

ani = animation.FuncAnimation(fig, prepare_animation(bar_container), len(distributions),
                              repeat=True, blit=True)

ani.save('output_distr_per_day.gif', codec="png",
         dpi=1000, bitrate=-1,
         savefig_kwargs={'transparent': True, 'facecolor': 'none'})

plt.show()

