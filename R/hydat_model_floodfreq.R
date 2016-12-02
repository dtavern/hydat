

#' model flood recurrence intervals
#'
#' @param x input dataset post-processed through `hydat_load`
#' @param logx logical input on whether to transform x variable with log10()
#' @param logy logical input on whether to transform y variable with log10()
#'
#' @return returns linear model diagnostics and model result in a list format
#' @export

hydat_model_floodfreq <- function(x, logx = FALSE, logy = FALSE){
  flooddist <- hydat_flooddist(x)
  flooddist <- flooddist[1:(nrow(flooddist)-1),]
  if(logx){flooddist$q <- log10(flooddist$max_q)} else{flooddist$q <- flooddist$max_q}
  if(logx){flooddist$rec <- log10(flooddist$recurrence_int)} else{flooddist$rec <- flooddist$recurrence_int}
  flm <- lm(flooddist$rec ~ flooddist$q)
  sumflm <- summary(flm)

  ## Residuals save as col
  flooddist$yhat <- fitted(flm)
  flooddist$resid <- residuals(flm)
  flooddist$stdresid <- residuals(flm)/sumflm$sigma

  ## diagnostic plots

    par(mfrow=c(2,2),cex=1.0,mai=c(1.1,1.1,0.5,0.4))
  # Fitted line plot. Predicted y versus observed y.
  plot(flooddist$yhat~flooddist$rec,xlab="recurrence",
       ylab="yhat",main="Predicted vs Actual",
       pch=19)
  abline(a=0,b=1,col="red")
  # Residual plot
  plot(flooddist$yhat, flooddist$resid,xlab = "yhat",
       ylab = "Residual",main = "Residual Plot",pch = 19)
  abline(h=0, col="red")
  # Normality plot
  qqnorm(flooddist$resid, ylab = "Residual", pch =19)
  qqline(flooddist$resid, col ="red")
  # Histogram of residuals
  hist(flooddist$resid,breaks = 10,xlab = "Residual",
       main = "Residuals", col="grey", border="black")
  par(mfrow=c(1,1),cex=1.0,mai=c(1.0,1.0,1.0,1.0))
  diag_plots <-recordPlot()
  plot.new()

  shapiro <- shapiro.test(flooddist$resid)
  output <- list(diagnostic_plots = diag_plots, shapiro_normality = shapiro, model = flm, model_summary = sumflm)
  return(output)

}
