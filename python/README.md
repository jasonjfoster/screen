# screen

[![PyPI version](https://img.shields.io/pypi/v/yfscreen?label=PyPI&color=brightgreen)](https://pypi.org/project/yfscreen/)
[![codecov](https://codecov.io/gh/jasonjfoster/screen/graph/badge.svg)](https://app.codecov.io/github/jasonjfoster/screen)
[![Downloads](https://img.shields.io/pypi/dm/yfscreen?color=brightgreen)](https://pypistats.org/packages/yfscreen)

## Overview

'yfscreen' provides simple and efficient access to Yahoo Finance's screener API <https://finance.yahoo.com/research-hub/screener/> for querying and retrieving financial data.

The 'yfscreen' package abstracts the complexities of interacting with Yahoo Finance APIs, such as session management, crumb and cookie handling, query construction, pagination, and JSON payload generation. This abstraction allows users to focus on filtering and retrieving data rather than managing API details. Use cases include screening across a range of security types:

* **Equities**: coverage spans 50 regions for identifying top-performing stocks by specified criteria
* **Mutual funds**: screened by metrics such as historical performance and performance ratings
* **ETFs**: filtered by criteria including expense ratio and historical performance
* **Indices**: stock market indices covering sectors, industries, or the overall market
* **Futures**: contracts screened by exchange, percent price change, and region

The package supports advanced query capabilities, including logical operators, nested filters, and customizable payloads. It automatically handles pagination for efficient retrieval of large datasets by fetching results in batches of up to 250 entries per request. Filters are defined as lists of conditions to accommodate a wide range of screens.

The implementation uses standard HTTP libraries to handle API interactions efficiently and supports both R and Python to make it accessible for a broad audience.

## Installation

* Install the released version from PyPI:

```python
pip install yfscreen
```

* Or the development version from GitHub:

```python
pip install git+https://github.com/jasonjfoster/screen.git@main#subdirectory=python
```

## Usage

First, import the package and explore the available filter options:

```python
import yfscreen as yfs

print(yfs.data_filters)
```

To create a query, define filters and use the `create_query()` function:

```python
filters = [
  ["eq", ["region", "us"]],
  ["btwn", ["intradaymarketcap", 2000000000, 10000000000]],
  ["btwn", ["intradaymarketcap", 10000000000, 100000000000]],
  ["gt", ["intradaymarketcap", 100000000000]],
  ["gt", ["dayvolume", 5000000]]
]

query = yfs.create_query(filters)
```

Next, specify the security type and create the payload with the `create_payload()` function:

```python
payload = yfs.create_payload("equity", query)
```

Finally, retrieve the data using the `get_data()` function:

```python
data = yfs.get_data(payload)
```
