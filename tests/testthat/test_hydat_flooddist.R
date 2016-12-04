context("Generate flood frequency")


test_that("hydat_flooddist successfully generates distribution of flood frequencies",{
  x <- hydat_load(burpee)
  y <- hydat_flooddist(x)
  expect_equal(max(y["percentile"]), expected = 100)
  expect_true(is.character(y$station_name))
  expect_true(is.integer(y$year))
  expect_true(is.numeric(y$max_q))
  expect_equal(min(y["perc_exceeding"]), expected = 0)
  expect_error(hydat_flooddist(burpee)) # Attempt to apply function on unprocessed data
})
