# Xgboost Tuning --------------------------------------------------------------

  for (i in 1:50) {gc(reset=TRUE)}
  rm(list=setdiff(ls(),"df"))
  set.seed(123)
  
  library(data.table)
  library(tidyverse)
  library(tm)
  library(caret)
  library(xgboost)
  library(scales)
  library(zoo)

# Split into train, test and prediction data sets -----------------------------

  pred <- filter(df,isactive==1)
  df.train <- filter(df,isactive==0)

  trainIndex <- createDataPartition(df.train$receivable, 
                                    p = 2/3, 
                                    list = FALSE, 
                                    times = 1)

  train <- df.train[ trainIndex,]
  test  <- df.train[-trainIndex,]
  rm(trainIndex)
  
  # Set default tuning grid for xgboost ---------------------------------------
  
  xgb.params <- expand.grid(max_depth=9:15,
                            gamma=0:6/20,
                            colsample_bytree=5:8/8,
                            subsample=5:8/8,
                            min_child_weight=2^0:5,
                            max_delta_step=c(3,4,5,6),
                            eta=1,
                            tree_method="hist",
                            alpha=c(0.8,0.9,1,1.1,1.2),
                            lamda=c(0.8,0.9,1,1.1,1.2))
  
  k <- nrow(xgb.params)
  
  for (i in 1:50) {gc(reset=TRUE)}
  t1 <- proc.time()
  
  # Prepare the Xgb Matrices --------------------------------------------------
  
  dtrain <- train %>%
    mutate_all(funs(as.numeric)) %>%
    select(-yfinal,-incurred,-applied,-receivable) %>%
    data.matrix() %>%
    xgb.DMatrix(label=train$yfinal)
  
  dtest <- test %>%
    mutate_all(funs(as.numeric)) %>%
    select(-yfinal,-incurred,-applied,-receivable) %>%
    data.matrix() %>%
    xgb.DMatrix(label=test$yfinal)
  
  dtest <- test %>%
    mutate_all(funs(as.numeric)) %>%
    select(-yfinal,-incurred,-applied) %>%
    data.matrix() %>%
    xgb.DMatrix(label=pred$yfinal)
  
  
  # Prepare paramters for xgboost tuning --------------------------------------
  
  watchlist <- list(train=dtrain, test=dtest)
  
  y_weight <- mean(train$yfinal)
  
  xgb.tunelog <- setDT(xgb.params[0,])
  xgb.tunelog$iter <- numeric(k)
  xgb.tunelog$train_rmse_mean <- numeric(k)
  xgb.tunelog$train_rmse_std <- numeric(k)
  xgb.tunelog$test_rmse_mean <- numeric(k)
  xgb.tunelog$test_rmse_std <- numeric(k)
  xgb.tunelog$model <- numeric(k)
  
  xgb.tunelog[] <- lapply(xgb.tunelog,as.numeric)
  
  rm(train,test,pred,df.train)
  
  # Run an xgboost model for each set of paramters in the xgb.params
  
  for (i in 1:k){
    
    gc(reset=TRUE)
    
    print(i)
    
    param.list <- data.table(max_depth=.subset2(xgb.params,1)[i],
                            gamma=.subset2(xgb.params,2)[i],
                            colsample_bytree=.subset2(xgb.params,3)[i],
                            min_child_weight=.subset2(xgb.params,4)[i],
                            subsample=.subset2(xgb.params,5)[i],
                            max_delta_step=.subset2(xgb.params,6)[i],
                            eta=.subset2(xgb.params,7)[i],
                            tree_method=.subset2(xgb.params,8)[i],
                            alpha=.subset2(xgb.params,9)[i],
                            lambda=.subset2(xgb.params,10)[i])
    
    xgb.base.model <- xgb.cv(param.list,
                           watchlist=watchlist,
                           objective = "binary:logistic",
                           eval_metric = "rmse",
                           scale_pos_weight=y_weight,
                           data=dtrain,
                           nrounds=80,
                           nfold=5,
                           metrics=c("rmse"),
                           print_every_n=1)
    
    xgb.tunelog <- rbindlist(list(xgb.tunelog,
                                  cbind(param.list,
                                        xgb.base.model$evaluation_log,
                                        i),
                                  row.names = NULL)
    )
  }
  
  write.csv(xgb.tunelog,file="xgb.tune.base.model.csv")
  t2 <- proc.time()
  xgboost.runtime <- t2 - t1
  for (i in 1:50) {gc(reset=TRUE)}