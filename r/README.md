# screen

[![](https://github.com/jasonjfoster/screen/actions/workflows/check-standard.yaml/badge.svg)](https://github.com/jasonjfoster/screen/actions/workflows/check-standard.yaml)
[![](https://codecov.io/gh/jasonjfoster/screen/graph/badge.svg)](https://app.codecov.io/github/jasonjfoster/screen)

## Overview

`yscreen` is a package that provides simple and efficient access to Yahoo Finance's screener functionality for querying and retrieval of financial data.

The core functionality of the screen package abstracts the complexities of interacting with Yahoo Finance APIs, such as session management, crumb and cookie handling, query construction, pagination, and JSON payload generation. This abstraction allows users to focus on filtering and retrieving data rather than managing API details. Use cases include screening across a range of asset classes:

* **Equities**: coverage spans 50 regions to enable the identification of top-performing stocks based on specified criteria
* **Mutual funds**: funds can be screened using metrics such as historical performance, performance ratings, and other factors
* **ETFs**: a wide range of ETFs can be filtered by criteria including expense ratio, historical performance, and additional attributes
* **Indices**: stock market indices are available and often categorized by sector, industry, or the overall market
* **Futures**: futures contracts can be screened by exchange, price percent changes, and regional specifications

The package supports advanced query capabilities, including logical operators, nested filters, and customizable payloads. It automatically handles pagination to ensure efficient retrieval of large datasets by fetching results in batches of up to 250 entries per request. Filters can be dynamically defined to accommodate a wide range of screening needs.

The implementation leverages standard HTTP libraries to handle API interactions efficiently and provides support for both R and Python to ensure accessibility for a broad audience.

## Installation

* Install the released version from CRAN:

```r
install.packages("screenr")
```

* Or the development version from GitHub:

```r
# install.packages("devtools")
devtools::install_github("jasonjfoster/screen/r")
```

* Or the latest version from r-universe:

```r
r_universe <- "https://jasonjfoster.r-universe.dev"
install.packages("screenr", repos = r_universe)
```

## Usage

First, load the package and explore the available filter options:

```r
library(screenr)

print(data_filters)
```

To create a query, define filters and use the `create_query` function:

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

Next, specify the security type and create the payload with the `create_payload` function:

```r
payload <- create_payload("equity", query)
```

Finally, retrieve the data using the `get_data` function:

```r
data <- get_data(payload)
```
