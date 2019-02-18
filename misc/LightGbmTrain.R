# LightGBM Train --------------------------------------------------------------

rm(list=setdiff(ls(),"df"))
for (i in 1:50) {gc(reset=TRUE)}

# Create train lgb.datasets ---------------------------------------------------

df.train <- filter(df,isactive==0)
train <- select(df.train,-receivable,-incurred,-applied)
train[] <- lapply(train, as.numeric)
dtrain <- lgb.Dataset(as(as.matrix(select(train,-yfinal)),"dgCMatrix"),label=train$yfinal)

params <- list(objective = "binary", 
               metric = "binary",
               num_leaves=512,
               min_data=64,
               learning_rate=0.2)
  
lgbm.base.model <- lgb.train(params,
                             data=dtrain,
                             nrounds=200,
                             num_threads=6,
                             verbose=1)

# View predictions

pred <- setorder(df,receivable,Days)[isactive==1,.SD[.N], by="receivable"]
dpred <- lgb.Dataset(as(as.matrix(select(pred,-incurred,-applied,-yfinal)),"dgCMatrix"))
pred$COLLECTION_PROBABILITY_FORECAST <- predict(lgbm.base.model,as.matrix(select(pred,-incurred,-applied,-yfinal)))
plot(density(pred$COLLECTION_PROBABILITY_FORECAST))

names(pred)

