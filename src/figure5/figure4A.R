library(cowplot)
library(tidyverse)
library(here)
library(arrow)
library(glue)
ri_summary <- read_feather(here("data/processed/figure4/ri_summary.feather"))

ri_overall <- read_csv(here("data/processed/overall_RI.csv")) %>%
    mutate(status = recode(status, "Septic shock" = "t1", "Shock resolved" = "t2", "Before discharge" = "t3", "Healthy control" = "healthy")) %>%
    filter(status != "healthy") %>%
    mutate(status = factor(status, levels = c("t1", "t2", "t3", "healthy")))

ri_nucleus <- read_csv(here("data/processed/13800_RI.csv")) %>%
    mutate(status = recode(status, "Septic shock" = "t1", "Shock resolved" = "t2", "Before discharge" = "t3", "Healthy control" = "healthy")) %>%
    filter(status != "healthy") %>%
    mutate(status = factor(status, levels = c("t1", "t2", "t3", "healthy")))

labs <- read_feather(here("data/processed/figure4/labs.feather"))
cytokine <- read_feather(here("data/processed/figure4/cytokines.feather"))

cor_test_lab <- function(lab) {
    a <- ri_summary %>%
        group_by(timepoint) %>%
        summarise(mean_value = median(mean))

    lab_summary <- labs %>%
        mutate(code_name = recode(code_name, "CRP (C-Reactive Protein)[Serum]" = "CRP", "WBC COUNT[Whole blood]" = "WBC (/uL)", "Lymphocyte(%)[Whole blood]" = "Lymphocyte (%)", "Neutrophil(%)[Whole blood]" = "Neutrophil (%)"))

    cytokine_summary <- cytokine %>%
        select(No, timepoint = TimePoint, code_name = Cytokine, result_value = Value, group) %>%
        filter(code_name %in% c("CCL2/MCP-1", "IL-10", "IL-2", "TNF-alpha")) %>%
        mutate(timepoint = factor(timepoint), code_name = factor(code_name))

    item_summary <- bind_rows(lab_summary, cytokine_summary) %>%
        filter(code_name == {{ lab }})

    b <- item_summary %>%
        group_by(timepoint) %>%
        summarise(mean_value = median(result_value))

    cor.test(a$mean_value, b$mean_value)$estimate
}

c("CRP", "WBC (/uL)", "Neutrophil (%)", "Lymphocyte (%)", "CCL2/MCP-1", "IL-10", "IL-2", "TNF-alpha") %>% map_dbl(cor_test_lab)

ri_overall_fig <- ri_overall %>%
    group_by(status) %>%
    summarise(mean_value = mean(mean, na.rm = T), std_value = sd(mean, na.rm = T), se_value = std_value / sqrt(n()), .groups = "drop") %>%
    ggplot(aes(x = status)) +
    geom_point(aes(y = mean_value)) +
    geom_errorbar(aes(ymin = mean_value - se_value, ymax = mean_value + se_value), width = 0.2) +
    labs(y = "RI", title = "Overall RI") +
    scale_x_discrete(labels = c("T1", "T2", "T3")) +
    theme_minimal() +
    theme(
        plot.title = element_text(size = 5, hjust = 0.5, vjust = -1),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 5),
        axis.text.x = element_text(size = 5),
        axis.text.y = element_text(size = 5),
        legend.position = "none"
    )

ri_nucleus_fig <- ri_nucleus %>%
    group_by(status) %>%
    summarise(mean_value = mean(mean, na.rm = T), std_value = sd(mean, na.rm = T), se_value = std_value / sqrt(n()), .groups = "drop") %>%
    ggplot(aes(x = status)) +
    geom_point(aes(y = mean_value)) +
    geom_errorbar(aes(ymin = mean_value - se_value, ymax = mean_value + se_value), width = 0.2) +
    labs(y = "RI", title = "Nucleus RI") +
    scale_x_discrete(labels = c("T1", "T2", "T3")) +
    theme_minimal() +
    theme(
        plot.title = element_text(size = 5, hjust = 0.5, vjust = -1),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 5),
        axis.text.x = element_text(size = 5),
        axis.text.y = element_text(size = 5),
        legend.position = "none"
    )

lab_fig_data <- labs %>%
    group_by(timepoint, code_name) %>%
    summarise(mean_value = mean(result_value, na.rm = T), std_value = sd(result_value, na.rm = T), se_value = std_value / sqrt(n()), .groups = "drop")

lab_fig_cor_data <- lab_fig_data %>%
    group_by(code_name) %>%
    summarize(y = max(mean_value + se_value) + 1, .groups = "drop") %>%
    mutate(cor_value = code_name %>% as.character() %>% map_dbl(cor_test_lab) %>% map_dbl(round, 3))

lab_fig <- lab_fig_data %>%
    ggplot(aes(x = timepoint)) +
    geom_point(aes(y = mean_value)) +
    geom_errorbar(aes(ymin = mean_value - se_value, ymax = mean_value + se_value), width = 0.2) +
    geom_text(aes(x = 1.7, y = y, label = glue("ρ = {cor_value}")), data = lab_fig_cor_data, hjust = 0, vjust = 0, size = 2) +
    facet_wrap(code_name ~ ., scales = "free_y", ncol = 8) +
    theme_minimal() +
    scale_x_discrete(labels = c("T1", "T2", "T3")) +
    labs(y = "Value") +
    theme(
        strip.text.x = element_text(
            size = 5, hjust = 0.5
        ),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 5),
        axis.text.x = element_text(size = 5),
        axis.text.y = element_text(size = 5),
        legend.position = "none"
    )

cytokine_fig_data <- cytokine %>%
    group_by(TimePoint, Cytokine) %>%
    summarise(mean_value = mean(Value, na.rm = T), std_value = sd(Value, na.rm = T), se_value = std_value / sqrt(n()), .groups = "drop") %>%
    mutate(TimePoint = factor(TimePoint))

cytokine_fig_cor_data <- cytokine_fig_data %>%
    group_by(Cytokine) %>%
    summarize(y = max(mean_value + se_value), .groups = "drop") %>%
    mutate(cor_value = Cytokine %>% as.character() %>% map_dbl(cor_test_lab) %>% map_dbl(round, 3))

cytokine_fig <- cytokine_fig_data %>%
    ggplot(aes(x = TimePoint)) +
    geom_point(aes(y = mean_value)) +
    geom_errorbar(aes(ymin = mean_value - se_value, ymax = mean_value + se_value), width = 0.2) +
    geom_text(aes(x = 1.7, y = y, label = glue("ρ = {cor_value}")), data = cytokine_fig_cor_data, hjust = 0, vjust = 0, size = 2) +
    facet_wrap(Cytokine ~ ., scales = "free_y", ncol = 8) +
    theme_minimal() +
    scale_x_discrete(labels = c("T1", "T2", "T3")) +
    labs(y = "Value") +
    theme(
        strip.text.x = element_text(
            size = 5, hjust = 0.5
        ),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 5),
        axis.text.x = element_text(size = 5),
        axis.text.y = element_text(size = 5),
        legend.position = "none"
    )


fig4a1 <- plot_grid(ri_overall_fig, lab_fig, ncol = 2, rel_widths = c(1, 4))
fig4a2 <- plot_grid(ri_nucleus_fig, cytokine_fig, ncol = 2, rel_widths = c(1, 4))
fig4a <- plot_grid(fig4a1, fig4a2, ncol = 1, rel_heights = c(1, 1))
fig4a
ggsave("figure/figure4/figure4A.pdf", fig4a, width = 8, height = 4, units = "in", device = cairo_pdf)
