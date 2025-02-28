data_filters <- read.csv("data-raw/filters.csv")
save(data_filters, file = "data/data_filters.rda")

data_region <- read.csv("data-raw/region.csv")
save(data_region, file = "data/data_region.rda")
