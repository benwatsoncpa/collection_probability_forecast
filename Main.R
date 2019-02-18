# This project was built under R version 3.5.0
# Author: Ben Watson (ben.watson@canada.ca; ben.watson.ca@gmail.com)

# Reset workspace & Load Libraries --------------------------------------------

rm(list=ls())
options(scipen=999)

for (i in 1:50) gc(reset=T)

  library(RODBC)
  library(data.table)
  library(tidyverse)
  library(tm)
  library(caret)
  library(xgboost)
  library(scales)
  library(zoo)

  set.seed(123)

# 1.0 Connect to ARRMS Database -----------------------------------------------
  source("./routines/1.ConnectToDatabase.R",echo=T)
  
# 2.0 Get SQL Data ------------------------------------------------------------
  source("./routines/2.GetSQLData.R",echo=T)
  
# 3.0 Clean SQL Data ----------------------------------------------------------
  source("./routines/3.CleanSQLData.R",echo=T)
  
# 4.0 Create Features ---------------------------------------------------------
  source("./routines/4.CreateFeatures.R",echo=T)

# 5.0 Train Xgboost Model -----------------------------------------------------
  
  source("./routines/5.XgboostTrain.R",echo=T)
  
# 6.0 Prepare Xgboost predictions for ARRMS Database --------------------------
  
  source("./routines/6.PreparePredictions.R",echo=T)
  
# 7.0 Append Xgboost predictions to ARRMS Database ----------------------------
  
  source("./routines/7.AppendPredictions.R",echo=T)
  

