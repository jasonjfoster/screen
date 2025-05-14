test_that("valid 'sec_type', 'field', and 'sort_field'", {

  # skip("long-running test")

  sec_types <- unique(data_filters[["sec_type"]])

  count <- 0
  result_ls <- list()

  for (sec_type in sec_types) {

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

    fields <- data_filters[["field"]][data_filters[["sec_type"]] == sec_type]
    sort_fields <- c(fields, NA)

    errors_ls <- list()

    for (field in fields) {

      type <- data_filters[["r"]][(data_filters[["sec_type"]] == sec_type) & (data_filters[["field"]] == field)]

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

        payload <- create_payload(sec_type = sec_type, query = query,
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
          sec_type = sec_type,
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

      if (is.na(sort_field)) {
        sort_field <- NULL
      }

      response <- tryCatch({

        payload <- create_payload(sec_type = sec_type, size = 1,
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
          sec_type = sec_type,
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

  # if (length(result_df) > 0) {
    expect_equal(result_df, data_errors)
  # } else {
  #   expect_equal(result_df, data.frame())
  # }

})
