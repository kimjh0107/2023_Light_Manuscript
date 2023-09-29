library(tidyverse)
library(here)
library(ggpubr)
library(ggrepel)
library(showtext)

wideScreen <- function(howWide=Sys.getenv("COLUMNS")) {
  options(width=as.integer(howWide))
}
wideScreen()


t1 <- read_csv(here('data/processed/t1_numpy_distribution.csv'))
t2 <- read_csv(here('data/processed/t2_numpy_distribution.csv'))
t3 <- read_csv(here('data/processed/t3_numpy_distribution.csv'))
hc <- read_csv(here('data/processed/hc_numpy_distirbution.csv'))


# merge dataframe into one dataframe 
df <- bind_rows(t1, t2, t3, hc)
df$'RI values' <- as.numeric(df$'RI value')
df$RI_values <- df$'RI value'


a1 <- ggdensity(df, x = "RI_values",
   add = "median", rug = TRUE, add.params = list(linetype = "dashed", size=1),
   color = "Status", fill = "Status",
   palette = c("green", "#00AFBB", 'red', '#E7B800'))

ggsave(here('figure/figure1/distribution_plot_for_fig1A.pdf'),a1, width = 7, height = 5, dpi = 300)

