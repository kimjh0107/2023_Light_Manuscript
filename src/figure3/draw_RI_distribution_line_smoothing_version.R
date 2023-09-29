library(tidyverse)
library(here)
library(showtext)
font_add_google("Encode Sans")

# read data 
# nucleus 
t1 <- read_csv(here('data/RI_distribution/slice_RI_mean_t1_threshold_overall.csv'))
colnames(t1) <- c("cell_num", "8", "7", "6", "5", "4", "3", "2", "1")
t1_pivot_longer <- pivot_longer(t1, cols = c("8", "7", "6", "5", "4", "3", "2", "1"), names_to = "shell_num", values_to = "density")
t1_pivot_longer$status <- 'Septic'
t1_pivot_longer <- t1_pivot_longer %>% filter(!is.na(density))
t1_pivot_longer$density <- t1_pivot_longer$density / 10000
#t1_pivot_longer_mean <- t1_pivot_longer %>% group_by(shell_num) %>% summarise(mean = mean(density), sd = sd(density))

t2 <- read_csv(here('data/RI_distribution/slice_RI_mean_t2_threshold_overall.csv'))
colnames(t2) <- c("cell_num", "8", "7", "6", "5", "4", "3", "2", "1")
t2_pivot_longer <- pivot_longer(t2, cols = c("8", "7", "6", "5", "4", "3", "2", "1"), names_to = "shell_num", values_to = "density")
t2_pivot_longer$status <- 'Resolved'
t2_pivot_longer <- t2_pivot_longer %>% filter(!is.na(density))
t2_pivot_longer$density <- t2_pivot_longer$density / 10000
#t2_pivot_longer_mean <- t2_pivot_longer %>% group_by(shell_num) %>% summarise(mean = mean(density), sd = sd(density))

t3 <- read_csv(here('data/RI_distribution/slice_RI_mean_t3_threshold_overall.csv'))
colnames(t3) <- c("cell_num", "8", "7", "6", "5", "4", "3", "2", "1")
t3_pivot_longer <- pivot_longer(t3, cols = c("8", "7", "6", "5", "4", "3", "2", "1"), names_to = "shell_num", values_to = "density")
t3_pivot_longer$status <- 'Discharge'
t3_pivot_longer <- t3_pivot_longer %>% filter(!is.na(density))
t3_pivot_longer$density <- t3_pivot_longer$density / 10000
#t3_pivot_longer_mean <- t3_pivot_longer %>% group_by(shell_num) %>% summarise(mean = mean(density), sd = sd(density))

hc <- read_csv(here('data/RI_distribution/slice_RI_mean_hc_threshold_overall.csv'))
colnames(hc) <- c("cell_num", "8", "7", "6", "5", "4", "3", "2", "1")
hc_pivot_longer <- pivot_longer(hc, cols = c("8", "7", "6", "5", "4", "3", "2", "1"), names_to = "shell_num", values_to = "density")
hc_pivot_longer$status <- 'Healthy'
hc_pivot_longer <- hc_pivot_longer %>% filter(!is.na(density))
hc_pivot_longer$density <- hc_pivot_longer$density / 10000
#hc_pivot_longer_mean <- hc_pivot_longer %>% group_by(shell_num) %>% summarise(mean = mean(density), sd = sd(density))



# merge three dataframes into one data 
df <- rbind(t1_pivot_longer, t2_pivot_longer, t3_pivot_longer, hc_pivot_longer)
df_mean <- df %>% group_by(status, shell_num) %>% summarise(mean = mean(density), sd = sd(density))


names(COLS)
COLS = c("red","turquoise","orange", 'green')
names(COLS) = c("Septic","Resolved","Discharge", 'Healthy')
###
overall_plot1 <- ggplot(df_mean) + 
                        geom_smooth(aes(as.numeric(shell_num),mean,colour=status,fill=status), method = loess, level = 0.95) +
                        scale_fill_manual(name="status",values=COLS)+
                        scale_color_manual(name="status",values=COLS) + 
                        scale_x_continuous(breaks = seq(1, 8, 1)) +
                        scale_y_continuous(limits = c(1.345, 1.39)) +
                        xlab("Center to peripheral") +
                        ylab("RI value") +  
                        theme_classic() 



nuclues_plot1 <- nucleus_plot1 + theme(legend.position = "none")
cytoplasm_plot1 <- cytoplasm_plot1 + theme(legend.position = "none")
membrane_plot1 <- membrane_plot1 + theme(legend.position = "none")
overall_plot1 <- overall_plot1 + theme(legend.position = "none")
plot_list <- list(nuclues_plot1, cytoplasm_plot1, membrane_plot1, overall_plot1)
# make no legend 

ggsave(here('figure/figure2/smooth_lineplot_cowplot.png'), plot_grid(plotlist = plot_list, ncol = 4, nrow = 1), width = 16, height = 3, dpi = 300)
ggsave(here('figure/figure2/smooth_lineplot_cowplot.pdf'), plot_grid(plotlist = plot_list, ncol = 4, nrow = 1), width = 16, height = 3, dpi = 300)
