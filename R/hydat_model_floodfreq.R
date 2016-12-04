

#' model flood recurrence intervals
#'
#' @param x input dataset post-processed through `hydat_load`
#' @param logx logical input on whether to transform x variable with log10()
#' @param logy logical input on whether to transform y variable with log10()
#' @import ggplot2
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
  # Apply theme to all plots
  theme_dtavern <- theme(panel.background = element_rect(fill = "white"),
                         axis.line.y = element_line(colour="black", size = 0.25),
                         axis.line.x = element_line(colour="black", size = 0.25),
                         axis.title.x = element_text(face = "bold", size = 13),
                         axis.title.y = element_text(face = "bold", size = 13, margin = margin(10,10,5,10)),
                         axis.text.x = element_text(face = "bold", size = 10),
                         axis.text.y = element_text(size = 9),
                         legend.key = element_rect(fill = "white"),
                         legend.title = element_text(face = "bold", size = 11),
                         legend.text = element_text(size = 11),
                         legend.position = c(0.9, 0.6))
  ## diagnostic plots
  # Fitted line plot. Predicted y versus observed y.
  pvhat_plot <- ggplot(data = flooddist)+
    geom_point(aes(x=rec,y=yhat)) +
    labs(x="Recurrence",y="yhat", title = "Predicted vs. Actual") +
    geom_abline(intercept = 0, slope = 1) +
    theme_dtavern
  # Residual plot
  resid_plot <- ggplot(data = flooddist)+
    geom_point(aes(x=yhat, y=resid))+
    labs(x="yhat", y="Residual", title = "Residual plot")+
    geom_hline(yintercept = 0) +
    theme_dtavern
  # Normality plot
  qq_plot <- ggplot(data=flooddist) +
    stat_qq(aes(sample = resid)) +
    labs(x="Expected", y="Observed", title = "QQ Plot")+ ## Add QQ line?
    theme_dtavern
  # Histogram of residuals
  resid_hist <- ggplot(data=flooddist)+
    geom_histogram(aes(x = resid), bins = 10)+
    labs(x="Residual", y="Frequency", title = "Residual histogram")+
    theme_dtavern

  plots <- list(pvhat_plot, resid_plot, qq_plot, resid_hist)
  shapiro <- shapiro.test(flooddist$resid)
  output <- list(diagnostic_plots = plots, shapiro_normality = shapiro, model = flm, model_summary = sumflm)
  return(output)

}
