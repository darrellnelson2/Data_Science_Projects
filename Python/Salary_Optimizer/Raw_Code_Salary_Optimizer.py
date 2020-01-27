# -*- coding: utf-8 -*-
"""
Created on Fri Jul 19 20:00:02 2019
Class: IST 718
Lab: 01
Problem Statement: How to predict salary for next head coach?
Data: Single excel file containing 118 instances x 23 attributes

@author: Darrell
"""

## Change the working directory
#import os
#print(os.getcwd())  # Prints the current working directory
#
## change to appropriate directory
#path = 'D:\Darrell\Desktop\Syracuse\Summer_19\IST_718_Big_Data_Analytics\Lab01'
#os.chdir(path)
#
#print(os.getcwd())  # Prints the current working directory
###############################################################################

## Import coaches data into IDE
import pandas as pd

df = pd.read_excel (r'D:\Darrell\Desktop\Syracuse\Summer_19\IST_718_Big_Data_Analytics\Lab01\coaches_modify.xlsx') #(use "r" before the path string to address special character, such as '\'). Don't forget to put the file name at the end of the path + '.xlsx'
print(df)
print('Shape of matrix:', df.shape)

df.dtypes # look at the type of data in this dataset
df.head()


#################### Delete all superfluous variables

# Remove columns as index base 
df.drop(df.columns[[2, 3, 5, 7, 8, 9, 12, 13, 14, 15, 16, 17, 21]], axis = 1, inplace = True)
print('Shape of new matrix:', df.shape)
df.head()
print('Columns of new matrix:', list(df.columns)) 

###############################################################################
######################### Clean up the data ###################################
## Remove all teams with missing data (NaN)

newdf = df.dropna(axis=0, how='any')
print('New shape:', newdf.shape)
print('Percentage of rows removed:', "{:.2%}".format((df.shape[0] - newdf.shape[0]) / df.shape[0]))


#### Correlation matrix
corr = newdf.corr()

# Generate a mask for the upper triangle
import numpy as np  # arrays and numerical processing
mask = np.zeros_like(corr, dtype=np.bool)
mask[np.triu_indices_from(mask)] = True

# Generate a custom diverging colormap
import seaborn as sns  # PROVIDES TRELLIS AND SMALL MULTIPLE PLOTTING
cmap = sns.diverging_palette(220, 10, as_cmap=True)

# Draw the heatmap with the mask and correct aspect ratio
sns.heatmap(corr, mask=mask, cmap=cmap, vmax=.3, center=0, annot=True,
            square=True, linewidths=.5, cbar_kws={"shrink": .5})


## Boxplots for different conferences
sns.boxplot(x="Conf", y="TotalPay", data=newdf, color = "gray");
sns.boxplot(x="Conf", y="StadSize", data=newdf, color = "blue");
sns.boxplot(x="Conf", y="Ratio", data=newdf, color = "orange");


## Train a model

## Remove spaces from column names
newdf.columns = ['School', 'Conf', 'MedianConfSal', 'TotalPay', 'StadSize',
       'GraduationRate', 'Ratio', 'OffenceScore', 'DefenseScore',
       'PointsPerGame']

#def formula_from_cols(df, y):
#    return y + ' ~ ' + ' + '.join([col for col in df.columns if not col==y])

#my_model = formula_from_cols(newdf, 'TotalPay')

import statsmodels.formula.api as smf  # R-like model specification
model_fit = smf.ols('TotalPay ~ Conf + MedianConfSal + StadSize + GraduationRate + Ratio + OffenceScore + DefenseScore + PointsPerGame', data = newdf).fit()
print(model_fit.summary())

## 2nd round of modeling
model2_fit = smf.ols('TotalPay ~ Conf + StadSize + DefenseScore + PointsPerGame', data = newdf).fit()
print(model2_fit.summary())

## 3rd round of modeling
model3_fit = smf.ols('TotalPay ~ StadSize + DefenseScore + PointsPerGame', data = newdf).fit()
print(model3_fit.summary())

## What is the recommended salary for the Syracuse football coach?
newdf['predict_sal'] = model_fit.predict(newdf)
newdf.loc[newdf['School'] == 'Syracuse']
ans1 = newdf.loc[newdf.School == 'Syracuse', 'predict_sal']
print('Predicted salary for Syracuse head coach:', float(round(ans1)))

## What would salary be if Syracuse was in Big East conference which is now the
## American Athletic Conference?
ans2 = float(round(ans1)) - 1.024e+06
print('Predicted salary for Syracuse head coach if still in AAC:', ans2)

## What would salary be if Syracuse was in Big Ten conference?
ans3 = ans2 + 1.908e+06
print('Predicted salary for Syracuse head coach was in Big Ten:', ans3)
