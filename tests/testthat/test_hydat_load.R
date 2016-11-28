context("Cleaning hydat dataset")


test_that("hydat_load successfully imports and cleans dataframe to be in long format",{
 x <- hydat_load(burpee)
 expect_equal(ncol(x), expected = 13)
 expect_equal(colnames(x)[1], expected = "station_name")
 expect_true(is.integer(x$year))
 expect_true(is.integer(x$month))
 expect_true(is.integer(x$dd))
 expect_true(is.numeric(x$measurement))

})
