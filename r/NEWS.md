# screen

## Version 0.1.3

* Added the `session` argument to the `get_data` function to reuse a session across calls

* Added input checks for the `filters` and `top_operator` arguments of the `create_query` function and the `size`, `offset`, `sort_type`, and `top_operator` arguments of the `create_payload` function

* Fixed an issue for the request headers in the `get_data` function

* Fixed an issue for restoring the `CURL_SSL_BACKEND` environment variable in the `get_session` function

* Added tests for batched requests, data frame alignment, and input checks

## Version 0.1.2

* Fixed an issue for the SSL backend in the `get_session` function

* Fixed an issue for failed requests in the `get_data` function

## Version 0.1.1

* Initial CRAN release
