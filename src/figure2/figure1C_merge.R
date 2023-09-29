library(cowplot)
library(magick)
library(here)

fig <- magick::image_read(here("data/raw/figure1/representative_img/t1_3D.png"))
fig1c_1_1 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)
fig <- magick::image_read(here("data/raw/figure1/representative_img/t2_3D.png"))
fig1c_1_2 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)
fig <- magick::image_read(here("data/raw/figure1/representative_img/t3_3D.png"))
fig1c_1_3 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)
fig <- magick::image_read(here("data/raw/figure1/representative_img/hc_3D.png"))
fig1c_1_4 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)

fig <- magick::image_read_pdf(here("data/raw/figure1/representative_img/original_raw_t1_img.pdf"))
fig <- magick::image_crop(fig, "450x450+200+200")
fig1c_2_1 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)
fig <- magick::image_read_pdf(here("data/raw/figure1/representative_img/original_raw_t2_img.pdf"))
fig <- magick::image_crop(fig, "450x450+170+130")
fig1c_2_2 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)
fig <- magick::image_read_pdf(here("data/raw/figure1/representative_img/original_raw_t3_img.pdf"))
fig <- magick::image_crop(fig, "450x450+175+150")
fig1c_2_3 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)
fig <- magick::image_read_pdf(here("data/raw/figure1/representative_img/original_raw_hc_img.pdf"))
fig <- magick::image_crop(fig, "450x450+190+150")
fig1c_2_4 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)

fig <- magick::image_read_pdf(here("data/raw/figure1/representative_img/t1_img3_overall.pdf"))
fig <- magick::image_crop(fig, "600x600+700+450")
fig1c_3_1 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)
fig <- magick::image_read_pdf(here("data/raw/figure1/representative_img/t2_img1_overall.pdf"))
fig <- magick::image_crop(fig, "600x600+700+350")
fig1c_3_2 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)
fig <- magick::image_read_pdf(here("data/raw/figure1/representative_img/t3_img5_overall.pdf"))
fig <- magick::image_crop(fig, "600x600+700+400")
fig1c_3_3 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)
fig <- magick::image_read_pdf(here("data/raw/figure1/representative_img/hc_img1_overall.pdf"))
fig <- magick::image_crop(fig, "600x600+700+350")
fig1c_3_4 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)

fig <- magick::image_read_pdf(here("data/raw/figure1/representative_img/t1_img3_nucleus.pdf"))
fig <- magick::image_crop(fig, "600x600+700+450")
fig1c_4_1 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)
fig <- magick::image_read_pdf(here("data/raw/figure1/representative_img/t2_img1_nucleus.pdf"))
fig <- magick::image_crop(fig, "600x600+700+350")
fig1c_4_2 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)
fig <- magick::image_read_pdf(here("data/raw/figure1/representative_img/t3_img5_nucleus.pdf"))
fig <- magick::image_crop(fig, "600x600+700+400")
fig1c_4_3 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)
fig <- magick::image_read_pdf(here("data/raw/figure1/representative_img/hc_img1_nucleus.pdf"))
fig <- magick::image_crop(fig, "600x600+700+350")
fig1c_4_4 <- ggdraw() + draw_image(fig, 0, 0, 1, 1)

source(here("src/figure1/figure1C_volume_boxplot.R"))
fig1c_1_5 <- fig
source(here("src/figure1/figure1C_drymass_boxplot.R"))
fig1c_2_5 <- fig
source(here("src/figure1/figure1C_overall_boxplot.R"))
fig1c_3_5 <- fig
source(here("src/figure1/figure1C_nucleus_boxplot.R"))
fig1c_4_5 <- fig

row <- 4
col <- 5
row_label_space <- 0.025
col_label_space <- 0.025
row_image_space <- (1 - 0.1) / row
col_image_space <- (1 - 0.1) / col

fig <- ggdraw() +
    draw_plot(fig1c_1_1, x = col_label_space, y = 3 * row_image_space, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_1_2, x = col_label_space + col_image_space, y = 3 * row_image_space, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_1_3, x = col_label_space + 2 * col_image_space, y = 3 * row_image_space, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_1_4, x = col_label_space + 3 * col_image_space, y = 3 * row_image_space, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_2_1, x = col_label_space, y = 2 * row_image_space, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_2_2, x = col_label_space + col_image_space, y = 2 * row_image_space, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_2_3, x = col_label_space + 2 * col_image_space, y = 2 * row_image_space, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_2_4, x = col_label_space + 3 * col_image_space, y = 2 * row_image_space, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_3_1, x = col_label_space, y = row_image_space, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_3_2, x = col_label_space + col_image_space, y = row_image_space, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_3_3, x = col_label_space + 2 * col_image_space, y = row_image_space, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_3_4, x = col_label_space + 3 * col_image_space, y = row_image_space, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_4_1, x = col_label_space, y = 0, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_4_2, x = col_label_space + col_image_space, y = 0, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_4_3, x = col_label_space + 2 * col_image_space, y = 0, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_4_4, x = col_label_space + 3 * col_image_space, y = 0, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_1_5, x = col_label_space + 4 * col_image_space, y = 3 * row_image_space, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_2_5, x = col_label_space + 4 * col_image_space, y = 2 * row_image_space, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_3_5, x = col_label_space + 4 * col_image_space, y = 1 * row_image_space, width = col_image_space, height = row_image_space) +
    draw_plot(fig1c_4_5, x = col_label_space + 4 * col_image_space, y = 0, width = col_image_space, height = row_image_space) +
    draw_label("Septic shock (T1)", x = col_label_space + 0 * col_image_space, y = row_image_space * row, hjust = 0, vjust = 0, size = 6) +
    draw_label("Shock resolved (T2)", x = col_label_space + 1 * col_image_space, y = row_image_space * row, hjust = 0, vjust = 0, size = 6) +
    draw_label("Before discharge (T3)", x = col_label_space + 2 * col_image_space, y = row_image_space * row, hjust = 0, vjust = 0, size = 6) +
    draw_label("Healthy (H)", x = col_label_space + 3 * col_image_space, y = row_image_space * row, hjust = -.5, vjust = 0, size = 6) +
    draw_label("Raw", x = col_label_space, y = 3.5 * row_image_space, vjust = 0, angle = 90, size = 6) +
    draw_label("MIP", x = col_label_space, y = 2.5 * row_image_space, vjust = 0, angle = 90, size = 6) +
    draw_label("Overall", x = col_label_space, y = 1.5 * row_image_space, vjust = 0, angle = 90, size = 6) +
    draw_label("Nucleus", x = col_label_space, y = 0 * row_image_space, hjust = -.6, vjust = 0, angle = 90, size = 6)


ggsave(here("figure/figure1/figure1C.pdf"), fig, width = 120, height = 90, units = "mm")
