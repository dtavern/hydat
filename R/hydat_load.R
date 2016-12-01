
#' Clean hydat data
#'
#' Takes in a .csv file from the hydat database and converts it into 'long' format and splits into two user-defined objects for discharge and stage
#'
#' @param path the input path of the .csv file
#' @param return select output for either "discharge" or stream "level"
#' @param omit input vector of measurement codes you wish to omit. See object `datasymb` for measurement codes. Default includes all measurements
#' @param min_year input integer of lower bound for range of years. Default has no minimum year
#' @param max_year input integer of upper bound for range of years. Default has no maximum year
#' @param na.rm logical input. Will remove all days with no discharge measurements. Default setting will not remove any observations
#'
#' @return returns discharge or stage dataframe in long format
#' @import magrittr
#' @import dplyr
#' @export

hydat_load <- function(path, return = "discharge", omit = NULL, min_year = NULL, max_year = NULL, na.rm = FALSE){
  if(is.character(path)){
  raw <- utils::read.csv(path, skip = 1)} else{raw = path}

  if(ncol(raw)!= 29){
    stop(print("The number of variables is not equal to the expected value of 29. Please ensure your input file is unmodified from the HYDAT database."))}
  if(!is.character(omit) & !is.null(omit)){stop(print("Expected omitted paramaters to be character vector or NULL. Please consult ?hydat_load for more information."))}
  if(!is.numeric(min_year) & !is.null(min_year)){stop(print("min_year must be an integer value or NULL. Please consult ?hydat_load for more information."))}
  if(!is.numeric(max_year) & !is.null(max_year)){stop(print("max_year must be an integer value or NULL. Please consult ?hydat_load for more information."))}
  if(!is.logical(na.rm)){stop(print("na.rm mus be a logical statement. Please consult ?hydat_load for more information."))}

  ## Changes measurement codes to char
  raw$PARAM[raw$PARAM == 1] <- "Discharge"
  raw$PARAM[raw$PARAM == 2] <- "Level"
  raw$TYPE[raw$TYPE == 1] <- "m3/s"
  raw$TYPE[raw$TYPE == 8|raw$TYPE == 9] <- "m"

  ## Cleanup of .csv, grouping discharge and discharge codes together and ascending them in order of day #
  raw <- raw %>%
    select(1:5,seq(6, 28, by=2), seq(7,29,by=2))

  ## Extract lists of column names for the discharge days and the discharge codes
  colnames_dlyflow <- colnames(raw[6:17])
  colnames_dlycode <- colnames(raw[18:29])

  ## For each of the days, unite discharge and discharge code together
  for (i in 1:length(colnames_dlyflow)) {
    raw <- raw %>%
      tidyr::unite_(col = colnames_dlyflow[i], from=c(colnames_dlyflow[i], colnames_dlycode[i]), remove = TRUE)
  }

  #Rename columns
  newnames <- colnames(raw)
  newnames[6:17] <- as.character(seq(1,12,by=1))
  colnames(raw) <- newnames

  ## Filter according to omits
  measurement_filter <- c(datasymb$SYMBOL_ID, "")
  if(is.character(omit)){measurement_filter <- setdiff(measurement_filter, omit)}
  ## Gather data into long format
  raw_tidy <- raw %>%
    tidyr::gather(key = "month", value = "measurement", 6:17) %>%
    tidyr::separate(measurement, c("measurement", "code"), sep = "_", remove = TRUE) %>%
    dplyr::arrange(PARAM, YEAR, month, DD) %>%
    dplyr::filter(code %in% measurement_filter) %>%
    dplyr::left_join(y = stations, by=c("ID" = "STATION_NUMBER")) %>%
    dplyr::left_join(y = datasymb[1:2], by = c("code" = "SYMBOL_ID")) %>%
    dplyr::select(STATION_NAME, PROV_TERR_STATE_LOC, PARAM, YEAR, month, DD, measurement,SYMBOL_EN, TYPE, LATITUDE, LONGITUDE,DRAINAGE_AREA_GROSS,DRAINAGE_AREA_EFFECT)
  colnames(raw_tidy) <- tolower(colnames(raw_tidy))
  raw_tidy$measurement <- as.numeric(raw_tidy$measurement)
  raw_tidy$month <- as.integer(raw_tidy$month)
  raw_tidy
  minyr <- if(is.null(min_year)){min(raw_tidy$year)} else{min_year}
  maxyr <- if(is.null(max_year)){max(raw_tidy$year)} else{max_year}
  raw_tidy <- raw_tidy %>%
    dplyr::filter(year >= minyr & year <= maxyr)

  if(na.rm == TRUE){
    raw_tidy <- raw_tidy[!is.na(raw_tidy$measurement),]
  }

  ## Separate data to discharge and level
  level <- raw_tidy %>%
    dplyr::filter(param == "Level")
  discharge <- raw_tidy %>%
    dplyr::filter(param == "Discharge")

  ## Takes the argument `return` to return either discharge values or stage values.
  if(return == "discharge"){
    return(discharge)
  }
  if(return == "level"){
    return(level)
  }
  else{
    print("Not a valid return argument. You may only return discharge or level data")
  }
}




