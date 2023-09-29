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

cytokine <- read_csv(here("data/raw/figure4/cytokine_level.csv"))
target_cytokine <- c("CCL2/MCP-1", "IL-10", "IL-2", "TNF-alpha")
cytokine <- cytokine %>%
    mutate(No = str_extract(Sample, "S[0-9]+")) %>%
    mutate(No = as.numeric(str_replace(No, "S", ""))) %>%
    mutate(No = factor(No)) %>%
    filter(Cytokine %in% target_cytokine) %>%
    mutate(group = ifelse(No %in% c(4, 6), "Non-survival", "Survival"))

cytokine_fig <- cytokine %>%
    filter(Cytokine != "Granzyme A") %>%
    filter(Cytokine != "Granzyme B") %>%
    ggplot(aes(x = TimePoint, y = Value)) +
    geom_point() +
    facet_wrap(Cytokine ~ Patient, scales = "free_y", ncol = 8)

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

ri_fig <- ri_summary %>%
    ggplot(aes(x = timepoint, y = mean)) +
    geom_point() +
    facet_wrap(~No, scales = "free_y", ncol = 8)

# FIGURE 4A ##################
lab_fig <- labs %>%
    group_by(timepoint, code_name) %>%
    summarise(mean_value = mean(result_value, na.rm = T), std_value = sd(result_value, na.rm = T), se_value = std_value / sqrt(n()), .groups = "drop") %>%
    ggplot(aes(x = timepoint)) +
    geom_point(aes(y = mean_value)) +
    geom_errorbar(aes(ymin = mean_value - se_value, ymax = mean_value + se_value), width = 0.2) +
    facet_wrap(code_name ~ ., scales = "free_y", ncol = 8) +
    theme_minimal() +
    scale_x_discrete(labels = c("T1", "T2", "T3")) +
    labs(y = "Value") +
    theme(axis.title.x = element_blank())

cytokine_fig <- cytokine %>%
    group_by(TimePoint, Cytokine) %>%
    summarise(mean_value = mean(Value, na.rm = T), std_value = sd(Value, na.rm = T), se_value = std_value / sqrt(n()), .groups = "drop") %>%
    mutate(TimePoint = factor(TimePoint)) %>%
    ggplot(aes(x = TimePoint)) +
    geom_point(aes(y = mean_value)) +
    geom_errorbar(aes(ymin = mean_value - se_value, ymax = mean_value + se_value), width = 0.2) +
    facet_wrap(Cytokine ~ ., scales = "free_y", ncol = 8) +
    theme_minimal() +
    scale_x_discrete(labels = c("T1", "T2", "T3")) +
    labs(y = "Value") +
    theme(axis.title.x = element_blank())

library(cowplot)
fig4a <- plot_grid(lab_fig, cytokine_fig, ncol = 1, rel_heights = c(1, 1))
ggsave("figure/figure4/figure4A.pdf", fig4a, width = 8, height = 4, units = "in")

lab_fig <- labs %>%
    group_by(group, timepoint, code_name) %>%
    summarise(mean_value = mean(result_value, na.rm = T), std_value = sd(result_value, na.rm = T), se_value = std_value / sqrt(n()), .groups = "drop") %>%
    filter(timepoint == 1) %>%
    ggplot(aes(x = group)) +
    geom_point(aes(y = mean_value)) +
    geom_errorbar(aes(ymin = mean_value - se_value, ymax = mean_value + se_value), width = 0.2) +
    facet_wrap(code_name ~ ., scales = "free_y", ncol = 8) +
    theme_minimal() +
    labs(y = "Value") +
    theme(axis.title.x = element_blank())

# FIGURE 4B ##################
## relation between ri and values
cor_test_lab <- function(lab) {
    a <- ri_summary %>%
        group_by(timepoint) %>%
        summarise(mean_value = median(mean))
    crps <- labs %>%
        mutate(code_name = recode(code_name, "CRP (C-Reactive Protein)[Serum]" = "CRP", "WBC COUNT[Whole blood]" = "WBC (/uL)", "Lymphocyte(%)[Whole blood]" = "Lymphocyte (%)", "Neutrophil(%)[Whole blood]" = "Neutrophil (%)")) %>%
        filter(code_name == {{ lab }})
    b <- crps %>%
        group_by(timepoint) %>%
        summarise(mean_value = median(result_value))

    cor.test(a$mean_value, b$mean_value)$estimate
}
a <- ri_summary %>%
    ungroup() %>%
    mutate(value_norm = (mean - min(mean)) / (max(mean) - min(mean)))

