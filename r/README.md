# screen

[![GitHub Actions](https://github.com/jasonjfoster/screen/actions/workflows/check-standard.yaml/badge.svg)](https://github.com/jasonjfoster/screen/actions/workflows/check-standard.yaml)
[![CRAN version](https://www.r-pkg.org/badges/version/yfscreen)](https://cran.r-project.org/package=yfscreen)
[![codecov](https://codecov.io/gh/jasonjfoster/screen/graph/badge.svg)](https://app.codecov.io/github/jasonjfoster/screen)
[![Downloads](https://cranlogs.r-pkg.org/badges/yfscreen?color=brightgreen)](https://www.r-pkg.org/pkg/yfscreen)

## Overview

'yfscreen' provides simple and efficient access to Yahoo Finance's 'screener' API <https://finance.yahoo.com/research-hub/screener/> for querying and retrieving financial data.

The 'yfscreen' package abstracts the complexities of interacting with Yahoo Finance APIs, such as session management, crumb and cookie handling, query construction, pagination, and JSON payload generation. This abstraction allows users to focus on filtering and retrieving data rather than managing API details. Use cases include screening across a range of security types:

* **Equities**: coverage spans 50 regions for identifying top-performing stocks based on specified criteria
* **Mutual funds**: screened by metrics such as historical performance, performance ratings, and other factors
* **ETFs**: filtered by criteria including expense ratio, historical performance, and additional attributes
* **Indices**: stock market indices categorized by sector, industry, or the overall market
* **Futures**: contracts screened by exchange, price percent changes, and regional specifications

The package supports advanced query capabilities, including logical operators, nested filters, and customizable payloads. It handles pagination automatically, fetching results in batches of up to 250 entries per request for efficient retrieval of large datasets. Filters can be defined dynamically to support a wide range of screening needs.

The implementation uses standard HTTP libraries to handle API interactions efficiently and is available in both R and 'Python' for accessibility to a broad audience.

## Installation

* Install the released version from CRAN:

```r
install.packages("yfscreen")
```

* Or the development version from GitHub:

```r
# install.packages("devtools")
devtools::install_github("jasonjfoster/screen/r")
```

## Usage

First, load the package and explore the available filter options:

```r
library(yfscreen)

print(data_filters)
```

To create a query, define filters and use the `create_query()` function:

```r
filters <- list(
  list("eq", list("region", "us")),
  list("btwn", list("intradaymarketcap", 2000000000, 10000000000)),
  list("btwn", list("intradaymarketcap", 10000000000, 100000000000)),
  list("gt", list("intradaymarketcap", 100000000000)),
  list("gt", list("dayvolume", 5000000))
)

query <- create_query(filters)
```

Next, specify the security type and create the payload with the `create_payload()` function:

```r
payload <- create_payload("equity", query)
```

Finally, retrieve the data using the `get_data()` function:

```r
data <- get_data(payload)
```