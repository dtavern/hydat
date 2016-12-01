

#' model flood recurrence intervals
#'
#' @param x input dataset post-processed through `hydat_load`
#'
#' @return returns linear model diagnostics and model result in a list format
#' @export
hydat_model_floodfreq <- function(x, logx = FALSE, logy = FALSE){
  flooddist <- hydat_flooddist(x)
  flooddist <- flooddist[1:(nrow(flooddist)-1),]
  if(logx){flooddist$q <- log10(flooddist$max_q)} else{flooddist$q <- flooddist$max_q}
  if(logx){flooddist$rec <- log10(flooddist$recurrence_int)} else{flooddist$rec <- flooddist$recurrence_int}



}
