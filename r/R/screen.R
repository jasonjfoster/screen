##' Filters Data for the Yahoo Finance API
##'
##' A data frame with the available filters data for the Yahoo Finance API.
##'
##' @format A data frame.
"data_filters"

##' Category Name Data for the Yahoo Finance API
##'
##' A data frame with the available category name data for the Yahoo Finance API.
##'
##' @format A data frame.
"data_categoryname"

##' Exchange Data for the Yahoo Finance API
##'
##' A data frame with the available exchange data for the Yahoo Finance API.
##'
##' @format A data frame.
"data_exchange"

##' Fund Family Name Data for the Yahoo Finance API
##'
##' A data frame with the available fund family name data for the Yahoo Finance API.
##'
##' @format A data frame.
"data_fundfamilyname"

##' Industry Data for the Yahoo Finance API
##'
##' A data frame with the available industry name for the Yahoo Finance API.
##'
##' @format A data frame.
"data_industry"

##' Peer Group Data for the Yahoo Finance API
##'
##' A data frame with the available peer group data for the Yahoo Finance API.
##'
##' @format A data frame.
"data_peer_group"

##' Regions Data for the Yahoo Finance API
##'
##' A data frame with the available regions for the Yahoo Finance API.
##'
##' @format A data frame.
"data_region"

##' Sector Data for the Yahoo Finance API
##'
##' A data frame with the available sector data for the Yahoo Finance API.
##'
##' @format A data frame.
"data_sector"

##' Errors Data for the Yahoo Finance API
##'
##' A data frame with the available errors data for the Yahoo Finance API.
##'
##' @format A data frame.
"data_errors"

check_sec_type <- function(sec_type) {

  valid_sec_type <- unique(screen::data_filters[["sec_type"]])

  if (!sec_type %in% valid_sec_type) {
    stop("invalid 'sec_type'")
  }

}

check_fields <- function(sec_type, query) {

  # check_sec_type(sec_type)

  valid_fields <- screen::data_filters[["field"]][screen::data_filters[["sec_type"]] == sec_type]
  error_fields <- screen::data_errors[["field"]][screen::data_errors[["sec_type"]] == sec_type]
  valid_fields <- setdiff(valid_fields, error_fields)

  fields <- c()

  for (operand in query[["operands"]]) {
    if (is.list(operand[["operands"]]) && length(operand[["operands"]]) > 0) {
      fields <- c(fields, operand[["operands"]][[1]][["operands"]][[1]])
    }
  }

  invalid_fields <- setdiff(fields, valid_fields)

  if (length(invalid_fields) > 0) {
    stop("invalid field(s)")
  }

}

check_sort_field <- function(sec_type, sort_field) {

  # check_sec_type(sec_type)

  valid_sort_fields <- screen::data_filters[["field"]][screen::data_filters[["sec_type"]] == sec_type]
  error_sort_fields <- screen::data_errors[["sort_field"]][screen::data_errors[["sec_type"]] == sec_type]
  valid_sort_fields <- setdiff(valid_sort_fields, error_sort_fields)

  if (!sort_field %in% valid_sort_fields) {
    stop("invalid 'sort_field' for 'sec_type'")
  }

}

