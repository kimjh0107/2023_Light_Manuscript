library(tidyverse)
library(here)
library(showtext)
font_add_google("Encode Sans")

# read data 
# nucleus 
df <- read_csv(here('data/raw/sampling_500_cell_num.csv'))
unique(df$cell_num)
df <- pivot_longer(df, cols = c("1", "2", "3", "4", "5", "6", "7", "8"), names_to = "shell_num", values_to = "RI_value")
df$density <- df$RI_value / 10000
write.csv(df, here('data/processed/random_sampling_500_cell_num.csv'))


df$shell_num <- as.numeric(df$shell_num)
df$RI_value <- as.numeric(df$RI_value)
fig <- df %>%
  ggplot(aes(shell_num, RI_value, color = timepoint, fill = timepoint)) +
  geom_smooth(method = "loess", level = 0.95) +
  geom_line(aes(group = interaction(timepoint, cell_num)), alpha = 0.1, size=0.2) +
  theme_minimal() +
  #facet_wrap(~threshold) +
  scale_x_continuous(breaks = c(1, 2, 3, 4, 5, 6, 7, 8), label = c("1\nCenter", "2", "3", "4", "5", "6", "7", "8\nPeripheral")) +
  labs(title = "Random sampling 500",x = "Shell Number", y = "RI", color = "Timepoint", fill = "Timepoint") +
  theme(panel.spacing = unit(2, "lines")) + 
  scale_fill_manual(values=c("#2EC1AC", "#D83A56", "#F8B400", "#1C315E")) + 
  scale_colour_manual(values=c("#2EC1AC", "#D83A56", "#F8B400", "#1C315E")) + 
  scale_y_continuous(limits = c(13830, 13900))

# ggsave(here('figures/fig_2b.pdf'), fig, width = 6, height = 4)
ggsave(here('lineplot_random_sampling_500.pdf'), fig, width = 6, height = 4)


