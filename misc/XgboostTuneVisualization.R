# Visualize the xgboost tuning results ----------------------------------------

  xgb.tunelog <- fread("xgb.tune.base.model.csv")
  
  # # Create model number -------------------------------------------------------
  # xgb.tunelog$model <- 1
  # xgb.tunelog <- data.frame(xgb.tunelog)
  # 
  # for (i in 2:nrow(xgb.tunelog)){
  #   xgb.tunelog$model[i] <- with(xgb.tunelog,ifelse(iter[i]==1,model[i-1]+1,model[i-1]))
  # }

  xgb.tunelog <- setDT(xgb.tunelog)
  
  # Visualize by variable
  ggplot(xgb.tunelog,aes(as.factor(alpha),test_rmse_mean))+
    geom_boxplot()
  
  View(xgb.tunelog)

  # Calculate variance --------------------------------------------------------
  xgb.tunelog[,ratio:=round(train_rmse_mean/test_rmse_mean,1)]
  xgb.tunelog[,ratio:=min(ratio),by=model]
  xgb.tunelog[,min_score:=min(test_rmse_mean),by=model]
  
  
  # Parallel Coordinates Plot
  xgb.tunelog.summary <- xgb.tunelog %>%
    group_by(model,gamma,colsample_bytree,subsample,max_delta_step) %>%
    summarise(test_score =min(test_rmse_mean)) %>%
    filter(test_score<0.15) %>%
    data.table()
  
  library(GGally)
  ggparcoord(data=xgb.tunelog.summary,columns=2:5,groupColumn = 'test_score',scale='std')+
    geom_line(size=3)
  
  # Plot results --------------------------------------------------------------
  
  ggplot(xgb.tunelog,aes(iter,test_rmse_mean,col=as.factor(max_delta_step)))+
    geom_point()
  
  xgb.tunelog.subset <- xgb.tunelog[min_score <0.145]
  
  ggplot(xgb.tunelog.subset,aes(iter,test_rmse_mean,ratio,col=as.factor(model)))+
    geom_point() + geom_line()+
    labs(title="Ratio = 0.9")+
    coord_cartesian(xlim=c(40,80),ylim=c(0.14,.16))
  
  # Determine slope of each line ----------------------------------------------
  
  models <- data.frame(model=unique(xgb.tunelog.subset$model),
                       slope=numeric(length(unique(xgb.tunelog.subset$model))))
  
  for (i in 1:nrow(models)){
  models$slope[i] <- coef(lm(test_rmse_mean~iter,data=xgb.tunelog[model==models$model[i]]))[2]
  }
  
  View(models)


