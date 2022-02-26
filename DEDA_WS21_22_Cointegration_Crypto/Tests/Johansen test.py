import pandas as pd
import numpy as np
from statsmodels.tsa.api import VAR
from statsmodels.tsa.vector_ar import vecm

# we read the original data to run the Johansen test
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

# optimal 5 lags chosen using VAR
model1_jh = vecm.coint_johansen(model1, det_order=0, k_ar_diff=4)
model2_jh = vecm.coint_johansen(model2, det_order=0, k_ar_diff=4)
model3_jh = vecm.coint_johansen(model3, det_order=0, k_ar_diff=4)
model4_jh = vecm.coint_johansen(model4, det_order=0, k_ar_diff=4)
model5_jh = vecm.coint_johansen(model5, det_order=0, k_ar_diff=4)
model6_jh = vecm.coint_johansen(model6, det_order=0, k_ar_diff=4)

# model 1
print('model 1')
rank1 = vecm.select_coint_rank(model1,det_order=0, k_ar_diff=4, signif=0.01)
print(rank1)

# model 2
print('model 2')
rank2 = vecm.select_coint_rank(model2,det_order=0, k_ar_diff=4, signif=0.01)
print(rank2)

# model 3
print('model 3')
rank3 = vecm.select_coint_rank(model3,det_order=0, k_ar_diff=4, signif=0.01)
print(rank3)

# model 4
print('model 4')
rank4 = vecm.select_coint_rank(model4,det_order=0, k_ar_diff=4, signif=0.01)
print(rank4)

# model 5
print('model 5')
rank5 = vecm.select_coint_rank(model5,det_order=0, k_ar_diff=4, signif=0.01)
print(rank5)

# model 6
print('model 6')
rank6 = vecm.select_coint_rank(model1,det_order=0, k_ar_diff=4, signif=0.01)
print(rank6)


