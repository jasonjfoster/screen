data_filters <- read.csv("data-raw/filters.csv")
save(data_filters, file = "data/data_filters.rda")

data_categoryname <- read.csv("data-raw/categoryname.csv")
save(data_categoryname, file = "data/data_categoryname.rda")

data_exchange <- read.csv("data-raw/exchange.csv")
save(data_exchange, file = "data/data_exchange.rda")

data_fundfamilyname <- read.csv("data-raw/fundfamilyname.csv")
save(data_fundfamilyname, file = "data/data_fundfamilyname.rda")

data_industry <- read.csv("data-raw/industry.csv")
save(data_industry, file = "data/data_industry.rda")

data_peer_group <- read.csv("data-raw/peer_group.csv")
save(data_peer_group, file = "data/data_peer_group.rda")

data_region <- read.csv("data-raw/region.csv")
save(data_region, file = "data/data_region.rda")

data_sector <- read.csv("data-raw/sector.csv")
save(data_sector, file = "data/data_sector.rda")