b <- labs %>%
    mutate(code_name = recode(code_name, "CRP (C-Reactive Protein)[Serum]" = "CRP", "WBC COUNT[Whole blood]" = "WBC (/uL)", "Lymphocyte(%)[Whole blood]" = "Lymphocyte (%)", "Neutrophil(%)[Whole blood]" = "Neutrophil (%)")) %>%
    ungroup() %>%
    group_by(code_name) %>%
    mutate(value_norm = (result_value - min(result_value)) / (max(result_value) - min(result_value))) %>%
    ungroup()

c <- cytokine %>%
    ungroup() %>%
    group_by(Cytokine) %>%
    mutate(value_norm = (Value - min(Value)) / (max(Value) - min(Value))) %>%
    ungroup()

bind_rows(list(
    "ri" = a %>% select(No, timepoint, value_norm), "lab" =
        b %>% select(No, timepoint, value_norm, code_name)
), .id = "item") %>%
    mutate(code_name = ifelse(is.na(code_name), item, code_name)) %>%
    select(-item) %>%
    rename(item = code_name) %>%
    group_by(timepoint, item) %>%
    summarize(mean_value = mean(value_norm)) %>%
    ggplot(aes(x = timepoint, y = mean_value, color = item, group = item)) +
    geom_point() +
    geom_line() +
    theme_minimal()

ri_table <- a %>% select(No, timepoint, value_norm)
cytokine_table <- c %>%
    select(No = Patient, timepoint = TimePoint, value_norm, code_name = Cytokine) %>%
    mutate(timepoint = factor(timepoint)) %>%
    filter(code_name %in% c("CCL2/MCP-1", "IL-10", "IL-2", "TNF-alpha"))

bind_rows(list(
    "ri" = ri_table,
    "cytokine" = cytokine_table, .id = "item"
)) %>%
    mutate(code_name = ifelse(is.na(code_name), item, code_name)) %>%
    select(-item) %>%
    rename(item = code_name) %>%
    group_by(timepoint, item) %>%
    summarize(mean_value = mean(value_norm)) %>%
    ggplot(aes(x = timepoint, y = mean_value, color = item, group = item)) +
    geom_point() +
    geom_line() +
    theme_minimal()

c("CRP", "WBC (/uL)", "Neutrophil (%)", "Lymphocyte (%)") %>% map_dbl(cor_test_lab)

# FIGURE 4C ##################
## survival and non-survival
lab_survival_fig <- labs %>%
    mutate(group = ifelse(No %in% c(4, 6), "Non-survival", "Survival")) %>%
    mutate(group = factor(group, levels = c("Survival", "Non-survival"))) %>%
    mutate(code_name = recode(code_name, "CRP (C-Reactive Protein)[Serum]" = "CRP", "WBC COUNT[Whole blood]" = "WBC (/uL)", "Lymphocyte(%)[Whole blood]" = "Lymphocyte (%)", "Neutrophil(%)[Whole blood]" = "Neutrophil (%)")) %>%
    mutate(code_name = factor(code_name, levels = c("CRP", "WBC (/uL)", "Lymphocyte (%)", "Neutrophil (%)"))) %>%
    group_by(timepoint, code_name, group) %>%
    summarise(mean_value = mean(result_value, na.rm = T), std_value = sd(result_value, na.rm = T), se_value = std_value / sqrt(n()), .groups = "drop") %>%
    filter(timepoint == 1, code_name == "CRP") %>%
    ggplot(aes(x = group)) +
    geom_point(aes(y = mean_value)) +
    geom_errorbar(aes(ymin = mean_value - se_value, ymax = mean_value + se_value), width = 0.2) +
    facet_wrap(code_name ~ ., scales = "free_y", ncol = 8) +
    theme_minimal() +
    labs(y = "Value") +
    theme(axis.title.x = element_blank())
ggsave("figure/figure4/figure4c-1.pdf", lab_survival_fig, width = 4, height = 4, units = "in")

cytokine %>%
    mutate(group = ifelse(Patient %in% c(4, 6), "Non-survival", "Survival")) %>%
    mutate(group = factor(group, levels = c("Survival", "Non-survival"))) %>%
    group_by(TimePoint, Cytokine, group) %>%
    summarise(mean_value = mean(Value, na.rm = T), std_value = sd(Value, na.rm = T), se_value = std_value / sqrt(n()), .groups = "drop") %>%
    filter(Cytokine %in% c("CCL2/MCP-1", "IL-10", "IL-2", "TNF-alpha")) %>%
    filter(TimePoint == 1) %>%
    ggplot(aes(x = group)) +
    geom_point(aes(y = mean_value)) +
    geom_errorbar(aes(ymin = mean_value - se_value, ymax = mean_value + se_value), width = 0.2) +
    facet_wrap(Cytokine ~ ., scales = "free_y", ncol = 8) +
    theme_minimal() +
    labs(y = "Value") +
    theme(axis.title.x = element_blank())
