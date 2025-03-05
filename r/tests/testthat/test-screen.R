test_that("valid 'quote_type' for 'sort_field'", {

  # skip("long-running test")

  error_df <- data.frame(
    quote_type = c("equity", "equity",
                   "mutualfund", "mutualfund", "mutualfund", "mutualfund",
                   "etf", "etf", "etf", "etf",
                   "index", "index",
                   "future"),
    field = c("exchange", "totalsharesoutstanding",
              "categoryname", "fundfamilyname", "exchange", "sector",
              "categoryname", "fundfamilyname", "exchange", "sector",
              "eodvolume", "exchange",
              "exchange")
  )

  quote_types <- unique(data_filters[["quote_type"]])

  result_ls <- list()

  for (quote_type in quote_types) {

    check_fields <- data_filters[["field"]][data_filters[["quote_type"]] == quote_type]

    error_ls <- list()

    for (field in check_fields) {

      response <- tryCatch({

        payload <- create_payload(quote_type = quote_type, size = 1, sort_field = field)
        response <- suppressWarnings(get_screen(payload = payload))

        response

      }, error = function(e) {
        NULL
      })

      if (is.null(response)) {

        error <- data.frame(
          quote_type = quote_type,
          field = field
        )

        error_ls <- append(error_ls, list(error))

      }

    }

    result <- do.call(rbind, error_ls)
    result_ls <- append(result_ls, list(result))

  }

  result_df <- do.call(rbind, result_ls)

  expect_equal(result_df, error_df)

})
