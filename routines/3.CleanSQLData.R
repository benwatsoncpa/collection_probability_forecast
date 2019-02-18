# 3.0 Clean data from SQL query 
  # 3.1 Demographic query cleanup ---------------------------------------------
    # 3.1.1 Calculate the limitation period -----------------------------------
    source("./functions/limitation.period.R")
    de[is.na(PROVINCE),PROVINCE:="Missing"]
    de[,limitation.period:=limitation_period(PROVINCE,INCURRED,PROGRAM_NAME)]

    # 3.1.2 Clean up missing values ------------------------------------------- 
    de[is.na(PROVINCE),PROVINCE:="blank"]
    de[is.na(PRODUCER_ORG),PRODUCER_ORG:="blank"]
    de[is.na(START_YEAR),START_YEAR:=0]
    de[is.na(END_YEAR),END_YEAR:=0]
    
    # 3.1.3 Apply demographic cleanup function --------------------------------
    source("./functions/demographic.cleanup.R")
    de[,RECEIVABLE_TYPE:=demographic_cleanup(RECEIVABLE_TYPE,"receivabletype_")]
    de[,DEBTOR_TYPE:=demographic_cleanup(DEBTOR_TYPE,"debtortype_")]
    de[,PROVINCE:=demographic_cleanup(PROVINCE,"province_")]
    de[,PROGRAM_NAME:=demographic_cleanup(PROGRAM_NAME,"program_")]
    de[,PRODUCER_ORG:=demographic_cleanup(PRODUCER_ORG,"producer_")]

    # 3.1.4 Create program year variable --------------------------------------
    de[,PROGRAM_YEAR:=paste("program_year",START_YEAR,END_YEAR,sep="_")]
    de$PROGRAM_YEAR <- as.factor(de$PROGRAM_YEAR)
    de$START_YEAR <- NULL
    de$END_YEAR <- NULL
    
    # 3.1.5 Calculate birth year ----------------------------------------------
    de$BIRTH_YEAR <- year(de$BIRTH_DATE)
    de[is.na(BIRTH_YEAR),BIRTH_YEAR:=0]
    de$BIRTH_DATE <- NULL
    

    # 3.1.6 One hot encode all the factor variables using dcast ----------------
    de1 <- dcast(de,RECEIVABLE_ID~RECEIVABLE_TYPE,fun=length,value.var="PROVINCE")
    de2 <- dcast(de,RECEIVABLE_ID~DEBTOR_TYPE,fun=length,value.var="PROVINCE")
    de3 <- dcast(de,RECEIVABLE_ID~PROVINCE,fun=length,value.var="PROVINCE")
    de4 <- dcast(de,RECEIVABLE_ID~PROGRAM_YEAR,fun=length,value.var="PROVINCE")
    de5 <- dcast(de,RECEIVABLE_ID~PROGRAM_NAME,fun=length,value.var="PROVINCE")
    de6 <- dcast(de,RECEIVABLE_ID~PRODUCER_ORG,fun=length,value.var="PROVINCE")
    
    # 3.1.7 Remove all one hot encoded fields ---------------------------------
    de <- de %>%
      select(-RECEIVABLE_TYPE,
             -DEBTOR_TYPE,
             -PROVINCE,
             -PROGRAM_YEAR,
             -PROGRAM_NAME,
             -PRODUCER_ORG) %>%
      data.table() 

    # 3.1.8 Set keys for de:de6 to RECEIVABLE_ID -----------------------------
    setkey(de,RECEIVABLE_ID)
    setkey(de1,RECEIVABLE_ID)
    setkey(de2,RECEIVABLE_ID)
    setkey(de3,RECEIVABLE_ID)
    setkey(de4,RECEIVABLE_ID)
    setkey(de5,RECEIVABLE_ID)
    setkey(de6,RECEIVABLE_ID)
    
    # 3.1.9 Merge de:de6 into de and tidy up ----------------------------------
    de <- merge(de,de1,all.x=T)
    de <- merge(de,de2,all.x=T)
    de <- merge(de,de3,all.x=T)
    de <- merge(de,de4,all.x=T)
    de <- merge(de,de5,all.x=T)
    de <- merge(de,de6,all.x=T)
    
    rm(de1,de2,de3,de4,de5,de6)
    
  # 3.2 Rename all tables (except de) -----------------------------------------
  names.string <- c("receivable",
                    "isactive",
                    "applied",
                    "incurred",
                    "balance",
                    "amount",
                    "type",
                    "subtype")
    
  names(li) <- names.string
  names(tr) <- names.string
  names(ti) <- names.string
  names(wl) <- names.string
  names(cs) <- names.string
  names(rp) <- names.string
  names(dc) <- names.string
  names(nt) <- names.string
  names(rs) <- c("receivable","eff.date","isactive","status")
    
  
  # 3.3 Misc. changes ---------------------------------------------------------
    # 3.3.1 Set applied to incurred if null (transfer in's) -------------------
    ti[is.na(applied),applied:=incurred]
    
    # 3.3.2 Filter missing values (welcome letters and legal instruments) -----
    li <- li[!is.na(applied)]
    wl <- wl[!is.na(applied) & applied > as.Date("1980-01-01")]
    
    # 3.3.3 Set missing amounts to zero (transfer in's) -----------------------
    ti[is.na(amount),amount:=0]
    
    # 3.3.4 Shorten balance field (transactions) ------------------------------
    tr[,balance:=gsub("Administrative Charge","Admin",balance)]
    
  # 3.4 Fix Deletion Amounts --------------------------------------------------
    
    # 3.4.1 Read deletion adjustments file ------------------------------------
    del.adj <- fread("./data/deletions.adjustments.csv")
    
    # 3.4.2 Get receivables for each type of treatment ------------------------ 
    adj1 <- del.adj[grepl("If deletion",TREATMENT)]$RECEIVABLE_ID
    adj2 <- del.adj[grepl("Multiply by -1",TREATMENT)]$RECEIVABLE_ID
    rm.these.receivables <- del.adj[TREATMENT=="Need manual review"]
  
    # 3.4.3 Adjust deletion transactions based on treatment -------------------
    tr[receivable %in% adj1 & applied <= as.Date("2011-08-16") & subtype=="Deletion Adjustment" & amount>0,amount:=-amount]
    tr[receivable %in% adj2 & subtype=="Deletion Adjustment",amount:=-amount]
  
  # 3.5 Rbind all imported ARRM tables ----------------------------------------
  df <- setDT(rbind(tr,ti,wl,cs,rp,dc,nt,li))
  
  # 3.6 Remove receivables that don't reconcile -------------------------------
  df <- df[!(receivable %in% rm.these.receivables)]
  
  # 3.7 Remove up receivables with zero defaults or that were reversed --------
    # 3.7.1 Find receivables that were reversed -------------------------------
    reversed.defaults <- df %>%
      filter(type=="Default" & balance=="Principal" | (balance=="Principal" & type=="Adjustment" & subtype!="Deletion Adjustment" & subtype!="Reimbursement")) %>%
      group_by(receivable) %>%
      summarise(amount=round(sum(amount),2)) %>%
      filter(amount==0) %>%
      data.table()
    
    # 3.7.2 Find receivables with 0 principle default -------------------------
    zero.defaults <- df %>%
      filter(type=="Default" & balance=="Principal" & amount==0) %>%
      data.table()
  
    # 3.7.3 Combine reversed and zero default receivables ---------------------
    rm <- c(reversed.defaults$receivable,zero.defaults$receivable)
  
    # 3.7.4 Filter df to exclude receivables these receivables ----------------
    df <- df[!(receivable %in% rm)]
    rm(list=setdiff(ls(),c("de","df","rs")))
  # 3.8 Remove all receivables that are "Returned to program" -----------------
  df <- df[!receivable %in% rs[status=="Closed - Returned to Program"]$receivable]
  
  # 3.9 Make backup and Tidy Up -----------------------------------------------
  rm(list=setdiff(ls(),c("df","rs","de")))
  df.backup <- df