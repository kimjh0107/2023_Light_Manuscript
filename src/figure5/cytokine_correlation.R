library(tidyverse)
library(here)
library(rstatix)
meta <- read_csv(here("data/raw/figure4/df_correlation.csv"))
cytokine <- read_csv(here("data/raw/figure4/cytokine_level.csv"))
data <- left_join(meta, cytokine, by = c("Sample" = "Sample")) %>%
    select(image_id, Sample, timepoint, shell_num, density, Cytokine, Value)


data <- data %>%
    group_by(Cytokine) %>%
    mutate(Norm = (Value - min(Value)) / (max(Value) - min(Value))) %>%
    distinct()

data %>%
    ggplot(aes(density, Norm)) +
    geom_point() +
    facet_wrap(shell_num ~ Cytokine, scales = "free_y")

data %>%
    filter(density != 0) %>%
    group_by(Cytokine) %>%
    cor_test(density, Norm, method = "pearson", conf.level = 0.95, alternative = "two.sided") %>%
    arrange(desc(cor), p)

library(boot)

bootCorTest <- function(data, i) {
    d <- data[i, ]
    cor.test(d$x, d$y)$p.value
}


# First dataset in help("cor.test")
library(boot)


x <- c(44.4, 45.9, 41.9, 53.3, 44.7, 44.1, 50.7, 45.2, 60.1)
y <- c(2.6, 3.1, 2.5, 5.0, 3.6, 4.0, 5.2, 2.8, 3.8)
dat <- data.frame(x, y)

set.seed(7612) # Make the results reproducible

bootCorTest2 <- function(data, i) {
    d <- data[i, ]
    res <- cor.test(d$x, d$y)
    c(stat = res$statistic, p.value = res$p.value)
}

b2 <- boot(dat, bootCorTest, R = 1000)

b2$t0
#  stat.t  p.value
# 1.841083 0.108173

b2
colMeans(b2$t)
