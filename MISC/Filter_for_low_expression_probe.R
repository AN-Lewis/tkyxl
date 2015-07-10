# a function to filter low expressing genes

filter <- function(x){
  if (length(x[x>=1]) >=2){return(TRUE)}else{return(FALSE)}
}

logic <- apply(d.Raw,1,filter)
length(logic[logic ==TRUE])
d <- d.Raw[logic,,keep.lib.sizes=FALSE]
