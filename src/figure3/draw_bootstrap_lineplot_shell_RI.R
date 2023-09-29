library(here)
library(glue)
library(arrow)
library(tidyverse)

set.seed(27)

SAMPLE_CELL_NUMBER <- 100
data <- read_feather(here("data/processed/figure2/RI_distribution.feather"))
data %>% pivot_wider(id_cols = c(timepoint, cell_num, threshold), names_from = shell_num, values_from = density) %>% write_feather(here("data/processed/figure2/RI_distribution_wide.feather"))
boots <- bootstraps(data, times = 2000, apparent = TRUE)
boots
mtcars
