
import pandas as pd
import numpy as np
from matplotlib.backends.backend_pdf import PdfPages


pd.set_option('display.max_columns', None)

# read the crypto currency data
hist_df = pd.read_csv('crypto_HistoricData.csv', index_col = 0)
hist_df.index = pd.to_datetime(hist_df.index)

# read and process the treasury data
treasury_data = pd.read_csv('Treasury Yield.csv', index_col = 0, parse_dates = True)
treasury_data.columns = ['price_treasury', 'open_treasury', 'high_treasury', 'low_treasury', 'change%_treasury']
treasury_data.index.name = 'date'
treasury_data.sort_index(inplace = True)

# save the treasury dataframe to csv
treasury_data.to_csv('Treasury Yield.csv')

# read, process and save the oil indicators csv
oil_data = pd.read_csv('oil price.csv', index_col = 0, parse_dates = True)
oil_data.index.name = 'date'
oil_data.columns = ['price_oil', 'open_oil', 'high_oil', 'low_oil', 'volume_oil', 'change%_oil']
oil_data.to_csv('oil price.csv')

# read, process and save the S&P index
SnP_data = pd.read_csv('S&P 500 Historical Data.csv', index_col = 0, parse_dates = True).dropna()
SnP_data.index.name = 'date'
SnP_data.columns = ['price_S&P', 'open_S&P', 'high_S&P', 'low_S&P', 'volume_S&P', 'change%_S&P']
SnP_data.to_csv('SnP data.csv')

# read, process and save the gold price
gold_data = pd.read_csv('Daily Gold Price.csv', index_col = 0, parse_dates = True)
gold_data.index.name = 'date'
gold_data.columns = ['price_gold', 'open_gold', 'high_gold', 'low_gold', 'volume_gold', 'change%_gold']

# read, process and save the global death data
death_data = pd.read_csv('global death.csv', parse_dates = True)
death_data_T = death_data.transpose()
death_data_T = death_data_T.drop(['Lat', 'Long', 'Province/State'])
death_data_T.index.name = 'Date'
death_data_T.columns = death_data_T.iloc[0]
death_data_T = death_data_T.drop(['Country/Region'])
death_data_T.index = pd.to_datetime(death_data_T.index)
death_data_T.loc[:,'Death_Global'] = death_data_T.sum(axis=1)
death_data_T.loc[:,'Daily_Death_Global'] = death_data_T['Death_Global'].rolling(window=2).apply(np.diff)
death_data_final = pd.DataFrame(death_data_T.loc[:, ['Death_Global', 'Daily_Death_Global']])

# read, process and save the global infected data
infection_data = pd.read_csv('global confirmed.csv', parse_dates = True)
infection_data_T = infection_data.transpose()
infection_data_T = infection_data_T.drop(['Lat', 'Long', 'Province/State'])
infection_data_T.index.name = 'Date'
infection_data_T.columns = infection_data_T.iloc[0]
infection_data_T = infection_data_T.drop(['Country/Region'])
infection_data_T.index = pd.to_datetime(infection_data_T.index)
infection_data_T.loc[:,'Infection_Global'] = infection_data_T.sum(axis=1)
infection_data_T.loc[:,'Daily_Infection_Global'] = infection_data_T['Infection_Global'].rolling(window=2).apply(np.diff)
infection_data_final = pd.DataFrame(infection_data_T.loc[:, ['Infection_Global', 'Daily_Infection_Global']])

# merge the dataframes
merge_crypto_treasury = hist_df.merge(treasury_data, left_index = True, right_index = True, how = 'inner')
merge_crypto_treasury_oil = merge_crypto_treasury.merge(oil_data, left_index = True, right_index = True, how = 'inner')
merge_crypto_treasury_oil_SnP = merge_crypto_treasury_oil.merge(SnP_data, left_index = True, right_index = True, how = 'inner')
final_merge_indicators = merge_crypto_treasury_oil_SnP.merge(gold_data, left_index = True, right_index = True, how = 'inner')
indicators_death = final_merge_indicators.join(death_data_final)
indicators_death_infection = indicators_death.join(infection_data_final)

indicators_death_infection.index.name = 'date'

indicators_death_infection.to_csv('final_merged_data.csv')

# read the media data
corona_topics_hist = pd.read_csv('ravenpack_coronavirus_topics_historical.csv', index_col = 0)
corona_topics_hist.index = pd.to_datetime(corona_topics_hist.index)
corona_entities_hist = pd.read_csv('ravenpack_coronavirus_entities_historical.csv', index_col = 0)
corona_entities_hist.index = pd.to_datetime(corona_entities_hist.index)
corona_countires_hist = pd.read_csv('ravenpack_coronavirus_countries_historical.csv', index_col = 0)
corona_countires_hist.index = pd.to_datetime(corona_countires_hist.index)

