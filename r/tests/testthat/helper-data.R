# test arguments

# batched requests (more than one request) with the rows aligned
# into one data frame
test_sizes <- list(
  "batches" = list(sec_type = "equity", size = 251)
)

# test data

# aligned (shared columns) and misaligned (missing columns, mixed
# types, and zero rows) data frames
test_aligns <- list(
  "columns" = list(
    dfs = list(
      data.frame(
        symbol = "AAPL",
        price = 100.5,
        stringsAsFactors = FALSE
      ),
      data.frame(
        symbol = "MSFT",
        price = 200.25,
        stringsAsFactors = FALSE
      )
    ),
    expected = data.frame(
      symbol = c("AAPL", "MSFT"),
      price = c(100.5, 200.25),
      stringsAsFactors = FALSE
    )
  ),
  "fill" = list(
    dfs = list(
      data.frame(
        symbol = c("AAPL", "MSFT"),
        price = c(100.5, 200.25),
        stringsAsFactors = FALSE
      ),
      data.frame(
        symbol = "AMZN",
        price = 300.75,
        "price.raw" = "100.5",
        check.names = FALSE,
        stringsAsFactors = FALSE
      ),
      data.frame(
        symbol = character(0)
      )
    ),
    expected = data.frame(
      symbol = c("AAPL", "MSFT", "AMZN"),
      price = c(100.5, 200.25, 300.75),
      "price.raw" = c(NA, NA, "100.5"),
      check.names = FALSE,
      stringsAsFactors = FALSE
    )
  )
)
