# import pytest
import time
import pandas as pd
import yfscreen as yfs

# @pytest.mark.skip(reason = "long-running test")

def test_that(): # valid 'sec_type', 'field', and 'sort_field'

  sec_types = yfs.data_filters["sec_type"].unique()
  
  count = 0
  result_ls = []

  for sec_type in sec_types:

    if sec_type == "equity":
      sort_field = "intradaymarketcap"
    elif sec_type == "mutualfund":
      sort_field = "fundnetassets"
    elif sec_type == "etf":
      sort_field = "fundnetassets"
    elif sec_type == "index":
      sort_field = "percentchange"
    elif sec_type == "future":
      sort_field = "percentchange"

    fields = yfs.data_filters.loc[yfs.data_filters["sec_type"] == sec_type, "field"]
    sort_fields = list(fields)
    sort_fields.append(None)

    errors_ls = []

    for field in fields:
        
      type_value = yfs.data_filters.loc[(yfs.data_filters["sec_type"] == sec_type) & (yfs.data_filters["field"] == field), "python"].values[0] 
      
      if type_value == "str":
        test_value = "test"
      elif type_value in ["int", "float"]:
        test_value = 1
      elif type_value == "now-1w/d":
        test_value = "now-1w/d"
      else:
        test_value = None

      filters = ["eq", [field, test_value]]
      
      query = yfs.create_query(filters)
      
      try:
          
        payload = yfs.create_payload(sec_type = sec_type, query = query,
                                    size = 1, sort_field = sort_field)
        response = yfs.get_data(payload = payload)
        
        if (response is None):
          response = "success"
          
      except:
        response = None

      if response is None:
          
        errors_ls.append({
          "sec_type": sec_type,
          "field": field,
          "sort_field": None
        })
          
      count += 1
      
      if count % 5 == 0:
      
        print("pause one second after five requests")
        time.sleep(1)

    for sort_field in sort_fields:
          
      try:
          
        payload = yfs.create_payload(sec_type = sec_type, size = 1,
                                    sort_field = sort_field)
        response = yfs.get_data(payload = payload)
          
        # if (response is None):
        #   response = "success"
        
      except:
        response = None

      if response is None:
          
        errors_ls.append({
          "sec_type": sec_type,
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
  
  # if (len(result_df) > 0):
  pd.testing.assert_frame_equal(result_df, yfs.data_errors)
  # else:
  #   pd.testing.assert_frame_equal(result_df, pd.DataFrame())