process_filters <- function(filters) {

  if (!is.list(filters[[1]])) {
    filters <- list(filters)
  }

  result_ls <- list()

  for (filter in filters) {

    operator <- filter[[1]]
    operands <- filter[[2]]
    key <- operands[[1]]

    if (!key %in% names(result_ls)) {
      result_ls[[key]] <- list()
    }

    result_ls[[key]] <- append(result_ls[[key]], list(list(operator = operator, operands = operands)))

  }

  return(result_ls)

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
##' A function to create a structured query with logical operations and nested conditions
##' formatted for the Yahoo Finance API.
##'
##' @param filters list. Each element is a sublist that defines a filtering condition with
##' the following structure:
##' \describe{
##'   \item{\code{comparison}}{string. Comparison operator (i.e., "gt", "lt", "eq", "btwn").}
##'   \item{\code{field}}{list. Field name (e.g. "region") and its associated value(s).}
##' }
##' @param top_operator string. Top-level logical operator to combine all filters (i.e., "and", "or").
##' @return A nested list representing the structured query with logical operations and
##' nested conditions formatted for the Yahoo Finance API.
##' @examples
##' filters <- list(
##'   list("eq", list("region", "us")),
##'   list("btwn", list("intradaymarketcap", 2000000000, 10000000000)),
##'   list("btwn", list("intradaymarketcap", 10000000000, 100000000000)),
##'   list("gt", list("intradaymarketcap", 100000000000)),
##'   list("gt", list("dayvolume", 5000000))
##' )
##'
##' query <- create_query(filters)
##' @export
create_query <- function(filters = list("eq", list("region", "us")),
                         top_operator = "and") {

  result_ls <- process_filters(filters)
  result <- list(operator = top_operator, operands = list())

  for (key in names(result_ls)) {
    result[["operands"]] <- append(result[["operands"]], list(list(operator = "or", operands = result_ls[[key]])))
  }

  return(result)

}

##' Create a Payload for the Yahoo Finance API
##'
##' A function to create a payload to query the Yahoo Finance API with customizable parameters.
##'
##' @param sec_type string. Type of security to search
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
##'   list("eq", list("region", "us")),
##'   list("btwn", list("intradaymarketcap", 2000000000, 10000000000)),
##'   list("btwn", list("intradaymarketcap", 10000000000, 100000000000)),
##'   list("gt", list("intradaymarketcap", 100000000000)),
##'   list("gt", list("dayvolume", 5000000))
##' )
##'
##' query <- create_query(filters)
##'
##' payload <- create_payload("equity", query)
##' @export
create_payload <- function(sec_type = "equity", query = NULL,
                           size = 25, offset = 0,
                           sort_field = NULL, sort_type = NULL,
                           top_operator = "and") {

  check_sec_type(sec_type)

  if (is.null(query)) {
    query <- create_query()
  }

  check_fields(sec_type, query)

  if (is.null(sort_field)) {
    if (sec_type == "equity") {
      sort_field <- "intradaymarketcap"
    } else if (sec_type == "mutualfund") {
      sort_field <- "fundnetassets"
    } else if (sec_type == "etf") {
      sort_field <- "fundnetassets"
    } else if (sec_type == "index") {
      sort_field <- "percentchange"
    } else if (sec_type == "future") {
      sort_field <- "percentchange"
    }
  }

  check_sort_field(sec_type, sort_field)

  result <- list(
    includeFields = NULL, # unable to modify the result
    offset = offset,
    query = query,
    quoteType = sec_type,
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
##' \item{handle}{A curl handle object for subsequent requests.}
##' \item{crumb}{A string representing the crumb value for authentication.}
##' \item{cookies}{A data frame of cookies for the request.}
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

##' Get Data from the Yahoo Finance API
##'
##' A function to get data from the Yahoo Finance API using the specified payload.
##'
##' @param payload list. Payload that contains search criteria created using
##' the \code{\link{create_query}} and \code{\link{create_payload}} functions.
##' @return A data frame that contains data from the Yahoo Finance API for the
##' specified search criteria.
##'
##' @examples
##' filters <- list(
##'   list("eq", list("region", "us")),
##'   list("btwn", list("intradaymarketcap", 2000000000, 10000000000)),
##'   list("btwn", list("intradaymarketcap", 10000000000, 100000000000)),
##'   list("gt", list("intradaymarketcap", 100000000000)),
##'   list("gt", list("dayvolume", 5000000))
##' )
##'
##' query <- create_query(filters)
##'
##' payload <- create_payload("equity", query)
##'
##' data <- get_data(payload)
##' @export
get_data <- function(payload = NULL) {

  if (is.null(payload)) {
    payload <- create_payload()
  }

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

  count <- 0
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

    if (length(result_df) > 0) {

      result_df <- jsonlite::flatten(result_df)
      result_df <- process_cols(result_df)

      result_ls <- append(result_ls, list(result_df))
      result_cols <- union(result_cols, colnames(result_df))

      offset <- offset + chunk_size
      size <- size - chunk_size

    } else {
      size <- 0
    }

    count <- count + 1

    if (count %% 5 == 0) {

      message("pause one second after five requests")
      Sys.sleep(1)

    }

  }

  if (length(result_ls) == 0) {
    return(data.frame())
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
