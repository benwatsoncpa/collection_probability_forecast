# 6.0 Prepare Xgboost predictions for ARRMS Database --------------------------

  # 6.1 Prepare prediction dataset --------------------------------------------
  pred <- setorder(df,receivable,Days)[isactive==1,.SD[.N], by="receivable"]
  dpred <- xgb.DMatrix(data.matrix(select(pred,-yfinal,-receivable,-incurred,-applied)))

  # 6.2 Format data types for oracle database ---------------------------------
  pred[,FORECAST_PCT:=round(predict(xgb.base.model,dpred),4)]
  pred[,FORECAST_DATE:=format(Sys.Date(), "'%d-%b-%y'")]

  # 6.3 Arrange columns and create date stamp columns ------------------------- 
  predictions <- pred %>%  
    select(RECEIVABLE_ID=receivable,
           FORECAST_DATE,
           FORECAST_PCT,
           ADJUSTED_DEFAULT_AMOUNT=adjusted_default) %>%
    mutate(CREATED_BY_USER_ID="'WATSONBE'",
           CREATED_DATETIME=format(Sys.Date(),"'%d-%b-%y'"),
           LAST_UPDATE_USER_ID="'WATSONBE'",
           LAST_UPDATE_DATETIME=format(Sys.Date(),"'%d-%b-%y'")) %>%
    data.frame()

  # 6.4 Create SQL Statement that will append predictions to database ---------
  sql.append <- "INSERT INTO ARRM_CLCTN_PROBABLY_FORECAST (RECEIVABLE_ID, FORECAST_DATE, FORECAST_PCT, ADJUSTED_DEFAULT_AMOUNT, CREATED_BY_USER_ID, CREATED_DATETIME, LAST_UPDATE_USER_ID, LAST_UPDATE_DATETIME) VALUES (%s);" 
  sqls <- sprintf(sql.append,apply(predictions,1,function(i)paste(i,collapse=",")))


