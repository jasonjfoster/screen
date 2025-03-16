test_that("valid 'quote_type', 'field', and 'sort_field'", {

  # skip("long-running test")

  quote_types <- unique(data_filters[["quote_type"]])

  count <- 0
  result_ls <- list()

  for (quote_type in quote_types) {

    if (quote_type == "equity") {
      sort_field <- "intradaymarketcap"
    } else if (quote_type == "mutualfund") {
      sort_field <- "fundnetassets"
    } else if (quote_type == "etf") {
      sort_field <- "fundnetassets"
    } else if (quote_type == "index") {
      sort_field <- "percentchange"
    } else if (quote_type == "future") {
      sort_field <- "percentchange"
    } else {
      sort_field <- NULL
    }

    fields <- data_filters[["field"]][data_filters[["quote_type"]] == quote_type]
    sort_fields <- fields

    errors_ls <- list()

    for (field in fields) {

      type <- data_filters[["r"]][(data_filters[["quote_type"]] == quote_type) & (data_filters[["field"]] == field)]

      if (type == "character") {
        test_value <- "test"
      } else if (type %in% c("integer", "numeric")) {
        test_value <- 1
      } else if (type == "now-1w/d") {
        test_value <- "now-1w/d"
      } else {
        test_value <- NA
      }

      filters <- list("eq", list(field, test_value))

      query <- create_query(filters)

      response <- tryCatch({

        payload <- create_payload(quote_type = quote_type, query = query,
                                  size = 1, sort_field = sort_field)
        response <- suppressWarnings(get_data(payload = payload))

        if (is.null(response)) {
          response <- "success"
        } else {
          response
        }

      }, error = function(e) {
        NULL
      })

      if (is.null(response)) {

        error <- data.frame(
          quote_type = quote_type,
          field = field,
          sort_field = NA
        )

        errors_ls <- append(errors_ls, list(error))

      }

      count <- count + 1

      if (count %% 5 == 0) {

        message("pause one second after five requests")
        Sys.sleep(1)

      }

    }

    for (sort_field in sort_fields) {

      response <- tryCatch({

        payload <- create_payload(quote_type = quote_type, size = 1,
                                  sort_field = sort_field)
        response <- suppressWarnings(get_data(payload = payload))

        if (is.null(response)) {
          response <- "success"
        } else {
          response
        }

      }, error = function(e) {
        NULL
      })

      if (is.null(response)) {

        error <- data.frame(
          quote_type = quote_type,
          field = NA,
          sort_field = sort_field
        )

        errors_ls <- append(errors_ls, list(error))

      }

      count <- count + 1

      if (count %% 5 == 0) {

        message("pause one second after five requests")
        Sys.sleep(1)

      }

    }

    if (length(errors_ls) > 0) {

      result <- do.call(rbind, errors_ls)
      result_ls <- append(result_ls, list(result))

    }

  }

  result_df <- do.call(rbind, result_ls)

  expect_equal(result_df, data_errors)

})
