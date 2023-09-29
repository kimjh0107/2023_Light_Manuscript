library(tidyverse)
library(here)
library(ggbreak)

data <- read_csv(here("data/raw/figure3/random_sampling_auc_prognosis_timepoint1_CD8_healthy_timepoint1_CD8.csv"))

fig <- data %>%
  mutate(num = as.integer(num)) %>%
  ggplot(aes(x = num, y = auc, group = num)) +
  geom_boxplot() +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red", size = 0.5) +
  ylim(0.75, 1) +
  scale_x_continuous(breaks = c(1, 2, 3, 4, 5, 9, 10), labels = c("1", "2", "3", "4", "5", "", "")) +
  scale_x_break(c(5, 9), scale = 0.35) +
  labs(x = "Number of cells", y = "AUROC") +
  theme_classic() +
  theme(
    axis.text.x.top = element_blank(),
    axis.ticks.x.top = element_blank(),
    axis.line.x.top = element_blank(),
    text = element_text(size = 6)
  )
fig

ggsave(here("figure/figure3/figure3D.pdf"), fig, width = 90, height = 60, units = "mm")
