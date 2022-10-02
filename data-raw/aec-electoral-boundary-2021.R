## code to prepare `aec-electoral-boundary-2021` dataset goes here
library(sf)
library(tidyverse)
library(rmapshaper)

tmp_fn <- tempfile()
download.file("https://www.aec.gov.au/Electorates/gis/files/2021-Cwlth_electoral_boundaries_ESRI.zip", tmp_fn)
unzip(tmp_fn, exdir = dirname(tmp_fn))
unz("~/Downloads/test.zip", "/2021-Cwlth_electoral_boundaries_ESRI/2021_ELB_region.shp")

elec_map_2021 <- read_sf(file.path(dirname(tmp_fn), "2021_ELB_region.shp")) %>%
  select(division = Elect_div,
         area = Area_SqKm,
         geometry = geometry) %>%
  # simply map
  # https://www.r-bloggers.com/2021/03/simplifying-geospatial-features-in-r-with-sf-and-rmapshaper/
  ms_simplify(keep = 0.001,
              keep_shapes = FALSE)

winners <- read_csv("https://results.aec.gov.au/27966/Website/Downloads/HouseDopByDivisionDownload-27966.csv",
                    skip = 1) %>%
  filter(Elected == "Y") %>%
  select(state = StateAb, division = DivisionNm, party = PartyAb) %>%
  distinct()

aec2022 <- elec_map_2021 %>%
  left_join(winners, by = "division")

usethis::use_data(aec2022, overwrite = TRUE)
