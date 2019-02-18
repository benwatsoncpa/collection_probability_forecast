# 7.0 Append Xgboost predictions to ARRMS Database ----------------------------

arrm <- odbcConnect("",
                    uid="", 
                    pwd="", 
                    believeNRows=F)

lapply(sqls, function(s) sqlQuery(arrm, s))

odbcCloseAll()