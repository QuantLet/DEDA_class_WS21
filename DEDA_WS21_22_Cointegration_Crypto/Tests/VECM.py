import pandas as pd
import numpy as np
from statsmodels.tsa.api import VAR
import matplotlib.pyplot as plt
from statsmodels.tsa.vector_ar import vecm
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

def vecm_impulse(model, rank):
    mod = vecm.VECM(model, k_ar_diff = 4, coint_rank = rank, deterministic = 'ci')
    res = mod.fit()
    ir = res.irf(periods = 30)
    ir.plot(plot_stderr=False, figsize=(40, 40))

vecm_impulse(model1, 3)
plt.savefig('BTC_price_impulse')
vecm_impulse(model2, 3)
plt.savefig('DASH_price_impulse')
vecm_impulse(model3, 4)
plt.savefig('ETH_price_impulse')
vecm_impulse(model4, 4)
plt.savefig('BTC_retrun_impulse')
vecm_impulse(model5, 4)
plt.savefig('DASH_retrun_impulse')
vecm_impulse(model6, 3)
plt.savefig('ETH_retrun_impulse')
