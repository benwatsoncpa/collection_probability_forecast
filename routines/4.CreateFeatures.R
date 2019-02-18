# 4.0 Create features and prepare data for xgboost ----------------------------

  # 4.1 Calculate the number of days between applied and incurred -------------
  df <- df[,Days:=as.numeric(applied-incurred,units="days")]
  
  # 4.2 Remove notes and documents that are prior to the incurred date --------
  df <- df[Days > 0 | (type!="note" & type!="document")]
  
  # These are removed because the notes and documents were joined, in the SQL 
  # statements, on debtor account id and not receivable id. 
  
  # 4.3 Calculate end dates of each type of reeivable -------------------------
    
    # 4.3.1 Receivables closed by deletion or recovery ------------------------  
    end.date.inactive1 <- df %>%
      merge(rs,by=c("receivable","isactive")) %>%
      filter(isactive==0) %>%
      filter(status=="Closed - Paid in Full" | status %like% "Del") %>%
      filter((type=="Adjustment" & subtype=="Deletion Adjustment") | type=="Recovery") %>%
      group_by(receivable) %>%
      summarise(end.date=max(applied)) %>%
      data.table()
    
    # 4.3.2 Inactive receivables closed by cases ------------------------------
    end.date.inactive2 <- df %>%
      merge(rs,by=c("receivable","isactive")) %>%
      filter(isactive==0) %>%
      filter(!(receivable %in% end.date.inactive1$receivable)) %>%
      filter(status!="On Hold") %>%
      filter(type=="case") %>%
      group_by(receivable) %>%
      summarise(end.date=max(applied)) %>%
      data.table()
        
    # 4.3.3 Inactive receivables on hold --------------------------------------
    end.date.inactive3 <- df %>%
      merge(rs,by=c("receivable","isactive")) %>%
      filter(isactive==0) %>%
      filter(status=="On Hold") %>%
      mutate(end.date=Sys.time()+60*60*24) %>%
      select(receivable,end.date) %>%
      distinct() %>%
      data.table()
      
    # 4.3.4 Active receivables ------------------------------------------------
    end.date.active <- df %>%
      filter(isactive==1) %>%
      select(receivable) %>%
      distinct() %>%
      mutate(end.date=Sys.time()+60*60*24) %>%
      data.table()
      
    # 4.3.5 Combine all receivable end dates ----------------------------------
    end.dates <- rbind(end.date.inactive1,
                       end.date.inactive2,
                       end.date.inactive3,
                       end.date.active)
    
  # 4.4 Remove notes and documents that are after the end date ----------------
    df <- merge(df,end.dates,all.x=T,by="receivable")
    df <- df[(applied < end.date) | (type!="note" & type!="document")]
    df[,end.date:=NULL]
  
  # These are removed because the notes and documents were joined, in the SQL 
  # statements, on debtor account id and not receivable id. 
  
  # 4.5 Tidy up ---------------------------------------------------------------
  rm(list=setdiff(ls(),c("de","df","rs","df.backup")))
  
  # 4.6 Remove spaces and punctuation from subtype column ---------------------
  df$subtype <- removePunctuation(df$subtype)
  df$subtype <- gsub(' ','',df$subtype)

  # 4.7 Create new features with dcast----------------------------------------
  df.balancesubtype <- dcast(df,isactive+receivable+incurred+applied+Days~
                             balance+type+subtype,fun.aggregate=sum,sep="_",value.var="amount")

  df.balancetype <- dcast(df,isactive+receivable+incurred+applied+Days~
                            balance+type,fun.aggregate=sum,sep="_",value.var="amount")

  df.balance <- dcast(df,isactive+receivable+incurred+applied+Days~
                        balance,fun.aggregate=sum,sep="_",value.var="amount")

  df.type <- dcast(df,isactive+receivable+incurred+applied+Days~
                     type,fun.aggregate=sum,sep="_",value.var="amount")

  # 4.8 Merge new dcast features together ------------------------------------
  merge.list <- list(df.type,df.balancesubtype,df.balancetype,df.balance)
  df <- Reduce(function(x,y) merge(x,
                                   y,
                                   by=c("isactive",
                                        "receivable",
                                        "incurred",
                                        "applied",
                                        "Days"),
                                   all=TRUE),merge.list)
  
  
  rm(list=setdiff(ls(),c("de","df","rs","df.backup")))
  for (i in 1:50) gc(reset=TRUE)

  # 4.9 Create cumulative variables ------------------------------------------
  df <- setorder(df,Days)
  rmnames <- c("isactive","receivable","incurred","applied","Days")
  cnames <- paste("c_", setdiff(names(df),rmnames), sep='')
  df <- df[,(cnames):=lapply(.SD,cumsum),by=receivable,.SDcols = setdiff(names(df),rmnames)]

  # 4.10 Calculate adjusted_default: the denominator of ycurrent --------------
  df <- df[,adjusted_default:=(c_Principal_Default+
                                 c_Principal_Adjustment-
                                 c_Principal_Adjustment_DeletionAdjustment)]
  
  # 4.11 Calculate ycurrent: % of principle recovered -------------------------
  df <- df[,ycurrent:=-(c_Principal_Recovery+c_Principal_Reversal)/adjusted_default]
  
  # 4.12 lag ycurrent to create yprevious -------------------------------------
  df[,yprevious1:=lag(ycurrent,1),by=receivable]
  df[,yprevious2:=lag(ycurrent,2),by=receivable]
  df[,yprevious3:=lag(ycurrent,3),by=receivable]
  df[,yprevious4:=lag(ycurrent,4),by=receivable]
  df[,yprevious5:=lag(ycurrent,5),by=receivable]
  df[is.na(yprevious1),yprevious1:=0]
  df[is.na(yprevious2),yprevious2:=0]
  df[is.na(yprevious3),yprevious3:=0]
  df[is.na(yprevious4),yprevious4:=0]
  df[is.na(yprevious5),yprevious5:=0]
  
  # 4.13 Fix NA and Infinite ycurrent values ----------------------------------
    
    # 4.13.1 Bound ycurrent by 0 and 1 (response needs to be binary) ----------
    df[,ycurrent:=pmax(ycurrent,0)]
    df[,ycurrent:=pmin(ycurrent,1)]
  
    # 4.13.2 If ycurrent is missing, set to previous value --------------------
    df <- setorder(df,Days)
    df[,ycurrent:=ifelse(is.na(ycurrent),lag(ycurrent),ycurrent),by=receivable]
    df[adjusted_default==0,ycurrent:=0]
    
  # 4.14 Calculate the yfinal variable ----------------------------------------
  df <- df[,yfinal:=ycurrent[which.max(Days)],by=receivable]
    
  # 4.15 Calculate days_diff (days since last transaction) --------------------
  df <- df[,days_diff:=Days-lag(Days,1),by=receivable]
  df <- df[is.na(days_diff),days_diff:=0]

  # 4.16 Create pred: active receivables (last record = current date) ---------
  pred <- setorder(df,receivable,Days)[isactive==1, .SD[.N], by="receivable"]
  pred <- pred[,applied:=Sys.time()]
  pred <- pred[,Days:=as.numeric(applied-incurred,units="days")]

  # 4.17 Set pred non-cumulative columns to zero ------------------------------
  exclusions <- c("isactive",
                  "receivable",
                  "incurred",
                  "applied",
                  "Days",
                  "Default",
                  "ycurrent",
                  "yfinal",
                  "days_diff",
                  "adjusted_default")
  
  exclusions <- c(exclusions,names(df)[grepl("c_",names(df))])
  inclusions <- setdiff(names(df),exclusions)
  
  pred <- pred[,(inclusions):=0]

  setcolorder(df,names(pred))
  df <- rbindlist(list(df,pred))

  # 4.18 Merge df with the demographic data -----------------------------------
  df <- merge(df,de,by.x="receivable",by.y="RECEIVABLE_ID",all.x=T)
  
  # 4.19 Remove duplicate columns ---------------------------------------------
  df <- data.frame(df)
  df <- df[!duplicated(as.list(df))]
  df <- data.table(df)

  # 4.20 Calculate the limitation period --------------------------------------
  
    # 4.20.1 Create new variable limitation.length ---------------------------
    df[,limitation.length:=numeric(nrow(df))]
    df[,limitation.length:=NA]
    
    # 4.20.2 Equal to limitation period when Days <= 0 ------------------------
    df[round(Days,0)<=0,limitation.length:=limitation.period*365]
    df[round(Days,0)<=0,Days.offset:=0]
    
    # 4.20.3 Equal to limitation period less Days when equal to min(Days) -----
    df[,min.Days:=min(Days),by=receivable]
    df[Days==min.Days,limitation.length:=limitation.period*365-Days]
    df[Days==min.Days,Days.offset:=Days]
    
    # 4.20.4 Equal to limitation period when recovery < 0 ---------------------
    df[Recovery<0,limitation.length:=limitation.period*365]
    df[Recovery<0,Days.offset:=Days]
    
    # 4.20.5 Carry forward non-NA limitation.length and Days.offset -----------
    setorder(df,receivable,Days)
    df[,limitation.length:=na.locf(limitation.length)]
    df[,Days.offset:=na.locf(Days.offset)]
    
    # 4.20.6 Offset limitation length by Days offset --------------------------
    df[,limitation.length:=limitation.length-Days+Days.offset]
    
    # 4.20.7 Tidy up ----------------------------------------------------------
    df[,Days.offset:=NULL]
    df[,min.Days:=NULL]

  # 4.21 Tidy up --------------------------------------------------------------
  rm(list=setdiff(ls(), c("df","t1")))
  for (i in 1:50) gc(reset=TRUE)
  
  # # 4.21 Write df to file to provide quick start for xgboost training ---------
  # fwrite(df,"df.csv")

