library(prophet)
context("prophet_pick_changepoints")

df <- read.csv("https://raw.githubusercontent.com/facebookincubator/prophet/master/examples/example_wp_peyton_manning.csv")
df$y <- log(df$y)
m <- prophet(df)

test_that("Basic", {
  cpts <- prophet_pick_changepoints(m)
  expect_equal(nrow(cpts), 11L)
})

test_that("digits", {
  cpts <- prophet_pick_changepoints(m, digits = 1)
  expect_equal(nrow(cpts), 10L)
})
