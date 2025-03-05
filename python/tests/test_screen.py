# import pytest
import pandas as pd
import screen

# @pytest.mark.skip(reason = "long-running test")

def test_that(): # valid 'quote_type' for 'sort_field'
  
	error_df = pd.DataFrame({
		"quote_type": ["equity", "equity",
				   "mutualfund", "mutualfund", "mutualfund", "mutualfund",
				   "etf", "etf", "etf", "etf",
				   "index", "index",
				   "future"],
		"field": ["exchange", "totalsharesoutstanding",
				  "categoryname", "fundfamilyname", "exchange", "sector",
				  "categoryname", "fundfamilyname", "exchange", "sector",
				  "eodvolume", "exchange",
				  "exchange"]
	})

	# Get unique quote types
	quote_types = screen.data_filters["quote_type"].unique()

	result_ls = []

	for quote_type in quote_types:
	  
		check_fields = screen.data_filters.loc[screen.data_filters["quote_type"] == quote_type, "field"]

		error_ls = []

		for field in check_fields:
		  
			try:
			  
				payload = screen.create_payload(quote_type = quote_type, size = 1, sort_field = field)
				response = screen.get_screen(payload = payload)
				
			except Exception:
			  
				response = None

			if response is None:
			  
				error_ls.append({
				  "quote_type": quote_type,
				  "field": field
				})

		if error_ls:
			result_ls.extend(error_ls)

	result_df = pd.DataFrame(result_ls)
	
	pd.testing.assert_frame_equal(result_df, error_df)
