# 7.0 Append Xgboost predictions to ARRMS Database ----------------------------

arrm <- odbcConnect("ARRM64_UAT",
                    uid="ARRM_FRMS_RO", 
                    pwd="nkZ_7Qug", 
                    believeNRows=F)

lapply(sqls, function(s) sqlQuery(arrm, s))

odbcCloseAll()