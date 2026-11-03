import re
import pytest
import yfscreen as yfs

def test_check(): # input checks

  # test data
  test_check_query = yfs.create_query(["eq", ["region", "us"]])

  # check_filters
  with pytest.raises(ValueError, match = re.escape("invalid 'filters'")):
    yfs.create_query(["eq"])

  # check_top_operator
  with pytest.raises(ValueError, match = re.escape("invalid 'top_operator'")):
    yfs.create_query(top_operator = "xor")

  # check_sec_type
  with pytest.raises(ValueError, match = re.escape("invalid 'sec_type'")):
    yfs.create_payload("bond", test_check_query)

  # check_size
  with pytest.raises(ValueError, match = re.escape("invalid 'size'")):
    yfs.create_payload("equity", test_check_query, size = "a")
  with pytest.raises(ValueError, match = re.escape("value of 'size' must be greater than or equal to one")):
    yfs.create_payload("equity", test_check_query, size = 0)

  # check_offset
  with pytest.raises(ValueError, match = re.escape("invalid 'offset'")):
    yfs.create_payload("equity", test_check_query, offset = 1.5)
  with pytest.raises(ValueError, match = re.escape("value of 'offset' must be greater than or equal to zero")):
    yfs.create_payload("equity", test_check_query, offset = -1)

  # check_sort_type
  with pytest.raises(ValueError, match = re.escape("invalid 'sort_type'")):
    yfs.create_payload("equity", test_check_query, sort_type = "up")

  # check_fields
  with pytest.raises(ValueError, match = re.escape("invalid field(s)")):
    yfs.create_payload("equity", yfs.create_query(["eq", ["notafield", 1]]))

  # check_sort_field ('exchange' is a field but not a sort field)
  with pytest.raises(ValueError, match = re.escape("invalid 'sort_field' for 'sec_type'")):
    yfs.create_payload("equity", test_check_query, sort_field = "exchange")
  with pytest.raises(ValueError, match = re.escape("invalid 'sort_field' for 'sec_type'")):
    yfs.create_payload("equity", test_check_query, sort_field = "notafield")
