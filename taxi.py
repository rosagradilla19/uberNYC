#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar 20 14:48:49 2020

@author: oliviaroberts
"""
from pyspark.sql.functions import lit
from pyspark.sql.functions import udf
from pyspark.sql.functions import rand 
from pyspark.sql.functions import split 

# Taxi data
taxi_df = spark.read.csv("taxi-raw-apr14.csv", inferSchema = True, header = True)
uber_df = spark.read.csv("uber-raw-data-apr14.csv", inferSchema = True, header = True)

# Add columns: Time, Label, Day
taxi_df = taxi_df.withColumn('Time', lit(None))
uber_df = uber_df.withColumn('Time', lit(None))
taxi_df = taxi_df.withColumn('Label', lit(None))
uber_df = uber_df.withColumn('Label', lit(None))
taxi_df = taxi_df.withColumn('Day', lit(None))
uber_df = uber_df.withColumn('Day', lit(None))

# Getting correct weekdays
split_col = split(uber_df['Date/Time'], ' ')
uber_df = uber_df.withColumn('Date', split_col.getItem(0))
uber_df = uber_df.withColumn('Timestamp', split_col.getItem(1))

split_col = split(taxi_df['pickup_datetime'], ' ')
taxi_df = taxi_df.withColumn('Date', split_col.getItem(0))
taxi_df = taxi_df.withColumn('Timestamp', split_col.getItem(1))
taxi_df = taxi_df.withColumn('AM/PM', split_col.getItem(2))


def time_column_uber(X):
    a = ['0:', '1:', '2:', '3:', '4:', '5:', '6:', '7:', '8:', '9:']
    b = list(range(10, 25))
    if X[0:2] in a:
        x = int(X[0])
        return(x)
    if int(X[0:2]) in b:
        x = int(X[0:2])
        return(x)
        
def time_column_taxi(X, Y):
    if Y == "AM":
        a = ['01', '02', '03', '04', '05', '06', '07', '08', '09']
        b = ['10', '11']
        if X[0:2] == '12':
            x = 0
            return(x)
        if X[0:2] in a:
            x = int(X[1])
            return(x)
        if X[0:2] in b:
            x = int(X[0:2])
            return(x)
    if Y == "PM":
        a = ['01', '02', '03', '04', '05', '06', '07', '08', '09']
        b = ['10', '11']
        if X[0:2] == '12':
            x = 12
            return(x)
        if X[0:2] in a:
            x = int(X[1]) + 12
            return(x)
        if X[0:2] in b:
            x = int(X[0:2]) + 12
            return(x)

def day_column(X):
    a = ['04/01/2014', '04/02/2014', '04/03/2014', '04/04/2014', '04/05/2014', '04/06/2014', '04/07/2014']
    b = ['4/1/2014', '4/2/2014', '4/3/2014', '4/4/2014', '4/5/2014', '4/6/2014', '4/7/2014']
    if X == a[0] or X == b[0]:
        return("Tuesday")
    if X == a[1] or X == b[1]:
        return("Wednesday")
    if X == a[2] or X == b[2]:
        return("Thursday")
    if X == a[3] or X == b[3]:
        return("Friday")
    if X == a[4] or X == b[4]:
        return("Saturday")
    if X == a[5] or X == b[5]:
        return("Sunday")
    if X == a[6] or X == b[6]:
        return("Monday")
    
def label_column_taxi(X):
    return("Taxi")

def label_column_uber(X):
    return("Uber")

func = udf(time_column_uber)
uber_df = uber_df.withColumn('Time', func(uber_df['Timestamp']))

func = udf(time_column_taxi)
taxi_df = taxi_df.withColumn('Time', func(taxi_df['Timestamp'], taxi_df['AM/PM']))

func = udf(label_column_taxi)
taxi_df = taxi_df.withColumn('Label', func(taxi_df['Label']))
func = udf(label_column_uber)
uber_df = uber_df.withColumn('Label', func(uber_df['Label']))

func = udf(day_column)
taxi_df = taxi_df.withColumn('Day', func(taxi_df['Date']))
uber_df = uber_df.withColumn('Day', func(uber_df['Date']))

# Dropping nulls
uber_df = uber_df.filter((uber_df.Day != 'null'))
taxi_df = taxi_df.filter((taxi_df.dropoff_longitude != '0.0'))

# Take sample
taxi_df = taxi_df.select("*").orderBy(rand()).limit(130000)
uber_df = uber_df.select("*").orderBy(rand()).limit(130000)

# Select only columns needed
taxi_df = taxi_df.select("Time", "Label", "Day", "Date", "dropoff_latitude", "dropoff_longitude")
uber_df = uber_df.select("Time", "Label", "Day", "Date", "Lat", "Lon")

#Union
rides_df = uber_df.union(taxi_df)

# Write to csv
rides_df.write.format("csv").save('rides.csv', header = 'true')


