library(tidyverse)
library(here)

# Overall
df <- read_csv(here("data/processed/overall_RI.csv")) %>%
    mutate(status = recode(status, "Septic shock" = "t1", "Shock resolved" = "t2", "Before discharge" = "t3", "Healthy control" = "healthy")) %>%
    mutate(status = factor(status, levels = c("t1", "t2", "t3", "healthy")))

summary(aov(mean ~ status, data = df))

fig <- df %>%
    ggplot(aes(status, mean)) +
    geom_boxplot(outlier.shape = NA) +
    theme_classic() +
    labs(x = "Status", y = "RI") +
    scale_x_discrete(labels = c("T1", "T2", "T3", "H")) +
    geom_signif(
        comparisons = list(c("t1", "healthy")),
        map_signif_level = TRUE,
        y_position = 1.40,
        textsize = 2,
        tip_length = 0,
        vjust = 0.6
    ) +
    geom_signif(
        comparisons = list(c("t2", "healthy")),
        map_signif_level = TRUE,
        y_position = 1.392,
        textsize = 1.5,
        tip_length = 0
    ) +
    geom_signif(
        comparisons = list(c("t3", "healthy")),
        map_signif_level = TRUE,
        y_position = 1.385,
        textsize = 2,
        tip_length = 0,
        vjust = 0.6
    ) +
    theme(
        axis.title.x = element_blank(),
        axis.text.x = element_text(size = 5),
        axis.title.y = element_text(size = 5),
        axis.text.y = element_text(size = 5),
        legend.position = "none"
    ) +
    ylim(1.35, 1.41)
fig

ggsave(here("figure/figure1/figure1C_overall_ri.pdf"), fig, width = 40, height = 40, units = "mm")
