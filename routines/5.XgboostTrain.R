# 5.0 Xgboost Train and Append Predictions ------------------------------------

for (i in 1:50) {gc(reset=TRUE)}

  # 5.1 Set xgboost parameters based on hyperparameter tuning -----------------
  xgb.params <- data.table(max_depth=12,
                           gamma=0.15,
                           colsample_bytree=1,
                           min_child_weight=1,
                           subsample=1,
                           max_delta_step = 5,
                           eta=0.1,
                           lambda=1,
                           alpha=1)

  # 5.2 Set up training and prediction data sets ------------------------------
  train <- df[isactive==0,]
  train[] <- lapply(train, as.numeric)
  
  dtrain <- train %>%
    select(-yfinal,-receivable,-incurred,-applied) %>%
    data.matrix() %>%
    xgb.DMatrix(label=train$yfinal)
  
  pred <- filter(df,isactive==1)
  pred[] <- lapply(pred, as.numeric)
  
  dpred <- pred %>%
    select(-yfinal,-incurred,-applied) %>%
    data.matrix() %>%
    xgb.DMatrix()
  
  watchlist <- list(train=dtrain)
  
  # 5.3 Train Xgboost Model ---------------------------------------------------
  for (i in 1:50) {gc(reset=TRUE)}
  t1 <- proc.time()
  
  xgb.base.model <- xgb.train(watchlist=watchlist,
                              xgb.params,
                              objective="binary:logistic",
                              eval_metric = "rmse",
                              tree_method="hist",
                              data=dtrain,
                              nrounds=800,
                              metrics=c("rmse"),
                              print_every_n=1,
                              seed=123)
  
  for (i in 1:50) {gc(reset=TRUE)}
  t2 <- proc.time()
  xgboost.training.time <- t2-t1
  print(xgboost.training.time)
  
  
  

  
  
  
  
  
  
  
  
