library(prophet)
context("prophet_pick_changepoints")

ds <- as.Date("2017-01-01") + 0:99

trend <- c(rep(1, 50), rep(-1, 50))
adjust <- c(rep(0, 50), rep(100, 50))
set.seed(314)
y <- trend * 1:100 + rnorm(100, adjust, 3)
df <- data.frame(ds, y)
m <- prophet(df, weekly.seasonality = FALSE, yearly.seasonality = FALSE)

set.seed(314)
df_nochange <- data.frame(ds, y = rnorm(100))
m_nochange <- prophet(df_nochange,
                      weekly.seasonality = FALSE, yearly.seasonality = FALSE)

test_that("Basic", {
  cpts <- prophet_pick_changepoints(m)
  expect_equal(nrow(cpts), 8L)
  expect_true(all(abs(cpts$delta[-1]) >= 10^-2))
})

test_that("digits", {
  cpts <- prophet_pick_changepoints(m, digits = 1)
  expect_equal(nrow(cpts), 7L)
  expect_true(all(abs(cpts$delta[-1]) >= 10^-1))
})

test_that("no change", {
  cpts <- prophet_pick_changepoints(m_nochange)
  expect_equal(nrow(cpts), 1L)
})
