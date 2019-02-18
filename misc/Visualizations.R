# Various visualizations ------------------------------------------------------------
# Note: To be run after running Xgboost Train and Predict ---------------------------

# Set up ----------------------------------------------------------------------
train <- df[isactive==0,]
dtrain <- xgb.DMatrix(data.matrix(select(train,-yfinal,-receivable,-incurred,-applied)),label=train$yfinal)

train$predicted <- predict(xgb.base.model,dtrain)
train$Year <- round(train$Days/365,0)

## Error Rate by Year of Receivable -------------------------------------------

vis <- train %>%
  mutate(error=abs(yfinal-predicted)) %>%
  group_by(Year) %>%
  summarise(error=mean(error)) %>%
  data.table()

ggplot(vis,aes(Year,error))+
  geom_bar(stat="identity",col="black",fill="dodgerblue4",alpha=0.9)+
  geom_label(aes(label=paste(round(error*100,1),"%",sep='')))+
  coord_cartesian(xlim=c(0,10),ylim=c(0,0.2))+
  scale_y_continuous(labels=percent)+
  scale_x_continuous(breaks=0:10)+
  labs(title="Prediction Error vs Age of Receivable",
       x="Age of Receivable (Years)",
       y="Mean Absolute Error")


## Average Receivable Collection Rates by Year Debt Incurred ------------------

train$incur_year <- as.POSIXlt(train$incurred)$year+1900

vis <- train %>%
  select(receivable,incur_year,yfinal) %>%
  distinct() %>%
  group_by(incur_year) %>%
  summarise(avg.collection.rate =mean(yfinal)) %>%
  data.table()

ggplot(vis,aes(incur_year,avg.collection.rate))+
  geom_point(shape=0,col="red")+geom_smooth(method="loess")+
  labs(title="Average Receivable Collection Rates by Year Debt Incurred",
       x="Year Debt Incurred",y="Collection Rate (%)")

## What variables are important?
train.vars <- names(select(train,-yfinal,-receivable,-incurred,-applied))
imp <- xgb.importance(train.vars,xgb.base.model)

vis <- imp %>%
  select(Feature,Gain) %>%
  top_n(n=15,Gain)

ggplot(vis,aes(reorder(Feature,Gain),Gain))+
  geom_bar(stat="identity",fill="cornflowerblue",col="black")+
  labs(title="Feature Importance",y="Importance",x="Feature")+
  coord_flip()

# Percentage of Debt Recovered vs. Prediction ---------------------------------

train$predicted <- predict(xgb.base.model,dtrain)

rcs <- c(42383,45087,47792,50954,61220,64622)

vis <- train %>%
  filter(receivable %in% rcs) %>%
  mutate(Years=Days/365.25) %>%
  select(receivable,predicted,ycurrent,Years) %>%
  gather(var.type,value,-Years,-receivable) %>%
  data.table()

ggplot(vis,aes(Years,value,col=var.type))+
  geom_point()+geom_line()+
  scale_color_manual(name="",values=c("black","red"),labels=c("Predicted","Actual"))+
  facet_wrap(~paste("Receivable ",receivable,sep=''))+
  labs(title="Percentage of Debt Recovered vs. Predicted",x="Age of Receivable (Years)",y="")


