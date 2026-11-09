# screen

## Version 0.1.3

* Added the `session` argument to the `get_data` function to reuse a session across calls

* Added input checks for the `filters` and `top_operator` arguments of the `create_query` function and the `size`, `offset`, `sort_type`, and `top_operator` arguments of the `create_payload` function

* Fixed an issue for list columns that cannot be flattened in the `get_data` function

* Removed the internal `Check`, `Process`, and `Env` classes from the package namespace

* Added tests for batched requests, data frame alignment, and input checks

## Version 0.1.2

* Fixed an issue for the `offset` field of the payload in the `get_data` function ([#1](https://github.com/jasonjfoster/screen/issues/1))

* Fixed an issue for the SSL backend in the `get_session` function

* Fixed an issue for failed requests in the `get_data` function

## Version 0.1.1

* Initial PyPI release
