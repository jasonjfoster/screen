\name{screenr-package}
\alias{screenr-package}
\alias{screenr}
\docType{package}
\title{
  \packageTitle{screenr}
}
\description{
  \packageDescription{screenr}
}
\details{

  \code{screenr} is a package that provides simple and efficient access to Yahoo Finance's screener functionality for querying and retrieval of financial data.

  The core functionality of the screen package abstracts the complexities of interacting with Yahoo Finance APIs, such as session management, crumb and cookie handling, query construction, pagination, and JSON payload generation. This abstraction allows users to focus on filtering and retrieving data rather than managing API details. Use cases include screening across a range of asset classes:

  \itemize{
    \item \strong{Equities}: coverage spans 50 regions to enable the identification of top-performing stocks based on specified criteria
    \item \strong{Mutual funds}: funds can be screened using metrics such as historical performance, performance ratings, and other factors
    \item \strong{ETFs}: a wide range of ETFs can be filtered by criteria including expense ratio, historical performance, and additional attributes
    \item \strong{Indices}: stock market indices are available and often categorized by sector, industry, or the overall market
    \item \strong{Futures}: futures contracts can be screened by exchange, price percent changes, and regional specifications
  }

  The implementation leverages standard HTTP libraries to handle API interactions efficiently and provides support for both R and Python to ensure accessibility for a broad audience.
}
\author{
  \packageAuthor{screenr}
}
