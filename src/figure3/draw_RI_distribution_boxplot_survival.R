library(Seurat)
library(tidyverse)
library(here)
library(ggpubr)
library(showtext)

font_add_google("Encode Sans")
# read data 
# nucleus 
t1 <- read_csv(here('/home/jhkim/2022-tomocube-sepsis-manuscript/data/RI_distribution/mean_by_folder_t1_threshold_overall.csv'))

t1$patient <- ifelse(t1$folder %in% c('20220502'), 'p4', "NA")
t1$patient <- ifelse(t1$folder %in% c('20220519'), 'p5', t1$patient)
t1$patient <- ifelse(t1$folder %in% c('20220520'), 'p6', t1$patient)
t1$patient <- ifelse(t1$folder %in% c('20220526'), 'p7', t1$patient)
t1$patient <- ifelse(t1$folder %in% c('20220526_2'), 'p8', t1$patient)
t1$patient <- ifelse(t1$folder %in% c('20220602_3'), 'p9', t1$patient)
t1$patient <- ifelse(t1$folder %in% c('20220603_3'), 'p10', t1$patient)
t1$patient <- ifelse(t1$folder %in% c('20220607_2'), 'p11', t1$patient)

# mortaltiy
t1$survival <- ifelse(t1$patient %in% c('p5','p7','p8','p9','p10','p11'), 'Survived', "NA")
t1$survival <- ifelse(t1$patient %in% c('p4','p6'), 'Non_survived', t1$survival)

colnames(t1) <- c("cell_num", "img_mean", "folder", "patient", "survival")
# t1_pivot_longer <- pivot_longer(t1, cols = c("8", "7", "6", "5", "4", "3", "2", "1"), names_to = "shell_num", values_to = "density")
# t1_pivot_longer$status <- 'Septic shock'
# t1_pivot_longer <- t1_pivot_longer %>% filter(!is.na(density))
# t1_pivot_longer$density <- t1_pivot_longer$density / 10000
t1 <- t1 %>% filter(!is.na(img_mean))
t1$img_mean <- t1$img_mean / 10000



df <- t1 %>% group_by(survival, cell_num) %>% summarise(mean = mean(img_mean), sd = sd(img_mean))


my_comparisons <- list(c("Survived", "Non_survived"))

p1 <- df %>% 
        ggboxplot(x = "survival", y = "mean", 
                    color = "survival", palette = c('blue',"red"),
                    add = "jitter", 
                    title = "RI value distribution",
                    xlab = "Status", 
                    ylab = "RI value") + 
        stat_compare_means(comparisons = my_comparisons, label = "p.signif") + 
        scale_x_discrete(limits=c('Survived', 'Non_survived')) + 
        scale_x_continuous("Status", labels = as.character(status), breaks = status)


#plot1 <- p1 + theme(text = element_text(family = "Encode Sans")) 
ggsave(here("figure/figure2/boxplot_ri_distribution_survival.pdf"), p1, width = 7, height = 7, dpi = 300)
ggsave(here("figure/figure2/boxplot_ri_distribution.png"), p1, width = 7, height = 7, dpi = 300)

