#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 11 14:28:30 2020

@author: oliviaroberts
"""
from pyspark.sql.functions import lit
from pyspark.sql.functions import udf
from pyspark.sql.functions import split

# St. Patrick's Day
# Read csv
uber_df = spark.read.csv(".csv", inferSchema = True, header = True)

# Add columns: Time, Label
uber_df = uber_df.withColumn('Time', lit(None))
uber_df = uber_df.withColumn('Label', lit(None))

# St Patrick's Day
uber_df = uber_df.filter((uber_df.Pickup_date[0:10] == '2015-03-17'))

# Split columns
split_col = split(uber_df['Pickup_date'], ' ')
uber_df = uber_df.withColumn('Date', split_col.getItem(0))
uber_df = uber_df.withColumn('Timestamp', split_col.getItem(1))

def time_column(X):
    x = int(X[0:2])
    return(x)

def label_column(X):
    return("St. Patrick's Day")
        
func = udf(time_column)
uber_df = uber_df.withColumn('Time', func(uber_df['Timestamp']))

func = udf(label_column)
uber_df = uber_df.withColumn('Label', func(uber_df['Label']))

# Write to csv
uber_df.toPandas().to_csv('stpatricks.csv')

# NYC Pride
# Read csv
uber_df = spark.read.csv("uber-raw-data-jun14.csv", inferSchema = True, header = True)

# Add columns: Time, Label
uber_df = uber_df.withColumn('Time', lit(None))
uber_df = uber_df.withColumn('Label', lit(None))

# Split columns
split_col = split(uber_df['Date/Time'], ' ')
uber_df = uber_df.withColumn('Date', split_col.getItem(0))
uber_df = uber_df.withColumn('Timestamp', split_col.getItem(1))

# Pride Day 
uber_df = uber_df.filter((uber_df.Date[0:10] == '6/29/2014'))

def time_column(X):
    a = ['0:', '1:', '2:', '3:', '4:', '5:', '6:', '7:', '8:', '9:']
    b = list(range(10, 25))
    if X[0:2] in a:
        x = int(X[0])
        return(x)
    if int(X[0:2]) in b:
        x = int(X[0:2])
        return(x)

def label_column(X):
    return("NYC Pride")
        
func = udf(time_column)
uber_df = uber_df.withColumn('Time', func(uber_df['Timestamp']))

func = udf(label_column)
uber_df = uber_df.withColumn('Label', func(uber_df['Label']))

# Write to csv
uber_df.toPandas().to_csv('nycpride.csv')

# Fourth of July
# Read csv
uber_df = spark.read.csv(“uber-raw-data-jul14.csv”, inferSchema = True, header = True)

# Add columns: Time, Label
uber_df = uber_df.withColumn(‘Time’, lit(None))
uber_df = uber_df.withColumn(‘Label’, lit(None))

# Split columns
split_col = split(uber_df[‘Date/Time’], ' ’)
uber_df = uber_df.withColumn(‘Date’, split_col.getItem(0))
uber_df = uber_df.withColumn(‘Timestamp’, split_col.getItem(1))

# Fourth of July 
uber_df = uber_df.filter((uber_df.Date[0:9] == '7/4/2014'))

def time_column(X):
    a = ['0:', '1:', '2:', '3:', '4:', '5:', '6:', '7:', '8:', '9:']
    b = list(range(10, 25))
    if X[0:2] in a:
        x = X[0]
        x = int(x)
        return(x)
    if int(X[0:2]) in b:
        x = X[0:2]
        x = int(x)
        return(x)
        
def label_column(X):
    return(“Fourth of July”)

func = udf(time_column)
uber_df = uber_df.withColumn(‘Time’, func(uber_df[‘Timestamp’]))

func = udf(label_column)
uber_df = uber_df.withColumn(‘Label’, func(uber_df[‘Label’]))

# Write to csv
uber_df.toPandas().to_csv(‘fourthjuly.csv’) 
