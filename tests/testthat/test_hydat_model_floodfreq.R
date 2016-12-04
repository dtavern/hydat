context("fit model and provide diagnostics")


test_that("model fits correctly and outputs into list format",{
  x <- hydat_model_floodfreq(hydat_load(burpee))
  expect_equal(length(x), expected = 4)
  expect_true(is.list(x))
  expect_true(is.list(x[1]))
  expect_true(is.list(x[2]))
  expect_true(is.list(x[3]))
  expect_true(is.list(x[4]))
  expect_error(hydat_model_floodfreq(burpee)) ## Tests to see if function applies successfully on unprocessed data (it shouldn't)

})
