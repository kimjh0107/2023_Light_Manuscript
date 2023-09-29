library(tidyverse)
library(here)
library(glue)
library(arrow)

read_RI_distribution_data <- function(timepoint, threshold) {
    result <- read_csv(here(glue("data/raw/RI_distribution/slice_RI_mean_{timepoint}_threshold_{threshold}.csv")))
    result <- result %>% mutate(timepoint = timepoint, threshold = threshold, .before = "shell1")
    if ("Unnamed: 0" %in% colnames(result)) {
    result <- result %>% select(-`Unnamed: 0`)
    } else {
    result <- result %>% select(-"...1")
    }

    result <- result %>% mutate(cell_num = rownames(result), .before = "timepoint")
    return(result)
}

timepoints <- c("hc", "t1", "t2", "t3")
timpoints_map <- list(
    "hc" = "Healthy Control",
    "t1" = "T1",
    "t2" = "T2",
    "t3" = "T3"
)

thresholds <- c("13450_13600", "13600_13800", "13800")
thresholds_map <- list(
    "13450_13600" = "Membrane",
    "13600_13800" = "Cytoplasm",
    "13800" = "Nucleus"
)
column_names <- c("cell_num", "timepoint", "threshold", "8", "7", "6", "5", "4", "3", "2", "1")

groups <- purrr::cross2(timepoints, thresholds)
data <- groups %>%
    map_dfr(~ read_RI_distribution_data(timepoint = .x[[1]], threshold = .x[[2]])) %>%
    magrittr::set_colnames(column_names) %>%
    pivot_longer(cols = c(-timepoint, -cell_num, -threshold), names_to = "shell_num", values_to = "density") %>%
    mutate(shell_num = as.numeric(shell_num)) %>%
    na.omit()

write_feather(data, here("data/processed/figure2/RI_distribution.feather"))
