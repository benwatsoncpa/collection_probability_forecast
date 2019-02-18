# Determine if the pred and train can be distinguished by any vars ------------

library(mltools)

  # Create drift data set -----------------------------------------------------
  pred <- filter(df,isactive==1)
  pred$is_pred <- 1

  train <- df[isactive==0,]
  train$is_pred <- 0

  drift <- rbindlist(list(train,pred)) %>%
    select(-incurred,-applied) %>%
    data.table()

  # Partition drift dataset into 75% and 25% ----------------------------------
  ind <- createDataPartition(drift$receivable,p = 2/3,list = FALSE,times = 1)

  drift1 <- data.frame(drift[ ind,])
  drift2  <- data.frame(drift[-ind,])

  rm(pred,train,drift,ind)

  # For each column in drift, test if var predicts train/pred -----------------

  results <- data.frame(variable=character(ncol(drift1)),
                      issue=numeric(ncol(drift1)),
                      stringsAsFactors = F)


  for (i in 1:ncol(drift1)){
  
  print(i)

  bst <- xgboost(data = as.matrix(drift1[,i]),
                 label = drift1$is_pred, 
                 eta=0.3,
                 gamma=0,
                 max_depth = 6, 
                 min_child_weight=1,
                 subsample = 1, 
                 colsample_bytree =1, 
                 nrounds = 10, 
                 scale_pos_weight=0.5,
                 objective = "binary:logistic",
                 eval_metric="auc")
  
  drift2$predicted <- predict(bst,as.matrix(drift2[,i])) > 0.5
  auc_score <- auc_roc(drift2$predicted,drift2$is_pred)

  results$variable[i] <- names(drift1)[i]
  results$issue[i] <- auc_score
}

View(results)






