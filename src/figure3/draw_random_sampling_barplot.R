library(tidyverse)
library(here)
library(showtext)

# read data 
# nucleus 
df <- read_csv(here('data/raw/sampling_100_cell_num.csv'))
df <- pivot_longer(df, cols = c("1", "2", "3", "4", "5", "6", "7", "8"), names_to = "shell_num", values_to = "RI_value")
df$density <- df$RI_value / 10000
# write.csv(df, here('data/processed/random_sampling_500_cell_num.csv'))

summarize <- df %>% group_by(shell_num, timepoint) %>% summarise(mean = mean(RI_value), sd = sd(RI_value))
shell_summarize <- df %>% group_by(shell_num) %>% summarise(shell_mean = mean(RI_value), shell_sd = sd(RI_value))

# left join 
df <- left_join(summarize, shell_summarize, by = "shell_num")

# minus values in other columns
df$mean <- df$mean - df$shell_mean

plot <- ggplot(df, aes(shell_num, mean, fill = timepoint)) + 
            geom_bar(position="dodge", stat="identity") + 
            geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd), position=position_dodge(width=0.9), width=0.2) +
            theme_minimal() +
            scale_fill_manual(values=c("#2EC1AC", "#D83A56", "#F8B400", "#1C315E")) +
            labs(title = "Nucleus Random sampling 100",x = "Shell Number", y = "RI", fill = "Timepoint") +
            theme(panel.spacing = unit(2, "lines")) + 
            scale_y_continuous(limits = c(-30, 30))
ggsave(here('barplot_random_sampling_100.pdf'), plot, width = 10, height = 4)

