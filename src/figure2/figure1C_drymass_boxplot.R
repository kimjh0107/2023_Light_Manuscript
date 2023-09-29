library(tidyverse)
library(here)
library(ggsignif)
library(rstatix)
# Overall
df <- read_csv(here("data/processed/raw_physical_quantity.csv")) %>%
        select(timepoint = timepoint.x, drymass) %>%
        mutate(timepoint = factor(timepoint, levels = c("t1", "t2", "t3", "healthy")))

summary(aov(drymass ~ timepoint, data = df))

fig <- df %>%
        ggplot(aes(timepoint, drymass)) +
        geom_boxplot(outlier.shape = NA) +
        theme_classic() +
        labs(x = "Status", y = "Dry mass (pg)") +
        scale_x_discrete(labels = c("T1", "T2", "T3", "H")) +
        geom_signif(
                comparisons = list(c("t1", "healthy")),
                map_signif_level = TRUE,
                y_position = 150,
                textsize = 2,
                tip_length = 0,
                vjust = 0.5
        ) +
        geom_signif(
                comparisons = list(c("t2", "healthy")),
                map_signif_level = TRUE,
                y_position = 120,
                textsize = 2,
                tip_length = 0,
                vjust = 0.5
        ) +
        geom_signif(
                comparisons = list(c("t3", "healthy")),
                map_signif_level = TRUE,
                y_position = 90,
                textsize = 2,
                tip_length = 0,
                vjust = 0.5
        ) +
        theme(
                axis.text.x = element_text(size = 5),
                axis.title.x = element_blank(),
                axis.title.y = element_text(size = 5),
                axis.text.y = element_text(size = 5),
                legend.position = "none"
        ) +
        ylim(0, 190)
fig

ggsave(here("figure/figure1/figure1C_drymass_boxplot.pdf"), fig, width = 40, height = 40, units = "mm")
