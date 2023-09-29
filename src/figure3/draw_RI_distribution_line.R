library(tidyverse)
library(here)
library(showtext)
library(cowplot)

font_add_google("Encode Sans")

# read data 
# nucleus 
t1 <- read_csv(here('data/RI_distribution/slice_RI_mean_hc_threshold_13800.csv'))
colnames(t1) <- c("cell_num", "8", "7", "6", "5", "4", "3", "2", "1")
t1_pivot_longer <- pivot_longer(t1, cols = c("8", "7", "6", "5", "4", "3", "2", "1"), names_to = "shell_num", values_to = "density")
t1_pivot_longer$status <- 'Septic'
t1_pivot_longer <- t1_pivot_longer %>% filter(!is.na(density))
t1_pivot_longer$density <- t1_pivot_longer$density / 10000
t1_pivot_longer_mean <- t1_pivot_longer %>% group_by(shell_num) %>% summarise(mean = mean(density), sd = sd(density))

p1 <- ggplot(data = t1_pivot_longer_mean, aes(x = as.numeric(shell_num), y = mean) , group=as.numeric(shell_num)) + 
        geom_point(size = .5) +
        geom_ribbon(aes(y = mean, ymin = mean - sd, ymax = mean + sd), alpha = .8, fill='#E00A0A') +
        #geom_smooth(method = lm, level=0.95) + 
        geom_line(color = 'black', linetype = "dashed") +
        xlab("Center to peripheral") +
        ylab("RI value") +  
        scale_x_continuous(breaks = seq(1, 8, 1)) +
        scale_y_continuous(limits = c(1.38, 1.395)) +
        theme_classic() 

# ggsave(p1, filename = "figure/figure2/lineplot_hc_nucleus.png", width = 5, height = 3, dpi = 300)
# ggsave(p1, filename = "figure/figure2/lineplot_hc_nucleus.pdf", width = 5, height = 3, dpi = 300)



# cytoplasm 
t1 <- read_csv(here('data/RI_distribution/slice_RI_mean_hc_threshold_13600_13800.csv'))
colnames(t1) <- c("cell_num", "8", "7", "6", "5", "4", "3", "2", "1")
t1_pivot_longer <- pivot_longer(t1, cols = c("8", "7", "6", "5", "4", "3", "2", "1"), names_to = "shell_num", values_to = "density")
t1_pivot_longer$status <- 'Septic'
t1_pivot_longer <- t1_pivot_longer %>% filter(!is.na(density))
t1_pivot_longer$density <- t1_pivot_longer$density / 10000
t1_pivot_longer_mean <- t1_pivot_longer %>% group_by(shell_num) %>% summarise(mean = mean(density), sd = sd(density))

p2 <- ggplot(data = t1_pivot_longer_mean, aes(x = as.numeric(shell_num), y = mean) , group=as.numeric(shell_num)) + 
        geom_point(size = .5) +
        geom_ribbon(aes(y = mean, ymin = mean - sd, ymax = mean + sd), alpha = .8, fill='#CAC718') +
        geom_line(color = 'black', linetype = "dashed") +
        xlab("Center to peripheral") +
        ylab("RI value") +  
        scale_x_continuous(breaks = seq(1, 8, 1)) +
        scale_y_continuous(limits = c(1.36, 1.38)) +
        theme_classic() 
        
# ggsave(p1, filename = "figure/figure2/lineplot_hc_cytoplasm.png", width = 5, height = 3, dpi = 300)
# ggsave(p1, filename = "figure/figure2/lineplot_hc_cytoplasm.pdf", width = 5, height = 3, dpi = 300)




# membrane 
t1 <- read_csv(here('data/RI_distribution/slice_RI_mean_hc_threshold_13450_13600.csv'))
colnames(t1) <- c("cell_num", "8", "7", "6", "5", "4", "3", "2", "1")
t1_pivot_longer <- pivot_longer(t1, cols = c("8", "7", "6", "5", "4", "3", "2", "1"), names_to = "shell_num", values_to = "density")
t1_pivot_longer$status <- 'Septic'
t1_pivot_longer <- t1_pivot_longer %>% filter(!is.na(density))
t1_pivot_longer$density <- t1_pivot_longer$density / 10000
t1_pivot_longer_mean <- t1_pivot_longer %>% group_by(shell_num) %>% summarise(mean = mean(density), sd = sd(density))

p3 <- ggplot(data = t1_pivot_longer_mean, aes(x = as.numeric(shell_num), y = mean) , group=as.numeric(shell_num)) + 
        geom_point(size = .5) +
        geom_ribbon(aes(y = mean, ymin = mean - sd, ymax = mean + sd), alpha = .8, fill='#29E3B7') +
        geom_line(color = 'black', linetype = "dashed") +
        xlab("Center to peripheral") +
        ylab("RI value") +  
        scale_x_continuous(breaks = seq(1, 8, 1)) +
        scale_y_continuous(limits = c(1.345, 1.36)) +
        theme_classic() 
        
# ggsave(p1, filename = "figure/figure2/lineplot_hc_membrane.png", width = 5, height = 3, dpi = 300)
# ggsave(p1, filename = "figure/figure2/lineplot_hc_membrane.pdf", width = 5, height = 3, dpi = 300)




# overall 
t1 <- read_csv(here('data/RI_distribution/slice_RI_mean_hc_threshold_overall.csv'))
colnames(t1) <- c("cell_num", "8", "7", "6", "5", "4", "3", "2", "1")
t1_pivot_longer <- pivot_longer(t1, cols = c("8", "7", "6", "5", "4", "3", "2", "1"), names_to = "shell_num", values_to = "density")
t1_pivot_longer$status <- 'Septic'
t1_pivot_longer <- t1_pivot_longer %>% filter(!is.na(density))
t1_pivot_longer$density <- t1_pivot_longer$density / 10000
t1_pivot_longer_mean <- t1_pivot_longer %>% group_by(shell_num) %>% summarise(mean = mean(density), sd = sd(density))

p4 <- ggplot(data = t1_pivot_longer_mean, aes(x = as.numeric(shell_num), y = mean) , group=as.numeric(shell_num)) + 
        geom_point(size = .5) +
        geom_ribbon(aes(y = mean, ymin = mean - sd, ymax = mean + sd), alpha = .8, fill='#4B09E6') +
        geom_line(color = 'black', linetype = "dashed") +
        xlab("Center to peripheral") +
        ylab("RI value") +  
        scale_x_continuous(breaks = seq(1, 8, 1)) +
        scale_y_continuous(limits = c(1.345, 1.395)) +
        theme_classic() 
        
# ggsave(p1, filename = "figure/figure2/lineplot_hc_overall.png", width = 5, height = 3, dpi = 300)
# ggsave(p1, filename = "figure/figure2/lineplot_hc_overall.pdf", width = 5, height = 3, dpi = 300)

plot_list <- list(p1,p2,p3,p4)
ggsave(here('figure/figure2/lineplot_hc_cowplot.png'), plot_grid(plotlist = plot_list, ncol = 1, nrow = 4), width = 4, height = 10, dpi = 300)
ggsave(here('figure/figure2/lineplot_hc_cowplot.pdf'), plot_grid(plotlist = plot_list, ncol = 1, nrow = 4), width = 4, height = 10, dpi = 300)
