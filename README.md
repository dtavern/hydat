# hydat

**Author/Creator:** David Tavernini

**Version** v0.1.0 - In progress

**Comments/debug info** taverninid@gmail.com

###STATUS

This package is currently unreleased and the first version (v0.1.0) is still being developed. At this point, it is just a seed of an idea and I am currently developing this package for an assignment in STAT545. Stay tuned for an official release. If you are looking for any specific functions or scripts, I am open to providing them to you.

### Disclaimer

Note that this package is my first package being written and I am rather new with R/GitHub/R Packages. This package is open for use by anyone, but I am not liable for any problems this package may cause directly or indirectly. Please let me know if there are any issues that you find with this package as I would love to fix any problems.

### About

The goal of the hydat package is to smoothly and efficiently tidy hydrometric data downloaded from the Government of Canada [Hydat database](https://wateroffice.ec.gc.ca/search/search_e.html?sType=h2oArc). The primary function contained in this package (`hydat_load`) was created to convert the downloaded daily discharge data .csv files to dataframes in "long" format. In later versions, other tools will be developed to quickly generate hydrographs, rating curves, to name a few.

### Installation

You can install this package directly from my github account using `devtools::install_github("dtavern/hydat")`

### Collaboration and Comments

Initiating this project came from wrestling .csv data in excel prior to analysis. I thought I would speed up some of the processes for anyone else interested in rivers. If you have any suggestions such as other tasks you think could be automated, or if you would like to add in your own tools within this package, feel free to contact me at taverninid@gmail.com. Also feel free to branch off and develop this package further in your own interests!

### Limitations

This package is specifically developed for daily discharge .csv files downloaded from the Wateroffice website. Any manipulation of these files may cause the functions in this package to not work correctly. However, in theory, these functions work with all station daily discharge files found on the hydat database.

### Dependencies

This package uses dplyr and ggplot from the tidyverse package. You can ensure all dependencies are met by installing the tidyverse from CRAN

```
install.packages("tidyverse")
library(tidyverse)
```

###Functions

**Current Functions:**

`hydat_load`: Takes in raw .csv file from hydat database, matches measurement codes and station codes to their actual meaning, and converts the table from wide format to long format for easy analysis.

`hydat_flooddist`: Takes in processed dataframe through `hydat_load` and generates a percentile value for annual peak flows..
