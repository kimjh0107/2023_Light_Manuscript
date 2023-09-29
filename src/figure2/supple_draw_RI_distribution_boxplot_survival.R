library(Seurat)
library(tidyverse)
library(here)
library(ggpubr)
library(showtext)

font_add_google("Encode Sans")

# Overall
df <- read_csv(here('data/processed/survival_overall_RI.csv'))
hc <- read_csv(here('data/processed/overall_RI.csv')) %>% filter(status == "Healthy control")
df <- rbind(df,hc)
df$status <- factor(df$status, levels = c('Non-survival', 'Survival', "Healthy control"))

p1 <- df %>% 
        ggboxplot(x = "status", y = "mean", 
                fill = 'status',
                palette = c('#3C5488B2', "#E64B35B2", "#2EC1AC"),
                xlab = "Status", 
                ylab = "RI value",
                outlier.shape = NA) + 
        scale_x_discrete(limits=c('Non-survival', 'Survival', "Healthy control")) + 
        scale_y_continuous(limits = c(1.37, 1.39), breaks = c(1.37,1.38,1.39)) +
        stat_compare_means(label = "p.signif", method = "t.test",ref.group = "Healthy control")  

p1 <- p1 + theme(axis.title.x = element_text(size = 7),
                 axis.text.x = element_text(size=7), 
                 axis.title.y = element_text(size = 7),
                 axis.text.y = element_text(size=7),
                 legend.position = "none")

ggsave(here("figure/figure1/supple_survival_boxplot_overall_distribution.pdf"), p1, width = 4, height = 4, dpi = 300)




# Nucleus
df <- read_csv(here('data/processed/survival_13800_RI.csv'))
hc <- read_csv(here('data/processed/13800_RI.csv')) %>% filter(status == "Healthy control")
df <- rbind(df,hc)
df$status <- factor(df$status, levels = c('Non-survival', 'Survival', "Healthy control"))

p1 <- df %>% 
        ggboxplot(x = "status", y = "mean", 
                fill = 'status',
                palette = c('#3C5488B2', "#E64B35B2", "#2EC1AC"),
                xlab = "Status", 
                ylab = "RI value",
                outlier.shape = NA) + 
        scale_x_discrete(limits=c('Non-survival', 'Survival', "Healthy control")) + 
        scale_y_continuous(limits = c(1.38, 1.39), breaks = c(1.38,1.385,1.39)) +
        stat_compare_means(label = "p.signif", method = "t.test",ref.group = "Healthy control")  

p1 <- p1 + theme(axis.title.x = element_text(size = 7),
                 axis.text.x = element_text(size=7), 
                 axis.title.y = element_text(size = 7),
                 axis.text.y = element_text(size=7),
                 legend.position = "none")

ggsave(here("figure/figure1/supple_survival_boxplot_nucleus_distribution.pdf"), p1, width = 4, height = 4, dpi = 300)
