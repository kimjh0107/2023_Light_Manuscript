library(Seurat)
library(tidyverse)
library(here)
library(ggpubr)
library(showtext)

font_add_google("Encode Sans")
# read data 
# nucleus 
t1 <- read_csv(here('data/RI_distribution/slice_RI_mean_t1_threshold_overall.csv'))
colnames(t1) <- c("cell_num", "8", "7", "6", "5", "4", "3", "2", "1")
t1_pivot_longer <- pivot_longer(t1, cols = c("8", "7", "6", "5", "4", "3", "2", "1"), names_to = "shell_num", values_to = "density")
t1_pivot_longer$status <- 'Septic shock'
t1_pivot_longer <- t1_pivot_longer %>% filter(!is.na(density))
t1_pivot_longer$density <- t1_pivot_longer$density / 10000

t2 <- read_csv(here('data/RI_distribution/slice_RI_mean_t2_threshold_overall.csv'))
colnames(t2) <- c("cell_num", "8", "7", "6", "5", "4", "3", "2", "1")
t2_pivot_longer <- pivot_longer(t2, cols = c("8", "7", "6", "5", "4", "3", "2", "1"), names_to = "shell_num", values_to = "density")
t2_pivot_longer$status <- 'Shock resolved'
t2_pivot_longer <- t2_pivot_longer %>% filter(!is.na(density))
t2_pivot_longer$density <- t2_pivot_longer$density / 10000
#t2_pivot_longer_mean <- t2_pivot_longer %>% group_by(shell_num) %>% summarise(mean = mean(density), sd = sd(density))

t3 <- read_csv(here('data/RI_distribution/slice_RI_mean_t3_threshold_overall.csv'))
colnames(t3) <- c("cell_num", "8", "7", "6", "5", "4", "3", "2", "1")
t3_pivot_longer <- pivot_longer(t3, cols = c("8", "7", "6", "5", "4", "3", "2", "1"), names_to = "shell_num", values_to = "density")
t3_pivot_longer$status <- 'Before discharge'
t3_pivot_longer <- t3_pivot_longer %>% filter(!is.na(density))
t3_pivot_longer$density <- t3_pivot_longer$density / 10000

hc <- read_csv(here('data/RI_distribution/slice_RI_mean_hc_threshold_overall.csv'))
colnames(hc) <- c("cell_num", "8", "7", "6", "5", "4", "3", "2", "1")
hc_pivot_longer <- pivot_longer(hc, cols = c("8", "7", "6", "5", "4", "3", "2", "1"), names_to = "shell_num", values_to = "density")
hc_pivot_longer$status <- 'Healthy control'
hc_pivot_longer <- hc_pivot_longer %>% filter(!is.na(density))
hc_pivot_longer$density <- hc_pivot_longer$density / 10000


df <- bind_rows(t1_pivot_longer, t2_pivot_longer, t3_pivot_longer, hc_pivot_longer)
df <- df %>% group_by(status, cell_num) %>% summarise(mean = mean(density), sd = sd(density))


my_comparisons <- list(c("Before discharge", "Healthy control"),
                       c("Before discharge", "Shock resolved"), 
                       c("Before discharge", "Septic shock"),  
                       c("Shock resolved", "Septic shock"),
                       c("Shock resolved", "Healthy control"),
                       c("Septic shock", "Healthy control"))


vlnplot <-  ggplot(df, aes(x = status, y = mean, fill = status)) + 
                geom_violin() + 
                scale_fill_manual(values=c('blue', "green","red", "#E7B800")) + 
               # theme(legend.position=c("#E7B800","green", "green",'blue')) + 
                stat_compare_means(comparisons = my_comparisons, label = "p.signif") + 
                scale_x_discrete(limits=c('Septic shock', 'Shock resolved', 'Before discharge', 'Healthy control')) + 
                theme_classic() 


plot1 <- vlnplot + theme(text = element_text(family = "Encode Sans")) + theme(legend.position = "none") 
ggsave(here("figure/figure2/vlnplot_ri_distribution.pdf"), plot1, width = 7, height = 7, dpi = 300)
ggsave(here("figure/figure2/vlnplot_ri_distribution.png"), plot1, width = 7, height = 7, dpi = 300)

