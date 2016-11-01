library(tidyverse)
setwd("~/Documents/other_r_proj/hydat/csvs")
data_symb <- read_csv("DATA_SYMBOLS.csv")
stations <- read_csv("STATIONS.csv")

hydat_load <- function(path, discharge_obj = "discharge", levels_obj = "levels", monthly_meansQ = "mo_meanQ", monthly_meansLvl = "mo_meanLvl"){
  raw <- read_csv(path, skip = 1)
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
    unite_(col = colnames_dlyflow[i], from=c(colnames_dlyflow[i], colnames_dlycode[i]), remove = TRUE)
  }

  #Rename columns
  newnames <- colnames(raw)
  newnames[6:17] <- as.character(seq(1,12,by=1))
  colnames(raw) <- newnames

  ## Gather data into long format
  raw_tidy <- raw %>%
    gather(key = "month", value = "measurement", 6:17) %>%
    separate(measurement, c("measurement", "code"), sep = "_", remove = TRUE) %>%
    arrange(PARAM, YEAR, month, DD) %>%
    left_join(y = stations, by=c("ID" = "STATION_NUMBER")) %>%
    left_join(y = data_symb[1:2], by = c("code" = "SYMBOL_ID")) %>%
    select(STATION_NAME, PROV_TERR_STATE_LOC, PARAM, YEAR, month, DD, measurement, SYMBOL_EN, TYPE, LATITUDE, LONGITUDE,DRAINAGE_AREA_GROSS,DRAINAGE_AREA_EFFECT)
  colnames(raw_tidy) <- tolower(colnames(raw_tidy))
  raw_tidy$measurement <- as.numeric(raw_tidy$measurement)
  raw_tidy$month <- as.integer(raw_tidy$month)
  raw_tidy

  ## Separate data to discharge and level
  level <- raw_tidy %>%
    filter(param == "Level")
  discharge <- raw_tidy %>%
    filter(param == "Discharge")

  if(nrow(level) > 0){
    assign(levels_obj,level,.GlobalEnv)

    mo_meanLvl <- level %>%
      group_by(month) %>%
      summarize(mean_moLvl = mean(measurement, na.rm = TRUE),
                sd_moLvl = sd(measurement, na.rm = TRUE)) %>%
      ungroup()

    assign(monthly_meansLvl, mo_meanLvl, .GlobalEnv)
  } else {
    print("No entries of 'level' apparent in original dataset")
  }

  if(nrow(discharge)>0){
    assign(discharge_obj,discharge,.GlobalEnv)

    mo_meanQ <- discharge %>%
    group_by(month) %>%
    summarize(mean_moQ = mean(measurement, na.rm = TRUE),
            sd_moQ = sd(measurement, na.rm = TRUE)) %>%
    ungroup()

    assign(monthly_meansQ, mo_meanQ, .GlobalEnv)
  } else {
      print("No entries of 'discharge' apparent in original dataset")
    }
}



