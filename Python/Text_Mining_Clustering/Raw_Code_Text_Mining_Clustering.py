# -*- coding: utf-8 -*-
"""
Created on Mon Jul 22 15:02:57 2019
Class: IST 736
HW: 02-03

@author: Darrell
"""


## Change the working directory
import os
print(os.getcwd())  # Prints the current working directory

# change to appropriate directory
path = 'D:\Darrell\Desktop\Syracuse\Summer_19\IST_736_Text_Mining\Week03\HW2_3'
os.chdir(path)

print(os.getcwd())  # Prints the current working directory
###############################################################################

import tweepy as tw
# import pandas as pd

# Define my API keys
consumer_key= 'A1yBX00z3Sw5M4JodpC43Jz6i' # API key
consumer_secret= '9N0pVUVFXNwVm7gTpEqDrgrYadScSmYRJis78sTHvgDk6vIV6F'
access_token= '1126926683695484928-g1Cke3McRRD9Da1cWU7ibNX7KVb8SK'
access_token_secret= 'JWpwVEtc3pDcv3eIE8ijbGTV0EnIbnHS0exBLwapbwByE'

auth = tw.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tw.API(auth, wait_on_rate_limit=True)

    
# Collect tweets based off the last 3 months range of dates
import datetime
startdate = datetime.datetime(2019, 4, 22, 00, 00, 00)
enddate = datetime.datetime(2019, 7, 22, 00, 00, 00)


# Choose max amount of tweets to inspect
num_of_tweets = 150000

counter = 0
textlist = [] # create list for tweet body text
for tweet in tw.Cursor(api.search, q="#artificialintelligence", since=startdate, until=enddate).items(num_of_tweets):
    counter = counter + 1
    print (tweet.created_at, tweet.text)
    textlist.append(tweet.text)

print(counter) # output total number of tweets pulled in

###############################################################################
############################## Tokenize #######################################
