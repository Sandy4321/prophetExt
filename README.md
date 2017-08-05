
<!-- README.md is generated from README.Rmd. Please edit that file -->



# prophetExt

[![Travis-CI Build Status](https://travis-ci.org/hoxo-m/prophetExt.svg?branch=master)](https://travis-ci.org/hoxo-m/prophetExt)

Extension for Facebook [Prophet](https://github.com/facebookincubator/prophet).

## Installation

You can install prophetExt from github with:


```r
# install.packages("devtools")
devtools::install_github("hoxo-m/prophetExt")
```

or


```r
# install.packages("githubinstall")
githubinstall::githubinstall("prophetExt")
```

## Example

Ready data.


```r
df <- read.csv("https://raw.githubusercontent.com/facebookincubator/prophet/master/examples/example_wp_peyton_manning.csv")
df$y <- log(df$y)
```

Fit model.


```r
library(prophet)
m <- prophet(df)
```

Pick changepoints.


```r
library(prophetExt)
cpts <- prophet_pick_changepoints(m)
cpts
#>    changepoints  growth_rate       delta
#> 1    2007-12-10 -0.355170111  0.00000000
#> 2    2008-10-11 -0.005433292  0.34973682
#> 3    2009-01-14  0.453643069  0.45907636
#> 4    2009-10-26  0.212617070 -0.24102600
#> 5    2010-01-31 -0.032368395 -0.24498546
#> 6    2011-02-16  0.258211353  0.29057975
#> 7    2011-05-20  0.471607695  0.21339634
#> 8    2012-02-27 -0.377094625 -0.84870232
#> 9    2013-03-05  0.087664410  0.46475903
#> 10   2013-06-06  0.104119378  0.01645497
#> 11   2013-12-10 -0.239392370 -0.34351175
```

Draw changepoints.


```r
future <- make_future_dataframe(m, 365)
fore <- predict(m, future)
plot(m, fore) + prophet_gglayer(cpts)
```

![](README-draw-changepoints-1.png)<!-- -->

Detect outliers.


```r
outliers <- prophet_detect_outliers(m)
head(outliers)
```

Draw outliers.


```r
plot(m, fore) + prophet_gglayer(outliers)
```

![](README-draw-outliers-1.png)<!-- -->

Draw calendar plot.


```r
prophet_calendar_plot(outliers)
```

![](README-draw-calendar-plot-1.png)<!-- -->
