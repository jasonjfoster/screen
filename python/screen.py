import requests
import pandas as pd

# class Check:
#   
#   @staticmethod
#   def quote_type(quote_type):
#     
#     if quote_type not in Reference.data["quote_type"].unique():
#       raise Exception("Invalid quote_type")
#   
#   @staticmethod
#   def fields(fields):
#     
#     valid_fields = Reference.data.loc[Reference.data["quote_type"] == quote_type, "field"].tolist()
#     invalid_fields = [field for field in fields if field not in valid_fields]
#     
#     if invalid_fields:
#       raise Exception("Invalid field(s)")

class Process:
  
  @staticmethod
  def filters(filters):
    
    if isinstance(filters[0], str):
      filters = [filters]
    
    result_ls = {}

    for filter in filters:
      
      operator, operands = filter[0], tuple(filter[1])
      key = operands[0]
      
      if key not in result_ls:
        result_ls[key] = []
      
      result_ls[key].append({"operator": operator, "operands": operands})

    return result_ls
    
  # @staticmethod
  # def url(params):
  #   
  #   result = "?" + "&".join(f"{key}={value}" for key, value in params.items())
  #   
  #   return result
  
  @staticmethod
  def cols(df):
    
    df = df.copy()

    for col in df.columns:
  	  
      if df[col].apply(lambda x: isinstance(x, list)).all():
  			
        status_df = df[col].apply(lambda x: all(isinstance(i, dict) for i in x)).all()
  			
        if status_df:
  				
          cols = set()
  				
          for row in df[col]:
            for item in row:
  					  
              flattened_item = pd.json_normalize(item, sep = ".", max_level = None)
              cols.update(flattened_item.columns)
  				
          row_na = {key: None for key in cols}
  				
          result_ls = []
  				
          for row in df[col]:
  				
            if not row:
              result_ls.append(row_na)
            else:
  					  
              flattened_row = pd.json_normalize(row[0]).to_dict(orient = "records")[0]
              result = {key: flattened_row.get(key, None) for key in cols}
  						
              cols_na = cols - result.keys()
  						
              for col_na in cols_na:
                result[col_na] = None
  						
              result_ls.append(result)
  				
          result_df = pd.DataFrame(result_ls)
          df = pd.concat([df.reset_index(drop = True), result_df], axis = 1)
  				
          df.drop(columns = [col], inplace=True)
  			
        else:
          df[col] = None
  	
    return df

class Query:
  
  @staticmethod
  def create(filters = ["eq", ["region", "us"]], top_operator = "and"):
    """
    Create a Structured Query for the Yahoo Finance API
    
    A method to create a structured query with logical operations and nested conditions
    formatted for the Yahoo Finance API.
    
    Parameters:
      filters: each element is a sublist that defines a filtering condition with
        the following structure:
          - "comparison" (str): comparison operator (i.e. "gt", "lt", "eq", "btwn").
          - "field" (list): field name (e.g., "region") and its associated value(s).
      top_operator (str): top-level logical operator to combine all filters (i.e., "and", "or").
    
    Returns:
      A nested dictionary representing the structured query with logical operations and
      nested conditions formatted for the Yahoo Finance API.
    
    Examples:
      filters = [
        ["eq", ["region", "us"]],
        ["btwn", ["intradaymarketcap", 2000000000, 10000000000]],
        ["btwn", ["intradaymarketcap", 10000000000, 100000000000]],
        ["gt", ["intradaymarketcap", 100000000000]],
        ["gt", ["dayvolume", 5000000]]
        ])
      )
      
      query = Query.create(filters)
    """

    result_ls = Process.filters(filters)
    result = {"operator": top_operator, "operands": []}

    for key, operands in result_ls.items():
        result["operands"].append({"operator": "or", "operands": operands})

    return result

