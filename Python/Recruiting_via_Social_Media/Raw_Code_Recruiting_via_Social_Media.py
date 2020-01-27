# -*- coding: utf-8 -*-
"""
Created on Tue Jun  4 21:31:52 2019

@author: Darrell
"""

import tweepy as tw
import pandas as pd

# Define my API keys
consumer_key= '' # API key
consumer_secret= ''
access_token= ''
access_token_secret= ''

auth = tw.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tw.API(auth, wait_on_rate_limit=True)

    
# Collect tweets based off a range of dates
import datetime
startdate = datetime.datetime(2018, 2, 1, 00, 00, 00)
enddate = datetime.datetime(2018, 7, 25, 00, 00, 00)

# Choose a specific user
twitter_handle = "USC_FB"

# Choose max amount of tweets to inspect
num_of_tweets = 150000

# Create a function to grab the number of tweets posted, number of times they
# were retweeted, and how many likes their original comments had.
def TwitterFunc(twitter_handle, startdate, enddate, num_of_tweets):   
    counter = 0
    retweet_cnt = 0
    likes_cnt = 0
    for tweet in tw.Cursor(api.user_timeline, screen_name=twitter_handle, since=startdate, until=enddate).items(num_of_tweets):
        #print(tweet.text)
        #print('Retweet Count: ', tweet.retweet_count)
        #print('Number of Likes: ', tweet.favorite_count)
        counter = counter + 1
        retweet_cnt = retweet_cnt + tweet.retweet_count
        likes_cnt = likes_cnt + tweet.favorite_count
    print(counter)
    print(retweet_cnt)
    print(likes_cnt)
    ans = [counter, retweet_cnt, likes_cnt]
    return ans;


# Twitter handles for all 12 teams
Wash = "UW_Football" # Washington
Wazzu = "WSUCougarFB" # Washington State
Stanford = "StanfordFB" # Stanford
Oregon = "oregonfootball" # Oregon
Cal = "CalFootball" # Cal
O_State = "BeaverFootball" # Oregon State
Utah = "Utah_Football" # Utah
Ariz_State = "ASUFootball" # Arizona State
Ariz = "ArizonaFBall" # Arizona
USC = "USC_FB" # Trojans
UCLA = "UCLAFootball" # Bruins
Colo = "CUBuffsFootball" # Colorado

Pac12List = ["UW_Football", "WSUCougarFB", "StanfordFB", "oregonfootball" , 
             "CalFootball", "BeaverFootball" , "Utah_Football", "ASUFootball",
             "ArizonaFBall", "USC_FB", "UCLAFootball", "CUBuffsFootball"]


# Line of code used to access each team's tweet
TwitterFunc(Wazzu, startdate, enddate, num_of_tweets);
    
'''
Unable to run TwitterFunc in a for loop. It crashes everytime. Instead I manually
(hardcoded) collected the outputs from each team. Copy and pasted them into an 
Excel document and will now read in those values using the pandas built-in 
read_excel function.
'''

df = pd.read_excel (r'C:\Users\Darrell\Desktop\652final_proj\Twitter_Football_Data.xlsx') #(use "r" before the path string to address special character, such as '\'). Don't forget to put the file name at the end of the path + '.xlsx'
print (df)


# Now sort the table by most tweets
newdf = df.sort_values(by=['Tweets posted'], ascending = False)
newdf.plot.bar(x='Team', y='Tweets posted')

# Teams filtered by most retweets
rtwdf = df.sort_values(by=['Retweets'], ascending = False)
rtwdf.plot.bar(x='Team', y='Retweets')

# Teams filtered by most likes
likedf = df.sort_values(by=['Likes'], ascending = False)
likedf.plot.bar(x='Team', y='Likes')

# Sort teams by retweets per tweet
df['Retweet/Tweet'] = df['Retweets']/df['Tweets posted']
rtw_per_twdf = df.sort_values(by=['Retweet/Tweet'], ascending = False)
rtw_per_twdf.plot.bar(x='Team', y='Retweet/Tweet')

# Sort teams by Likes/Tweets, to see who the most authentic and popular teams are
df['Like/Tweet'] = df['Likes']/df['Tweets posted']
like_per_twdf = df.sort_values(by=['Like/Tweet'], ascending = False)
like_per_twdf.plot.bar(x='Team', y='Like/Tweet')


# Create list for 247Sports Recruiting Rankings
recruit_rank = ["USC", "Oregon", "Washington", "UCLA", "Utah", "Arizona State",
                "Stanford", "Cal", "Washington State", "Colorado",
                "Arizona", "Oregon State"]

# Get ranking scores for each sorted dataset
anslist = [] # create empty list to store the answers
rank = 0
for team in newdf['Team']:
    for team2 in recruit_rank:
        if team == team2:
            anslist.append(abs(recruit_rank.index(team2) - rank))
            rank = rank + 1
            #ans = newdf.index(team)
            #anslist.append(ans)


