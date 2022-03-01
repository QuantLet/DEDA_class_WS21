import pandas as pd
import numpy as np
from statsmodels.tsa.api import VAR
import matplotlib.pyplot as plt
from statsmodels.tsa.vector_ar import vecm
from matplotlib.backends.backend_pdf import PdfPages
# read the original data for the VECM
indicators_death_infection = pd.read_csv('../Data/final_merged_data.csv', index_col = 0)
indicators_death_infection.index = pd.to_datetime(indicators_death_infection.index)

# different sets of column names for test
xy1 = ['close_BTC', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy2 = ['close_DASH', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy3 = ['close_ETH', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy4 = ['BTC_return', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy5 = ['DASH_return', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy6 = ['ETH_return', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']


model1 = indicators_death_infection.loc[:, xy1]
model2 = indicators_death_infection.loc[:, xy2]
model3 = indicators_death_infection.loc[:, xy3]
model4 = indicators_death_infection.loc[:, xy4]
model5 = indicators_death_infection.loc[:, xy5]
model6 = indicators_death_infection.loc[:, xy6]

# run the VECM with the rank chosen by Johansen test and show the impulse response
def save_multi_image(filename):
   pp = PdfPages(filename)
   fig_nums = plt.get_fignums()
   figs = [plt.figure(n) for n in fig_nums]
   for fig in figs:
      fig.savefig(pp, format='pdf')
   pp.close()

save_multi_image('../impulse_response_plot')

def vecm_impulse(model, rank):
    mod = vecm.VECM(model, k_ar_diff = 4, coint_rank = rank, deterministic = 'ci')
    res = mod.fit()
    ir = res.irf(periods = 30)
    ir.plot(plot_stderr=False, figsize=(40, 40))
    save_multi_image('../impulse_response_plot')

vecm_impulse(model1, 3)
vecm_impulse(model2, 3)
vecm_impulse(model3, 4)
vecm_impulse(model4, 4)
vecm_impulse(model5, 4)
vecm_impulse(model6, 3)

def save_multi_image(filename):
   pp = PdfPages(filename)
   fig_nums = plt.get_fignums()
   figs = [plt.figure(n) for n in fig_nums]
   for fig in figs:
      fig.savefig(pp, format='pdf')
   pp.close()

save_multi_image('../impulse_response_plot')