# Calculate the limitation period which is based on the province that the 
# debtor is from, when the advance was incurred and the program

limitation_period <- Vectorize(function(province,incurred,program){
  if (grepl("AMPA",program) && incurred >= as.Date("2008-02-28")) {out=6}
  else if (province=="Quebec"){out=3}
  else if (province=="Ontario"){out=2}
  else if (province=="Saskatchewan" && incurred >=as.Date("2005-05-01")){out=2}
  else if (province=="Alberta" && !grepl("AMPA",program)){out=2}
  else{out=6}
  
  return(out)
})


