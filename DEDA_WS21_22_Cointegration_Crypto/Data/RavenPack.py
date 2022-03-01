import pandas as pd
import statsmodels as stam
import matplotlib.pyplot as plt
import numpy as np
from coinbase.wallet.client import Client
# from Historic_Crypto import HistoricalData
from statsmodels.tsa.stattools import adfuller
from matplotlib.backends.backend_pdf import PdfPages
from matplotlib.dates import DateFormatter
import matplotlib.dates as mdates
pd.set_option('display.max_columns', None)

# get the media data
corona_topics_hist = pd.read_csv('ravenpack_coronavirus_topics_historical.csv', index_col = 0)
corona_topics_hist.index = pd.to_datetime(corona_topics_hist.index)
corona_entities_hist = pd.read_csv('ravenpack_coronavirus_entities_historical.csv', index_col = 0)
corona_entities_hist.index = pd.to_datetime(corona_entities_hist.index)
corona_countires_hist = pd.read_csv('ravenpack_coronavirus_countries_historical.csv', index_col = 0)
corona_countires_hist.index = pd.to_datetime(corona_countires_hist.index)

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

finance_ratio = ratio_stockGains.merge(ratio_stockLoss, on = 'date', how = 'outer').replace(np.nan, 0)
crypt_ratio = ratio_coinbase.merge(ratio_binance, on = 'date', how = 'outer').replace(np.nan, 0)

finance_topic_ratio = pd.DataFrame(finance_ratio.iloc[:, 0] + finance_ratio.iloc[:, 1], columns = ['topic_ratio'])
crypt_exposure_ratio = pd.DataFrame(crypt_ratio.iloc[:, 0] + crypt_ratio.iloc[:, 1], columns = ['exposure_ratio'])

ratio_data = finance_topic_ratio.merge(crypt_exposure_ratio, on = 'date', how = 'inner')
media_ratio_data = ratio_data.merge(panic_index, on = 'date', how = 'inner')
media_ratio_data.to_csv('media_ratio_data.csv')

print(panic_index)