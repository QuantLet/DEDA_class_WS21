import pandas as pd
import matplotlib.pyplot as plt
from statsmodels.tsa.stattools import adfuller
from statsmodels.tsa.api import VAR
from statsmodels.stats.stattools import durbin_watson
from statsmodels.tools.eval_measures import rmse, aic
from statsmodels.tsa.stattools import grangercausalitytests
import numpy as np
from tabulate import tabulate

pd.set_option('display.max_columns', None)

# here we use the data that are stationary
indicators_death_infection = pd.read_csv('../Data/stationary_final_merged_data.csv', index_col = 0)
indicators_death_infection.index = pd.to_datetime(indicators_death_infection.index)

# different sets of column names for test

# all the data are stationary after first order difference
xy10 = ['close_BTC', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global']
xy20 = ['close_DASH', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global']
xy30 = ['close_ETH', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global']

# all the variables are stationary
xy40 = ['BTC_return', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy50 = ['DASH_return',  'topic_ratio', 'exposure_ratio', 'panic_index']
xy60 = ['ETH_return',  'topic_ratio', 'exposure_ratio', 'panic_index']

# all the data are stationry or stationary after first order difference
xy4 = ['BTC_return', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy5 = ['DASH_return', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']
xy6 = ['ETH_return', 'price_treasury', 'price_oil', 'price_S&P', 'price_gold', 'Daily_Death_Global', 'Daily_Infection_Global', 'topic_ratio', 'exposure_ratio', 'panic_index']


# VAR model
def var_model(df):
    mod = VAR(df)
    # estimate optimal lag for VAR
    lag_order = mod.select_order()
    print(lag_order.summary())

def var_residual(df, lags):
    var_mod = VAR(df)
    res = var_mod.fit(lags)
    print(res.summary())
    # durbin watson test，test the correlation in residuals. To ensure the model has explained the pattern in the time series.
    # The closer it is to the value 2, then there is no significant serial correlation.
    out = durbin_watson(res.resid)
    for col, val in zip(df.columns, out):
        print(col, ':', round(val, 2))

def grangers_causation_matrix(data, variables, test='ssr_chi2test', verbose=False):
    maxlag = 12
    df = pd.DataFrame(np.zeros((len(variables), len(variables))), columns=variables, index=variables)
    for c in df.columns:
        for r in df.index:
            test_result = grangercausalitytests(data[[r, c]], maxlag=maxlag, verbose=False)
            p_values = [round(test_result[i + 1][0][test][1], 4) for i in range(maxlag)]
            if verbose: print(f'Y = {r}, X = {c}, P Values = {p_values}')
            min_p_value = np.min(p_values)
            df.loc[r, c] = min_p_value
    df.columns = [var + '_x' for var in variables]
    df.index = [var + '_y' for var in variables]
    return df


# model 4
model4 = indicators_death_infection.loc[:, xy4]
var_model(model4)
var_residual(model4, 4)
print(tabulate(grangers_causation_matrix(model4, model4.columns), headers= model4.columns, tablefmt="rst"))

# model 5
model5 = indicators_death_infection.loc[:, xy5]
var_model(model5)
var_residual(model5, 4)
print(tabulate(grangers_causation_matrix(model5, model5.columns), headers= model5.columns, tablefmt="rst"))

# model 6
model6 = indicators_death_infection.loc[:, xy6]
var_model(model6)
var_residual(model6, 4)
print(tabulate(grangers_causation_matrix(model6, model6.columns), headers= model6.columns, tablefmt="rst"))