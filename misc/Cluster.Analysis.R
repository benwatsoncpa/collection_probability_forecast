# Cluster Analysis of ARRM Receivables ----------------------------------------

  for (i in 1:50) gc(reset=T)

  # Summarise df by receivable, month and amount collected --------------------
  cluster.df <- df %>%
    filter(isactive==0) %>%
    mutate(Years=round(Days/365.25,0)) %>%
    arrange(Days) %>%
    group_by(receivable,Years) %>%
    summarise(ycurrent=last(ycurrent)) %>%
    spread(Years,ycurrent) %>%
    data.table()
  
  # Deal with NAs
  cluster.df$`0` <- ifelse(is.na(cluster.df$`0`),0,cluster.df$`0`)
  cluster.df <- apply(cluster.df, 1, function(x) na.locf(x))
  cluster.df <- data.table(t(cluster.df))
  
  # Kmeans Cluster Analysis ---------------------------------------------------
  cl <- select(cluster.df,`0`:`10`)
  
  set.seed(1001)
  wss <- (nrow(cl)-1)*sum(apply(cl,2,var))
  
  for (i in 2:15) {
    print(i)
    wss[i] <- sum(kmeans(cl, centers=i,iter.max=1000)$withinss)
    }
  
  plot(1:15, wss, type="b", xlab="# of Clusters",ylab="Within groups sum of squares")
  fit <- kmeans(cl, centers=9,iter.max=1000)
  cl <- data.frame(select(cluster.df,receivable,`0`:`10`), cluster=fit$cluster)
  
  # Calculate Proportion of data in each cluster ------------------------------
  clp <- cl %>%
    select(receivable,cluster) %>%
    distinct() %>%
    group_by(cluster) %>%
    summarise(cnt=n()) %>%
    mutate(prop = cnt / sum(cnt)) %>%
    data.table()
  
  # Average line --------------------------------------------------------------
  cl.vis <- cl %>%
    gather(year,collected,-cluster,-receivable) %>%
    mutate(year=as.numeric(gsub("X","",year))) %>%
    group_by(cluster,year) %>%
    summarise(collected=mean(collected)) %>%
    merge(clp,by="cluster") %>%
    data.table()
  
  # Visualize the clusters ----------------------------------------------------
  ggplot(cl.vis,aes(year,collected))+
    geom_point(shape=1,col="red")+geom_line(col="blue")+
    labs(x="Year",y="Average % Collected")+
    facet_wrap(~paste("Cluster ",cluster,": ",round(prop*100,1),"%",sep=""), ncol = 3)
  