class Payload:
  
  @staticmethod
  def create(quote_type = "equity", query = Query.create(),
             size = 25, offset = 0,
             sort_field = None, sort_type = None,
             top_operator = "and"):
    """
    Create a Payload for the Yahoo Finance API
    
    A method to create a payload to query the Yahoo Finance API with customizable parameters.
    
    Parameters:
      quote_type (str): type of quote to search
        (i.e., "equity", "mutualfund", "etf", "index", "future").
      query (list or tuple): structured query to filter results created by
        the `Query.create` method.
      size (int): number of results to return.
      offset (int): starting position of the results.
      sort_field (str): field to sort the results.
      sort_type (str): type of sort to apply (i.e., "asc", "desc").
      top_operator (str): logical operator for the top-level of the query
        (i.e., "and", "or")
      
    Returns:
      A dictionary representing the payload to be sent to the Yahoo Finance API
      with the specified parameters.
        
    Examples:
    filters = ["eq", ["region", "us"]]
    
    query = Query.create(filters)
    
    payload = Payload.create(
      quote_type = "equity", query = query,
      size = 25, offset = 0,
      sort_field = "intradaymarketcap", sort_type = "desc",
      top_operator = "and"
    )
    """
    
    result = {
      "includeFields": None, # unable to modify the result
      "offset": offset,
      "query": query,
      "quoteType": quote_type,
      "size": size,
      "sortField": sort_field,
      "sortType": sort_type,
      "topOperator": top_operator,
    }
    
    return result

class Session:
  
  @staticmethod
  def get():
    """
    Get the Crumb, Cookies, and Handle for Yahoo Finance API
    
    A method to get the crumb, cookies, and handle required to authenticate and interact
    with the Yahoo Finance API.
    
    Returns:
      A dictionary containing the following elements:
        - "handle" (requests.Session): a session handle object for subsequent requests.
        - "crumb" (str): a string representing the crumb value for authentication.
        - "cookies" (dict): a data frame of cookies for the request.
        
      Examples:
        session = Session.get()
    """
    
    session = requests.Session()
    
    api_url = "https://query1.finance.yahoo.com/v1/test/getcrumb"
    
    headers = {
      "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
    }
    
    session.headers.update(headers)
  
    response = session.get(api_url)
    
    crumb = response.text.strip()
    cookies = session.cookies.get_dict()
  
    result = {
      "handle": session,
      "crumb": crumb,
      "cookies": cookies
    }
    
    return result

class Screen:
  
  @staticmethod
  def get(payload = Payload.create()):
    """
    Get Screen Data from the Yahoo Finance API
  
    A method to get data from the Yahoo Finance API using the specified payload.
  
    Parameters:
      payload (dict): payload that contains search criteria using
        the `Query.create` and `Payload.create` methods.
  
    Returns:
      A data frame that contains data from the Yahoo Finance API for the
      specified search criteria.
  
    Examples:
      filters = ["eq", ["region", "us"]]
  
      query = Query.create(filters)
  
      payload = Payload.create(
        quote_type = "equity", query = query,
        size = 25, offset = 0,
        sort_field = "intradaymarketcap", sort_type = "desc",
        top_operator = "and"
      )
  
      screen = Screen.get(payload)
    """
  
    session = Session.get()
    crumb = session["crumb"]
    cookies = session["cookies"]
    handle = session["handle"]
  
    params = {
      "crumb": crumb,
      "lang": "en-US",
      "region": "US",
      "formatted": "true",
      "corsDomain": "finance.yahoo.com",
    }
  
    api_url = "https://query1.finance.yahoo.com/v1/finance/screener" # + Process.url(params)
  
    headers = {
      # "Content-Type": "application/json",
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
    }
  
    max_size = 250
    size = payload["size"]
    offset = payload["offset"]
    
    result_cols = set()
    result_ls = []

    while size > 0:
  
      chunk_size = min(size, max_size)
      payload["size"] = chunk_size
      payload["offst"] = offset
  
      for key, value in cookies.items():
        handle.cookies.set(key, value)
  
      response = handle.post(api_url, params = params, json = payload, headers = headers)
  
      result = response.json()
      result_df = result["finance"]["result"][0]["quotes"]
  
      if (result_df is not None):
        
        result_df = pd.json_normalize(result_df)
        result_df = Process.cols(result_df)
        
        result_ls.append(result_df)
        result_cols.update(result_df.columns)
  
        size -= chunk_size
        offset += chunk_size
  
      else:
        size = 0
        
    result_cols = list(result_cols)
    
    for i in range(len(result_ls)):
      
      x = result_ls[i]
      cols_na = set(result_cols) - set(x.columns)
      
      for j in cols_na:
        x[j] = None
        
      result_ls[i] = x[result_cols]
    
    result = pd.concat(result_ls, ignore_index = True)
    
    return result
