\name{yfscreen-package}
\alias{yfscreen-package}
\alias{yfscreen}
\docType{package}
\title{
  \packageTitle{yfscreen}
}
\description{
  \packageDescription{yfscreen}
}
\details{

  \code{yfscreen} is a package that provides simple and efficient access to Yahoo Finance's screener API for querying and retrieving financial data.

  The core functionality of the \code{yfscreen} package abstracts the complexities of interacting with Yahoo Finance APIs, such as session management, crumb and cookie handling, query construction, pagination, and JSON payload generation. This abstraction allows users to focus on filtering and retrieving data rather than managing API details. Use cases include screening across a range of security types:

  \itemize{
    \item \strong{Equities}: coverage spans 50 regions for identifying top-performing stocks by specified criteria
    \item \strong{Mutual funds}: screened by metrics such as historical performance and performance ratings
    \item \strong{ETFs}: filtered by criteria including expense ratio and historical performance
    \item \strong{Indices}: stock market indices covering sectors, industries, or the overall market
    \item \strong{Futures}: contracts screened by exchange, percent price change, and region
  }

  The implementation uses standard HTTP libraries to handle API interactions efficiently and supports both R and Python to make it accessible for a broad audience.
}
\author{
  \packageAuthor{yfscreen}
}
