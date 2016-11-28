
#' Annual flood distribution
#'
#' Generates annual flood distribution by arranging annual peak flows in ascending order and calculates proportion less than. Note: daily discharge values that are NA are omitted from this analysis. Check your data before processing.
#'
#' @param x a dataframe that has been processed through hydat_load
#'
#' @return returns a dataframe of annual peak discharges and the proportion of discharges less than
#' @import dplyr
#' @import magrittr
#' @export

hydat_flooddist <- function(x){

  arr_yrmax <- x %>%
    select(station_name, year, month, dd, measurement) %>%
    na.omit() %>%
    group_by(station_name, year) %>%
    summarize(max_q = max(measurement)) %>%
    ungroup() %>%
    arrange(max_q)
  arr_yrmax <- arr_yrmax %>%
    mutate(percentile = ((row_number())/nrow(arr_yrmax))*100,
           perc_exceeding = 100-percentile,
           recurrence_int = 1/(perc_exceeding/100))
  return(arr_yrmax)
}