# select the finance related topics: stock loss and stock gain, select the crypto entities related data: Binance and Coinbase
stockGains = pd.DataFrame(corona_topics_hist.loc[(corona_topics_hist['TOPIC'] == 'Stock Gains') & (corona_topics_hist['COUNTRY_NAME'] == 'Worldwide')])
stockLoss = pd.DataFrame(corona_topics_hist.loc[(corona_topics_hist['TOPIC'] == 'Stock Losses') & (corona_topics_hist['COUNTRY_NAME']== 'Worldwide')])
binance = pd.DataFrame(corona_entities_hist.loc[corona_entities_hist['ENTITY_NAME'] == 'Binance Holdings Ltd.'])
coinbase = pd.DataFrame(corona_entities_hist.loc[corona_entities_hist['ENTITY_NAME'] == 'Coinbase Global Inc.'])
binance = binance.loc[binance['SEGMENT'] == 'Financials']
panic = corona_countires_hist.loc[(corona_countires_hist['COUNTRY_NAME'] == 'Worldwide')]

ratio_stockGains = pd.DataFrame(stockGains.loc[:, 'TOPIC_RATIO'])
ratio_stockGains.index.name = 'date'
ratio_stockLoss = pd.DataFrame(stockLoss.loc[:, 'TOPIC_RATIO'])
ratio_stockLoss.index.name = 'date'
ratio_binance = pd.DataFrame(binance.loc[:, 'MEDIA_EXPOSURE_RATIO'])
ratio_binance.index.name = 'date'
ratio_coinbase = pd.DataFrame(coinbase.loc[:, 'MEDIA_EXPOSURE_RATIO'])
ratio_coinbase.index.name = 'date'
panic_index = pd.DataFrame(panic.loc[:, 'PANIC_INDEX'])
panic_index.columns = ['panic_index']
panic_index.index.name = 'date'

# merge the media index data
finance_ratio = ratio_stockGains.merge(ratio_stockLoss, on = 'date', how = 'outer').replace(np.nan, 0)
crypt_ratio = ratio_coinbase.merge(ratio_binance, on = 'date', how = 'outer').replace(np.nan, 0)

finance_topic_ratio = pd.DataFrame(finance_ratio.iloc[:, 0] + finance_ratio.iloc[:, 1], columns = ['topic_ratio'])
crypt_exposure_ratio = pd.DataFrame(crypt_ratio.iloc[:, 0] + crypt_ratio.iloc[:, 1], columns = ['exposure_ratio'])

ratio_data = finance_topic_ratio.merge(crypt_exposure_ratio, on = 'date', how = 'inner')
media_ratio_data = ratio_data.merge(panic_index, on = 'date', how = 'inner')
media_ratio_data.to_csv('media_ratio_data.csv')

media_indicators_death_infection = indicators_death_infection.join(media_ratio_data, how = 'left')

media_indicators_death_infection.to_csv('final_merged_data.csv')

# convert string to float in the data
media_indicators_death_infection.loc[:, 'price_S&P'] = \
    media_indicators_death_infection.loc[:, 'price_S&P'].str.replace(',', '').astype(float)
media_indicators_death_infection.loc[:, 'price_gold'] = \
    media_indicators_death_infection.loc[:, 'price_gold'].str.replace(',', '').astype(float)

# different sets of column names for test
crypto = ('close_BTC', 'close_DASH', 'close_ETH')
crypto_return = ('BTC_return', 'DASH_return', 'ETH_return')
macro = ('price_treasury', 'price_oil', 'price_S&P', 'price_gold')
death_infection = ('Daily_Death_Global', 'Daily_Infection_Global')
media = ('topic_ratio', 'exposure_ratio', 'panic_index')

# exclude missing value in the data
macro_data = media_indicators_death_infection.loc[:, macro].replace(np.nan, 0)
return_data = media_indicators_death_infection.loc[:, crypto_return]
crypto_data = media_indicators_death_infection.loc[:, crypto]
covid_data = media_indicators_death_infection.loc[:, death_infection].replace(np.nan, 0)
media_data = media_indicators_death_infection.loc[:, media].replace(np.nan, 0)

# merge the processed data
merge0 = macro_data.merge(return_data, on = 'date', how = 'inner')
merge1 = merge0.merge(crypto_data, on = 'date', how = 'inner')
merge2 = merge1.merge(covid_data, on = 'date', how = 'inner')
merge3 = merge2.merge(media_data,  on = 'date', how = 'inner')

merge3.to_csv('final_merged_data.csv')

print(merge3.describe())
print(merge3)