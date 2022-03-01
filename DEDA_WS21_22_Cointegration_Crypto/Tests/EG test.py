import pandas as pd
import matplotlib.pyplot as plt
import statsmodels.tsa.stattools as ts
import numpy as np


# we use the logged crypto price and the original data of the other variables.
# In this case, the original data of the return of crypto and all the media index are stationary.
# The logged crypto price, the macro index and the covid infection and death are all stationary after firtst order difference.
indicators_death_infection = pd.read_csv('../Data/log_crypto_merged_data.csv', index_col = 0)
indicators_death_infection.index = pd.to_datetime(indicators_death_infection.index)

# different sets of column names for test
crypto = ('close_BTC', 'close_DASH', 'close_ETH')
crypto_return = ('BTC_return', 'DASH_return', 'ETH_return')

# all the data are stationary after first order difference
xy10 = ['close_BTC', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global']
xy20 = ['close_DASH', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global']
xy30 = ['close_ETH', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global']

# all the variables are stationary
xy40 = ['BTC_return', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy50 = ['DASH_return',  'topic_ratio', 'exposure_ratio', 'panic_index']
xy60 = ['ETH_return',  'topic_ratio', 'exposure_ratio', 'panic_index']

# all the data are stationry or stationary after first order difference
xy1 = ['close_BTC', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy2 = ['close_DASH', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy3 = ['close_ETH', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy4 = ['BTC_return', 'price_treasury','price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy5 = ['DASH_return', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy6 = ['ETH_return', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']


model1 = indicators_death_infection.loc[:, xy1]
model2 = indicators_death_infection.loc[:, xy2]
model3 = indicators_death_infection.loc[:, xy3]
model4 = indicators_death_infection.loc[:, xy4]
model5 = indicators_death_infection.loc[:, xy5]
model6 = indicators_death_infection.loc[:, xy6]

# test cointegration of two time series
def show_coint(df):
    for i, col in enumerate(df.columns):
        result = ts.coint(df.iloc[:, 0], df.iloc[:, i])
        print('coint result for '+ df.columns[0] + ' and '+ col)
        coint_result = pd.DataFrame(result).iloc[0:2, 0]
        coint_result.index = ['t-stat', 'p-value']

        print( 't-stat', round(coint_result[0], 2), '\n', 'p-value', round(coint_result[1], 2))

        critical_value = [-3.91940197, -3.34888899, -3.05329764]
            # H0 is no coint, abs greater reject
        if abs(coint_result[0]) > abs(critical_value[0]):
            print('reject H0 at 1%, cointegration exists')
        if abs(coint_result[0]) > abs(critical_value[1]):
            print('reject H0 at 5%, cointegration exists')
        if abs(coint_result[0]) > abs(critical_value[2]):
            print('reject H0 at 10%, cointegration exists')
        print('\n', ' - -'*20)

# model1
print('\n', 'model 1')
show_coint(model1)

# model 2
print('\n', 'model 2')
show_coint(model2)

# model 3
print('\n', 'model 3')
show_coint(model3)

# model 4
print('\n', 'model 4')
show_coint(model4)

# model 5
print('\n', 'model 5')
show_coint(model5)

# model 6
print('\n', 'model 6')
show_coint(model6)

