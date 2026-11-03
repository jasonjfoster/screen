test_that("input checks", {

  # test data
  test_check_query <- create_query(list("eq", list("region", "us")))

  # check_filters
  expect_error(create_query(list("eq")),
               "invalid 'filters'")

  # check_top_operator
  expect_error(create_query(top_operator = "xor"),
               "invalid 'top_operator'")

  # check_sec_type
  expect_error(create_payload("bond", test_check_query),
               "invalid 'sec_type'")

  # check_size
  expect_error(create_payload("equity", test_check_query, size = "a"),
               "invalid 'size'")
  expect_error(create_payload("equity", test_check_query, size = 0),
               "value of 'size' must be greater than or equal to one")

  # check_offset
  expect_error(create_payload("equity", test_check_query, offset = 1.5),
               "invalid 'offset'")
  expect_error(create_payload("equity", test_check_query, offset = -1),
               "value of 'offset' must be greater than or equal to zero")

  # check_sort_type
  expect_error(create_payload("equity", test_check_query, sort_type = "up"),
               "invalid 'sort_type'")

  # check_fields
  expect_error(create_payload("equity", create_query(list("eq", list("notafield", 1)))),
               "invalid field(s)",
               fixed = TRUE)

  # check_sort_field ('exchange' is a field but not a sort field)
  expect_error(create_payload("equity", test_check_query, sort_field = "exchange"),
               "invalid 'sort_field' for 'sec_type'")
  expect_error(create_payload("equity", test_check_query, sort_field = "notafield"),
               "invalid 'sort_field' for 'sec_type'")

})
