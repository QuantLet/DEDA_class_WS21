import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from statsmodels.tsa.api import VAR

# read the processed data which still contain non-stationarity
# here we perform the VAR to get the optimal lags for the following Johansen Test
indicators_death_infection = pd.read_csv('../Data/final_merged_data.csv', index_col = 0)
indicators_death_infection.index = pd.to_datetime(indicators_death_infection.index)

# determine the models, using the same x_variables but different y_variables
xy1 = ['close_BTC', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy2 = ['close_DASH', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy3 = ['close_ETH', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy4 = ['BTC_return', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy5 = ['DASH_return', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy6 = ['ETH_return', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']

# conduct the respective dataframe
model1 = indicators_death_infection.loc[:, xy1]
model2 = indicators_death_infection.loc[:, xy2]
model3 = indicators_death_infection.loc[:, xy3]
model4 = indicators_death_infection.loc[:, xy4]
model5 = indicators_death_infection.loc[:, xy5]
model6 = indicators_death_infection.loc[:, xy6]

# define a function to run VAR and display the result
def get_opt_lags (df):

    var_model = VAR(df)
    order = var_model.select_order()
    print(order.summary())

# all models with opt lag 5 for the johansen test
get_opt_lags(model1)
get_opt_lags(model2)
get_opt_lags(model3)
get_opt_lags(model4)
get_opt_lags(model5)
get_opt_lags(model6)


