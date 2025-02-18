process_filter <- function(filter) {

  result <- list(
    operator = filter[[1]],
    operands = lapply(filter[[2]], function(operand) {
      if (is.list(operand)) {
        process_filter(operand)
      } else {
        operand
      }
    })
  )

  return(result)

}

process_url <- function(params) {
  paste0("?", paste(names(params), params, sep = "=", collapse = "&"))
}

process_cols <- function(df) {

  for (col in colnames(df)) {

    if (all(vapply(df[[col]], is.list, logical(1)))) {

      status_df <- all(vapply(df[[col]], is.data.frame, logical(1)))

      if (status_df) {

        cols <- lapply(df[[col]], function(x) {
          colnames(jsonlite::flatten(x))
        })
        cols <- unique(unlist(cols))

        row_na <- data.frame(matrix(NA, nrow = 1, ncol = length(cols),
                                    dimnames = list(NULL, cols)))

        result_ls <- lapply(df[[col]], function(x) {

          x <- jsonlite::flatten(x)

          if (nrow(x) == 0) {
            return(row_na)
          } else {

            cols_na <- setdiff(cols, colnames(x))

            for (col_na in cols_na) {
              x[[col_na]] <- NA
            }

            x[1, cols, drop = FALSE]
          }

        })

        result <- do.call(rbind, result_ls)
        df <- cbind(df, result)

        df[[col]] <- NULL

      } else {
        df[[col]] <- NA
      }

    }
  }

  return(df)

}

##' Create a Structured Query for the Yahoo Finance API
##'
##' A function to create a list defining a query for the Yahoo Finance API with
##' logical operations and nested conditions defined in a structured format.
##'
##' @param filters list. Each element is a sublist defining a filtering condition.
##' Each sublist must contain:
##' \describe{
##'   \item{\code{operator}}{string. Logical operation for the condition (i.e. "and", "or").}
##'   \item{\code{operands}}{list. Conditions or nested subconditions.}
##'    Each condition includes:
##'   \describe{
##'     \item{\code{comparison}}{string. Comparison operator (i.e., "gt", "lt", "eq", "btwn").}
##'     \item{\code{field}}{list. Field name (e.g. "region") and its associated value(s).}
##'   }
##' }
##' @param top_operator string. Top-level logical operator to combine all filters (i.e., "and", "or").
##' @return A nested list representing the query with logical operations and
##' nested conditions formatted for the Yahoo Finance API.
##' @examples
##' filters <- list(
##'   list("or", list(
##'     list("eq", list("region", "us"))
##'   )),
##'   list("or", list(
##'     list("btwn", list("intradaymarketcap", 2000000000, 10000000000)),
##'     list("btwn", list("intradaymarketcap", 10000000000, 100000000000)),
##'     list("gt", list("intradaymarketcap", 100000000000))
##'   )),
##'   list("or", list(
##'     list("gt", list("dayvolume", 5000000))
##'   ))
##' )
##'
##' query <- create_query(filters)
##' @export
create_query <- function(filters = list(list("or", list(list("eq", list("region", "us"))))),
                         top_operator = "and") {

  result <- list(
    operator = top_operator,
    operands = lapply(filters, process_filter)
  )

  return(result)

}

##' Create a Payload for the Yahoo Finance API
##'
##' A function to create a payload to query the Yahoo Finance API with customizable parameters.
##'
##' @param quote_type string. Type of quote to search
##' (i.e., "equity", "mutualfund", "etf", "index", "future").
##' @param query list. Structured query to filter results created by
##' the \code{\link{create_query}} function.
##' @param size integer. Number of results to return.
##' @param offset integer. Starting position of the results.
##' @param sort_field string. Field to sort the results.
##' @param sort_type string. Type of sort to apply (i.e., "asc", "desc").
##' @param top_operator string. Logical operator for the top-level of the query
##' (i.e., "and", "or")
##' @return A list representing the payload to be sent to the Yahoo Finance API
##' with the specified parameters.
##' @examples
##' filters <- list(
##'   list("or", list(
##'     list("eq", list("region", "us"))
##'   ))
##' )
##'
##' query <- create_query(filters)
##'
##' payload <- create_payload(
##'   quote_type = "equity", query = query,
##'   size = 25, offset = 0,
##'   sort_field = "intradaymarketcap", sort_type = "desc",
##'   top_operator = "and"
##' )
##' @export
create_payload <- function(quote_type = "equity", query = create_query(),
                           size = 25, offset = 0,
                           sort_field = NULL, sort_type = NULL,
                           top_operator = "and") {

  result <- list(
    includeFields = NULL, # unable to modify the result
    offset = offset,
    query = query,
    quoteType = quote_type,
    size = size,
    sortField = sort_field,
    sortType = sort_type,
    topOperator = top_operator
  )

  return(result)

}