anslist1 = []
rank = 0
for team in rtwdf['Team']:
    for team2 in recruit_rank:
        if team == team2:
            anslist1.append(abs(recruit_rank.index(team2) - rank))
            rank = rank + 1
            #ans = newdf.index(team)
            #anslist.append(ans)

            
anslist2 = []
rank = 0
for team in likedf['Team']:
    for team2 in recruit_rank:
        if team == team2:
            anslist2.append(abs(recruit_rank.index(team2) - rank))
            rank = rank + 1
            #ans = newdf.index(team)
            #anslist.append(ans)


anslist3 = []
rank = 0
for team in rtw_per_twdf['Team']:
    for team2 in recruit_rank:
        if team == team2:
            anslist3.append(abs(recruit_rank.index(team2) - rank))
            rank = rank + 1
            #ans = newdf.index(team)
            #anslist.append(ans)


anslist4 = []
rank = 0
for team in like_per_twdf['Team']:
    for team2 in recruit_rank:
        if team == team2:
            anslist4.append(abs(recruit_rank.index(team2) - rank))
            rank = rank + 1
            #ans = newdf.index(team)
            #anslist.append(ans)

import numpy as np

test = pd.DataFrame(np.column_stack([anslist, anslist1, anslist2, anslist3, anslist4]),
             columns=['Tweets', 'Retweets', 'Likes', 'Rtw/twt', 'like/twt'])
colnames = ['Tweets', 'Retweets', 'Likes', 'Rtw/twt', 'like/twt']
a = []
for name in colnames:
    b = sum(test[name][0:3])
    a.append(b)

print('\nRecruiting Ranking displacement per team per categorty:\n\n', test, '\n\nFeature that best predicted top 25%:\n ', colnames[a.index(min(a))], min(a))

# Which feature was the closest in ranking overall?
a = []
for name in colnames:
    b = sum(test[name][0:12])
    a.append(b)


print('Feature with the best prediction overall: ', colnames[a.index(min(a))], min(a))
#########################################################################
#########################################################################

# Create list for Pre-Season Rankings
preseason_rank = [ "Washington", "USC", "Utah", "Stanford", "Arizona", "Oregon",
                "UCLA", "Cal", "Washington State", "Colorado", "Arizona State",
                "Oregon State"]


# Get ranking scores for each sorted dataset
anslist5 = [] # create empty list to store the answers
rank = 0
for team in newdf['Team']:
    for team2 in preseason_rank:
        if team == team2:
            anslist5.append(abs(preseason_rank.index(team2) - rank))
            rank = rank + 1
            #ans = newdf.index(team)
            #anslist.append(ans)


anslist6 = []
rank = 0
for team in rtwdf['Team']:
    for team2 in preseason_rank:
        if team == team2:
            anslist6.append(abs(preseason_rank.index(team2) - rank))
            rank = rank + 1
            #ans = newdf.index(team)
            #anslist.append(ans)

            
anslist7 = []
rank = 0
for team in likedf['Team']:
    for team2 in preseason_rank:
        if team == team2:
            anslist7.append(abs(preseason_rank.index(team2) - rank))
            rank = rank + 1
            #ans = newdf.index(team)
            #anslist.append(ans)


anslist8 = []
rank = 0
for team in rtw_per_twdf['Team']:
    for team2 in preseason_rank:
        if team == team2:
            anslist8.append(abs(preseason_rank.index(team2) - rank))
            rank = rank + 1
            #ans = newdf.index(team)
            #anslist.append(ans)


anslist9 = []
rank = 0
for team in like_per_twdf['Team']:
    for team2 in preseason_rank:
        if team == team2:
            anslist9.append(abs(preseason_rank.index(team2) - rank))
            rank = rank + 1
            #ans = newdf.index(team)
            #anslist.append(ans)

test2 = pd.DataFrame(np.column_stack([anslist5, anslist6, anslist7, anslist8, anslist9]),
             columns=['Tweets', 'Retweets', 'Likes', 'Rtw/twt', 'like/twt'])

colnames = ['Tweets', 'Retweets', 'Likes', 'Rtw/twt', 'like/twt']
a = []
for name in colnames:
    b = sum(test2[name][0:3])
    a.append(b)

print('\nPre-Season Ranking displacement per team per categorty:\n\n', test2, '\n\nFeature that best predicted top 25%:\n ', colnames[a.index(min(a))], min(a))

# Which feature was the closest in ranking overall?
a = []
for name in colnames:
    b = sum(test2[name][0:12])
    a.append(b)

print('Feature with the best prediction overall: ', colnames[a.index(min(a))], min(a))

## Outputed Files

export_csv = df.to_csv (r'C:\Users\Darrell\Desktop\652final_proj\Original_dataframe.csv', index = None, header=True) #Don't forget to add '.csv' at the end of the path
export_csv = test.to_csv (r'C:\Users\Darrell\Desktop\652final_proj\Recruiting_Displacement.csv', index = None, header=True) #Don't forget to add '.csv' at the end of the path
export_csv = test2.to_csv (r'C:\Users\Darrell\Desktop\652final_proj\PreSeason_Displacement.csv', index = None, header=True) #Don't forget to add '.csv' at the end of the path


