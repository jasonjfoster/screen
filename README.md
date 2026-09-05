# screen

## Overview

'screen' provides simple and efficient access to Yahoo Finance's screener API <https://finance.yahoo.com/research-hub/screener/> for querying and retrieving financial data.

The 'screen' package abstracts the complexities of interacting with Yahoo Finance APIs, such as session management, crumb and cookie handling, query construction, pagination, and JSON payload generation. This abstraction allows users to focus on filtering and retrieving data rather than managing API details. Use cases include screening across a range of security types:

* **Equities**: coverage spans 50 regions for identifying top-performing stocks by specified criteria
* **Mutual funds**: screened by metrics such as historical performance and performance ratings
* **ETFs**: filtered by criteria including expense ratio and historical performance
* **Indices**: stock market indices covering sectors, industries, or the overall market
* **Futures**: contracts screened by exchange, percent price change, and region

The package supports advanced query capabilities, including logical operators, nested filters, and customizable payloads. It automatically handles pagination for efficient retrieval of large datasets by fetching results in batches of up to 250 entries per request. Filters are defined as lists of conditions to accommodate a wide range of screens.

The implementation uses standard HTTP libraries to handle API interactions efficiently and supports both R and Python to make it accessible for a broad audience.
