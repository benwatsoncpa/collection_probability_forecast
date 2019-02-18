# LightGBM Tuning -------------------------------------------------------------

rm(list=setdiff(ls(),"df"))
for (i in 1:50) {gc(reset=TRUE)}

# Create train lgb.datasets ---------------------------------------------------

df.train <- filter(df,isactive==0)
train <- select(df.train,-receivable,-incurred,-applied)
train[] <- lapply(train, as.numeric)
dtrain <- lgb.Dataset(as(as.matrix(select(train,-yfinal)),"dgCMatrix"),label=train$yfinal)

# Set default tuning grid for xgboost -------------------------------------------

for (i in 1:50) {gc(reset=TRUE)}

params.dt <- expand.grid(num_leaves=2^(5:9),
                         min_data=2^(4:8),
                         learning_rate=0.5,
                         max_bin=2^(9:11))

tunelog <- data.table(model=numeric(0),
                      num_leaves=numeric(0),
                      min_data=numeric(0),
                      max_bin=numeric(0),
                      learning_rate=numeric(0),
                      iter=numeric(0),
                      rmse=numeric(0),
                      rmse_sd=numeric(0))

for (i in 1:nrow(params.dt)){

  params <- list(objective = "binary", 
                 metric = "rmse",
                 num_leaves=params.dt$num_leaves[i],
                 min_data = params.dt$min_data[i],
                 learning_rate = params.dt$learning_rate[i],
                 max_bin=params.dt$max_bin[i])
  
  lgbm.base.model <- lgb.cv(params,
                            data=dtrain,
                            nrounds=100,
                            nfold = 5,
                            num_threads=6,
                            record=T,
                            showsd = T,
                            early_stopping_rounds = 10)
  
  temp <- data.table(model=i,
                     num_leaves=params.dt$num_leaves[i],
                     min_data = params.dt$min_data[i],
                     learning_rate = params.dt$learning_rate[i],
                     max_bin=params.dt$max_bin[i],
                     iter=1:length(unlist(lgbm.base.model$record_evals$valid$rmse$eval)),
                     rmse=unlist(lgbm.base.model$record_evals$valid$rmse$eval),
                     rmse_sd=unlist(lgbm.base.model$record_evals$valid$rmse$eval_err))
  
  tunelog <- rbind(tunelog,temp)
  
}

fwrite(tunelog,"./Tune Results/lgb.tune.base.model 2018-04-09.csv")

# Visualize Predictions -------------------------------------------------------

lgbm.base.model$
plot(density(pred$COLLECTION_PROBABILITY_FORECAST))

# Analyze Tune Results --------------------------------------------------------

top10models <- tunelog %>%
  group_by(model) %>%
  summarise(rmse_min=min(rmse)) %>%
  distinct() %>%
  top_n(n=10,-rmse_min) %>%
  data.table()

View(tunelog)

ggplot(tunelog,aes(iter,rmse,col=as.factor(model)))+
  geom_point(shape=1)+geom_line()+
  coord_cartesian(ylim=c(0.18,0.25))

View(distinct(select(tunelog[model %in% top10models$model],-rmse,-rmse_sd,-iter)))
  
