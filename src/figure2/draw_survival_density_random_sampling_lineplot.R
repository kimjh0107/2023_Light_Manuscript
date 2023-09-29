library(tidyverse)
library(here)
library(showtext)
font_add_google("Encode Sans")

# read data 
# nucleus 
df <- read_csv(here('data/raw/survival_overall_sampling_5_cell_num.csv'))
df <- pivot_longer(df, cols = c("1", "2", "3", "4", "5", "6", "7", "8"), names_to = "shell_num", values_to = "RI_value")
write.csv(df, here('data/processed/survival_overall_density_random_sampling_5_cell.csv'))

df$shell_num <- as.numeric(df$shell_num)
df$RI_value <- as.numeric(df$RI_value)

unique(df$timepoint)
fig <- df %>%
  ggplot(aes(shell_num, RI_value, color = timepoint, fill = timepoint)) +
  geom_smooth(method = "loess", level = 0.95) +
  geom_line(aes(group = interaction(timepoint, cell_num)), alpha = 0.1, size=0.2) +
  theme_minimal() +
  scale_x_continuous(breaks = c(1, 2, 3, 4, 5, 6, 7, 8), label = c("1\nCenter", "2", "3", "4", "5", "6", "7", "8\nPeriphery")) +
  labs(x = "Shell number", y = 'Shell RI density / Background RI density', color = "Timepoint", fill = "Timepoint") +
  scale_fill_manual(values=c('#3C5488B2', "#E64B35B2")) + 
  scale_colour_manual(values=c('#3C5488B2', "#E64B35B2")) + 
  scale_y_continuous(limits = c(0, 1)) 

fig <- fig + theme(axis.title.x = element_text(size = 7),
                 axis.text.x = element_text(size=7), 
                 axis.title.y = element_text(size = 7),
                 axis.text.y = element_text(size=7))
                #  axis.text.y = element_text(size=7),
                #  legend.position = "none")

ggsave(here('figure/figure2/lineplot_survival_overall_random_sampling_5.pdf'), fig, width = 6, height = 4)

# ggsave(here('lineplot_overall_random_sampling_5_add_hc.pdf'), fig, width = 6, height = 4)





















