import pandas as pd
import statsmodels as stam
import matplotlib.pyplot as plt
import numpy as np
from statsmodels.tsa.stattools import adfuller
from matplotlib.backends.backend_pdf import PdfPages


indicators_death_infection = pd.read_csv('../Data/final_merged_data.csv', index_col = 0)
indicators_death_infection.index = pd.to_datetime(indicators_death_infection.index)

# different sets of column names for test
crypto = ('close_BTC', 'close_DASH', 'close_ETH')
crypto_return = ('BTC_return', 'DASH_return', 'ETH_return')
macro = ('price_treasury', 'price_oil', 'price_S&P', 'price_gold')
death_infection = ('Daily_Death_Global', 'Daily_Infection_Global')
media = ('topic_ratio', 'exposure_ratio', 'panic_index')

macro_data = indicators_death_infection.loc[:, macro]
return_data = indicators_death_infection.loc[:, crypto_return]
crypto_data = indicators_death_infection.loc[:, crypto]
covid_data = indicators_death_infection.loc[:, death_infection]
media_data = indicators_death_infection.loc[:, media]

# build a function to run and display the adfuller test result
def adf(df):
    for col in df.columns.values:
        adf_results = pd.DataFrame(adfuller(df[col])[0:4],
                                index=
                                ['Test Statistic', 'p-value', '#Lags Used', 'Number of Observations Used'],
                                   columns = [' '])
        print('\n', df[col].name, adf_results, '\n')

        for key, value in adfuller(df[col])[4].items():
            if adf_results.iloc[0,0] > value:
                print (df[col].name, 'not reject H0 on', key, ', non-stationary')
            else:
                print(df[col].name, 'reject H0 on', key, ', stationary')

           # adf_results.loc['Critical Value (%s)' % key] = value

adf(macro_data)
adf(covid_data)
adf(crypto_data)
adf(return_data)
adf(media_data)

# take out the non-stationarity in the data (media data are stationary)
# there are two main approaches, differencing and taking log
# https://towardsdatascience.com/how-to-remove-non-stationarity-in-time-series-forecasting-563c05c4bfc7

# Crypto price, use log first
log_crypto_data = np.log(crypto_data)
print('\nlog_crypto')
adf(log_crypto_data)

# p-values of the BTC data has reduced, we try to take first-order difference and the non-stationarity is
# removed
fd_log_crypto_data = log_crypto_data.diff(1).dropna()
crypto_data1 = fd_log_crypto_data
print('\nlog_first_difference_crypto')
adf(fd_log_crypto_data)

# retrun data 1 df
fd_return_data = return_data.diff(1).dropna()
return_data1 = fd_return_data
print('\nfirst_difference_return')
adf(return_data1)

# macro indicators, use first order difference, the non-stationarity is removed
fd_macro_data = macro_data.diff(1).dropna()
macro_data1 = fd_macro_data
print('\nfirst_difference_macro')
adf(fd_macro_data)

# covid data, try differencing
fd_covid_data= covid_data.diff(1).dropna()
covid_data1 = fd_covid_data
print('\nfirst_difference_covid')
adf(fd_covid_data)

# plot stationary data
def save_multi_image(filename):
   pp = PdfPages(filename)
   fig_nums = plt.get_fignums()
   figs = [plt.figure(n) for n in fig_nums]
   for fig in figs:
      fig.savefig(pp, format='pdf')
   pp.close()

def compareCrypto(df, df2):
    for col in df.columns:
        fig, axs = plt.subplots(2, 1, figsize=(12, 8))
        axs[0].plot(df.loc[:, col])
        axs[0].set_title('fd_log '+ col)
        axs[1].plot(df2.loc[:, col])
        axs[1].set_title('log '+ col)

    #filename = "multi_crypto.pdf"
    #save_multi_image(filename)

def comparefd(df, df2):
    for col in df.columns:
        fig, axs = plt.subplots(2, 1, figsize=(12, 8))
        axs[0].plot(df.loc[:, col])
        axs[0].set_title('fd '+ col)
        axs[1].plot(df2.loc[:, col])
        axs[1].set_title(col)

    #filename = "multi_covid.pdf"
    #save_multi_image(filename)

def comparePlots(df, df2):
    for col in df.columns:
        fig, axs = plt.subplots(2, 1, figsize=(12, 8))
        axs[0].plot(df.loc[:, col])
        axs[0].set_title('log_fd '+ col)
        axs[1].plot(df2.loc[:, col])
        axs[1].set_title(col)

def showplot(df):
    fig, axs = plt.subplots(3, 1, figsize=(12, 12))
    for i, col in enumerate(df.columns):
        axs[i].plot(df.loc[:, col])
        axs[i].set_title(col)

# we use the logged data for cryptocurrencies daily price, while the others are all stationary or stationary after first
# difference
merge1 = macro_data.merge(crypto_data1, on = 'date')
merge2 = merge1.merge(return_data, on = 'date')
merge3 = merge2.merge(covid_data1, on = 'date')
merge4 = merge3.merge(media_data, on ='date')
processed_merged_data1 = merge4

processed_merged_data1.to_csv('stationary_final_merged_data.csv')

# build a dataframe with logged crypto data and original data of other variable
merge10 = macro_data.merge(log_crypto_data, on = 'date')
merge20 = merge10.merge(return_data, on = 'date')
merge30 = merge20.merge(covid_data, on = 'date')
merge40 = merge30.merge(media_data, on ='date')
processed_merged_data10 = merge40

processed_merged_data10.to_csv('log_crypto_merged_data.csv')

comparefd(fd_macro_data, macro_data)
comparefd(fd_covid_data, covid_data)
compareCrypto(fd_log_crypto_data, log_crypto_data)
showplot(media_data)
showplot(return_data)

filename = "../multi_plots.pdf"
save_multi_image(filename)




