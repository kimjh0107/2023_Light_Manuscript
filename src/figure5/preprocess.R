library(tidyverse)
library(here)
library(arrow)
labs <- read_csv(here("data/raw/figure4/clinical_lab.csv"))
target_labs <- c("WBC COUNT[Whole blood]", "CRP (C-Reactive Protein)[Serum]", "Lymphocyte(%)[Whole blood]", "Neutrophil(%)[Whole blood]")
labs <- labs %>%
    select(No, timepoint, code_name, result_value) %>%
    mutate(No = factor(No)) %>%
    mutate(timepoint = factor(timepoint)) %>%
    filter(code_name %in% target_labs) %>%
    mutate(code_name = recode(code_name, "CRP (C-Reactive Protein)[Serum]" = "CRP", "WBC COUNT[Whole blood]" = "WBC (/uL)", "Lymphocyte(%)[Whole blood]" = "Lymphocyte (%)", "Neutrophil(%)[Whole blood]" = "Neutrophil (%)")) %>%
    mutate(code_name = factor(code_name, levels = c("CRP", "WBC (/uL)", "Lymphocyte (%)", "Neutrophil (%)"))) %>%
    mutate(result_value = as.numeric(result_value)) %>%
    filter(!is.na(result_value)) %>%
    mutate(group = ifelse(No %in% c(4, 6), "Non-survival", "Survival"))

write_feather(labs, here("data/processed/figure4/labs.feather"))

cytokines <- read_csv(here("data/raw/figure4/cytokine_level.csv"))
target_cytokine <- c("CCL2/MCP-1", "IL-10", "IL-2", "TNF-alpha")
cytokines <- cytokines %>%
    mutate(No = str_extract(Sample, "S[0-9]+")) %>%
    mutate(No = as.numeric(str_replace(No, "S", ""))) %>%
    mutate(No = factor(No)) %>%
    filter(Cytokine %in% target_cytokine) %>%
    mutate(group = ifelse(No %in% c(4, 6), "Non-survival", "Survival"))

write_feather(cytokines, here("data/processed/figure4/cytokines.feather"))

ri <- read_csv(here("data/raw/figure4/merge_correlation_result.csv"))
ri <- ri %>%
    select(Sample, timepoint = timepoint.x, filename, value_mean, value_50) %>%
    distinct() %>%
    mutate(No = str_extract(Sample, "S[0-9]+")) %>%
    mutate(No = as.numeric(str_replace(No, "S", ""))) %>%
    mutate(No = factor(No)) %>%
    mutate(timepoint = factor(as.numeric(str_replace(timepoint, "t", ""))))

ri_summary <- ri %>%
    group_by(No, timepoint) %>%
    summarise(mean = mean(value_mean), sd = sd(value_mean), n = n())

write_feather(ri_summary, here("data/processed/figure4/ri_summary.feather"))