##' Get the Crumb, Cookies, and Handle for Yahoo Finance API
##'
##' A function to get the crumb, cookies, and handle required to authenticate and interact
##' with the Yahoo Finance API.
##'
##' @return A list containing the following elements:
##' \item{handle}{A curl handle object to be used for subsequent requests.}
##' \item{crumb}{A string representing the crumb value for authentication.}
##' \item{cookies}{A data frame of cookies retrieved during the request.}
##' @examples
##' session <- get_session()
##' @export
get_session <- function() {

  handle <- curl::new_handle()

  api_url <- "https://query1.finance.yahoo.com/v1/test/getcrumb"

  headers <- c(
    `Accept` = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
    `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
  )

  curl::handle_setheaders(handle, .list = headers)

  response <- curl::curl_fetch_memory(api_url, handle = handle)
  crumb <- rawToChar(response$content)

  cookies <- curl::handle_cookies(handle)

  result <- list(
    handle = handle,
    crumb = crumb,
    cookies = cookies
  )

  return(result)

}

##' Get Screen Data from the Yahoo Finance API
##'
##' A function to send a payload to the Yahoo Finance API and get data for the screen.
##'
##' @param payload list. Payload to send to the Yahoo Finance API created using
##' the \code{\link{create_query}} and \code{\link{create_payload}} functions.
##' @return A data frame containing data from the Yahoo Finance API for the specified screen.
##'
##' @examples
##' filters <- list(
##'   list("or", list(
##'     list("eq", list("region", "us"))
##'   ))
##' )
##'
##' query <- create_query(filters)
##'
##' payload <- create_payload(
##'   quote_type = "equity", query = query,
##'   size = 25, offset = 0,
##'   sort_field = "intradaymarketcap", sort_type = "desc",
##'   top_operator = "and"
##' )
##'
##' screen <- get_screen(payload)
##' @export
get_screen <- function(payload = create_payload()) {

  session <- get_session()

  crumb <- session[["crumb"]]
  cookies <- session[["cookies"]]
  handle <- session[["handle"]]

  params <- list(
    crumb = crumb,
    lang = "en-US",
    region = "US",
    formatted = "true",
    corsDomain = "finance.yahoo.com"
  )

  api_url <- paste0("https://query1.finance.yahoo.com/v1/finance/screener", process_url(params))

  json_payload <- jsonlite::toJSON(payload, auto_unbox = TRUE)

  headers <- c(
    `Content-Type` = "application/json",
    `Cookie` = paste0(cookies[["name"]], "=", cookies[["value"]], collapse = "; ")
  )

  max_size <- 250
  size <- payload[["size"]]
  offset <- payload[["offset"]]

  result_cols <- NULL
  result_ls <- list()

  while (size > 0) {

    chunk_size <- min(size, max_size)
    payload[["size"]] <- chunk_size
    payload[["offset"]] <- offset

    json_payload <- jsonlite::toJSON(payload, auto_unbox = TRUE)

    curl::handle_setopt(handle, postfields = json_payload)
    curl::handle_setheaders(handle, .list = headers)

    response <- curl::curl(api_url, handle = handle)

    result <- jsonlite::fromJSON(response)
    result_df <- result[["finance"]][["result"]][["quotes"]][[1]]

    if (!is.null(result_df)) {

      result_df <- jsonlite::flatten(result_df)
      result_df <- process_cols(result_df)

      result_ls <- append(result_ls, list(result_df))
      result_cols <- union(result_cols, colnames(result_df))

      offset <- offset + chunk_size
      size <- size - chunk_size

    } else {
      size <- 0
    }

  }

  result_ls <- lapply(result_ls, function(x) {

    cols_na <- setdiff(result_cols, colnames(x))

    for (j in cols_na) {
      x[[j]] <- NA
    }

    x <- x[ , result_cols]

  })

  result <- do.call(rbind, result_ls)

  return(result)

}
