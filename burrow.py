#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 11 14:28:30 2020

@author: oliviaroberts
"""
from pyspark.sql.functions import lit
from pyspark.sql.functions import udf
from pyspark.sql.functions import rand 
from pyspark.sql.types import FloatType
from shapely.geometry import Point
import geopandas as gpd

# Read csv
uber_df = spark.read.csv("uber14.csv", inferSchema = True, header = True)
nyc = gpd.read_file('NYC_map/nyc.shp')

# Change lat/long to float
uber_df = uber_df.withColumn("Lat", uber_df["Lat"].cast(FloatType()))
uber_df = uber_df.withColumn("Lon", uber_df["Lon"].cast(FloatType()))

# Add columns: Burrow , Month
uber_df = uber_df.withColumn('Burrow', lit(None))
uber_df = uber_df.withColumn('Month', lit(None))

# Take sample
sample_uber_df = uber_df.select("*").orderBy(rand()).limit(100000)

def burrow_column(X, Y):
    point = Point(Y, X)
    if nyc['geometry'][0].contains(point):
        return('Bronx')
    if nyc['geometry'][1].contains(point):
        return('Staten Island')
    if nyc['geometry'][2].contains(point):
        return('Brooklyn')
    if nyc['geometry'][3].contains(point):
        return('Queens')
    if nyc['geometry'][4].contains(point):
        return('Manhattan')

def month_column(X):
    if X[0] == '4':
        return("April")
    if X[0] == '5':
        return("May")
    if X[0] == '6':
        return("June")
    if X[0] == '7':
        return("July")
    if X[0] == '8':
        return("August")
    if X[0] == '9':
        return("September")

func = udf(burrow_column)
sample_uber_df = sample_uber_df.withColumn('Burrow', func(sample_uber_df['Lat'], sample_uber_df['Lon']))

func = udf(month_column)
sample_uber_df = sample_uber_df.withColumn('Month', func(sample_uber_df['Date/Time']))

# Dropping nulls
sample_uber_df = sample_uber_df.filter((sample_uber_df.Month != 'null'))
sample_uber_df = sample_uber_df.filter((sample_uber_df.Burrow != 'null'))

# Write to csv
sample_uber_df.write.format("csv").save('burrows.csv', header = 'true')



#### Extras ####
uber_df.createOrReplaceTempView("Uber")
new_df = sqlContext.sql("select count(*) from Uber")
new_df = uber_df.groupby(uber_df.Burrow).count()
X = taxi_df.select("pickup_datetime").collect()[0] 
Y = uber_df.select("Lon").collect()[0] 
