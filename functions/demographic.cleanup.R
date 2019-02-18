# Function to clean up demographic fields 
demographic_cleanup <- function(x,prefix){
  x <- tolower(x)
  x <- removePunctuation(x)
  x <- gsub(" ",".",x)
  x <- paste(prefix,x,sep='')
  x <- as.factor(x)
}