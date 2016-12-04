## ------------------------------------------------------------------------
library(hydat)
library(ggplot2)
x <- hydat_load(burpee, omit = "E", na.rm = TRUE)

## ------------------------------------------------------------------------
xdist <- hydat_flooddist(x)

## ------------------------------------------------------------------------
ggplot(data = xdist, aes(y = recurrence_int, x = max_q)) +
  geom_line() +
  scale_x_log10()+
  scale_y_log10()

