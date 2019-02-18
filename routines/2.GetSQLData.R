# 2.0 Get data from SQL scripts -----------------------------------------------
  
  # 2.1 Get Cases query -------------------------------------------------------
  cs <- arrm %>%
    sqlQuery(source(file="sql/Cases.sql"),stringsAsFactors=F) %>%
    data.table()
  
  # 2.2 Get Documents query ---------------------------------------------------
  dc <- arrm %>%
    sqlQuery(source(file="sql/Documents.sql"),stringsAsFactors=F) %>%
    data.table()
  
  # 2.3 Get demographic query -------------------------------------------------
  de <- arrm %>%
    sqlQuery(source(file="sql/Demographics.sql"),stringsAsFactors=F) %>%
    data.table()
  
  # 2.4 Get Legal Instruments query -------------------------------------------
  li <- arrm %>%
    sqlQuery(source(file="sql/LegalInstruments.sql"),stringsAsFactors=F) %>%
    data.table()
  
  # 2.5 Get Notes query ------------------------------------------------------
  nt <- arrm %>%
    sqlQuery(source(file="sql/ReceivableNotes.sql"),stringsAsFactors=F) %>%
    data.table()
  
  # 2.6 Get Repayment Plans query ---------------------------------------------
  rp <- arrm %>%
    sqlQuery(source(file="sql/RepaymentPlans.sql"),stringsAsFactors=F) %>%
    data.table()
  
  # 2.7 Get Receivble Status query --------------------------------------------
  rs <- arrm %>%
    sqlQuery(source(file="sql/ReceivableStatusDetail.sql"),stringsAsFactors=F) %>%
    data.table()
  
  # 2.8 Get Transfer In query -------------------------------------------------
  ti<- arrm %>%
    sqlQuery(source(file="sql/TransferIns.sql"),stringsAsFactors=F) %>%
    data.table()
  
  # 2.9 Get Transactions query ------------------------------------------------
  tr <- arrm %>%
    sqlQuery(source(file="sql/Transactions.sql"),stringsAsFactors=F) %>%
    data.table()
  
  # 2.10 Get Welcome Letter query ----------------------------------------------
  wl <- arrm %>%
    sqlQuery(source(file="sql/WelcomeLetters.sql"),stringsAsFactors=F) %>%
    data.table()
  
  # 2.11 Close ODBC connection ------------------------------------------------
  odbcCloseAll()
  rm(arrm)
  