# 1.0 Connect to the ARRMS Database using RODBC -------------------------------

arrm<-odbcConnect("ARRM64",
                  uid="arrm_frms_ro",
                  pwd="ntU7n_P",
                  believeNRows=F)