# import pytest
import time
import pandas as pd
import screen

# @pytest.mark.skip(reason = "long-running test")

def test_that(): # valid 'quote_type', 'field', and 'sort_field'

  quote_types = screen.data_filters["quote_type"].unique()

  count = 0
  result_ls = []

  for quote_type in quote_types:

    if quote_type == "equity":
      sort_field = "intradaymarketcap"
    elif quote_type == "mutualfund":
      sort_field = "fundnetassets"
    elif quote_type == "etf":
      sort_field = "fundnetassets"
    elif quote_type == "index":
      sort_field = "percentchange"
    elif quote_type == "future":
      sort_field = "percentchange"
    else:
      sort_field = None

    fields = screen.data_filters.loc[screen.data_filters["quote_type"] == quote_type, "field"]
    sort_fields = fields

    errors_ls = []

    for field in fields:
        
      type_value = screen.data_filters.loc[(screen.data_filters["quote_type"] == quote_type) & (screen.data_filters["field"] == field), "python"].values[0] 
      
      if type_value == "str":
        test_value = "test"
      elif type_value in ["int", "float"]:
        test_value = 1
      elif type_value == "now-1w/d":
        test_value = "now-1w/d"
      else:
        test_value = None

      filters = ["eq", [field, test_value]]
      
      query = screen.create_query(filters)
      
      try:
          
        payload = screen.create_payload(quote_type = quote_type, query = query,
                                        size = 1, sort_field = sort_field)
        response = screen.get_screen(payload = payload)
        
        if (response is None):
          response = "success"
          
      except Exception:
        response = None

      if response is None:
          
        errors_ls.append({
          "quote_type": quote_type,
          "field": field,
          "sort_field": None
        })
          
      count += 1
      
      if count % 5 == 0:
      
        print("pause one second after five requests")
        time.sleep(1)

    for sort_field in sort_fields:
          
      try:
          
        payload = screen.create_payload(quote_type = quote_type, size = 1,
                                          sort_field = sort_field)
        response = screen.get_screen(payload = payload)
          
        if (response is None):
          response = "success"
        
      except Exception:
        response = None

      if response is None:
          
        errors_ls.append({
          "quote_type": quote_type,
          "field": None,
          "sort_field": sort_field
        })
          
      count += 1
      
      if count % 5 == 0:
      
        print("pause one second after five requests")
        time.sleep(1)		  
            
    if len(errors_ls) > 0:
      result_ls.extend(errors_ls)

  result_df = pd.DataFrame(result_ls)

  pd.testing.assert_frame_equal(result_df, screen.data_errors)
