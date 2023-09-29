library(tidyverse)
library(here)
library(showtext)
font_add_google("Encode Sans")

# read data
# nucleus
df <- read_csv(here("data/raw/overall_sampling_density_5_cell_num_add_healthy.csv"))
df <- pivot_longer(df, cols = c("1", "2", "3", "4", "5", "6", "7", "8"), names_to = "shell_num", values_to = "RI_value")
df$density <- df$RI_value / 10000
write.csv(df, here("data/processed/overall_density_random_sampling_5_cell.csv"))

df$shell_num <- as.numeric(df$shell_num)
df$RI_value <- as.numeric(df$RI_value)
unique(df$timepoint)

fig <- df %>%
  ggplot(aes(shell_num, RI_value, color = timepoint, fill = timepoint)) +
  geom_smooth(method = "loess", level = 0.95) +
  geom_line(aes(group = interaction(timepoint, cell_num)), alpha = 0.1, size = 0.2) +
  theme_minimal() +
  scale_x_continuous(breaks = c(1, 2, 3, 4, 5, 6, 7, 8), label = c("1\nCenter", "2", "3", "4", "5", "6", "7", "8\nPeriphery")) +
  labs(title = "overall random sampling 5", x = "Shell number", y = "Shell RI density / Background RI density", color = "Timepoint", fill = "Timepoint") +
  scale_fill_manual(values = c("#2EC1AC", "#D83A56", "#F8B400", "#1C315E")) +
  scale_colour_manual(values = c("#2EC1AC", "#D83A56", "#F8B400", "#1C315E")) +
  scale_y_continuous(limits = c(0, 1))

# ggsave(here('figures/fig_2b.pdf'), fig, width = 6, height = 4)
ggsave(here("lineplot_overall_random_sampling_5_add_hc.pdf"), fig, width = 6, height = 4)
