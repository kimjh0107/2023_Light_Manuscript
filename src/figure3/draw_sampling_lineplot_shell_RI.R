library(here)
library(glue)
library(arrow)
library(tidyverse)

SAMPLE_CELL_NUMBER <- 100
data <- read_feather(here("data/processed/figure2/RI_distribution.feather"))

sampled_cell <- data %>%
  select(threshold, cell_num) %>%
  distinct() %>%
  group_by(threshold) %>%
  slice_sample(n = SAMPLE_CELL_NUMBER)

fig_data <- sampled_cell %>%
  left_join(data) %>%
  mutate(threshold = recode(threshold, !!!thresholds_map)) %>%
  mutate(threshold = factor(threshold, levels = c("Nucleus", "Cytoplasm", "Membrane"))) %>%
  mutate(timepoint = recode(timepoint, !!!timpoints_map)) %>%
  mutate(timepoint = factor(timepoint, level = c("T1", "T2", "T3", "Healthy Control")))

fig <- fig_data %>%
  ggplot(aes(shell_num, density / 10000, color = timepoint, fill = timepoint)) +
  geom_smooth(method = "loess", level = 0.95) +
  geom_line(aes(group = interaction(timepoint, cell_num)), alpha = 0.1) +
  theme_minimal() +
  facet_wrap(~threshold) +
  scale_x_continuous(breaks = c(1, 2, 3, 4, 5, 6, 7, 8), label = c("1\nCenter", "2", "3", "4", "5", "6", "7", "8\nPeripheral")) +
  labs(x = "Shell Number", y = "RI", color = "Timepoint", fill = "Timepoint") +
  theme(panel.spacing = unit(2, "lines"))

ggsave(filename = here("figure/figure2/figure2-CDE.pdf"), plot = fig, width = 12, height = 6, units = "in")

# TODO: p-value 필요
# TODO: bootstrap을 통해서 robust한 p-value 및 graph 그릴 것.

#* mixed_model <- lme(density ~ status + shell_num + status * shell_num, random = ~ 1 | cell_num, data = df)
#* summary(mixed_model)
