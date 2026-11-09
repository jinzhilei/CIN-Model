#=======================================================================
# Script: Mantel_Test.R
# Purpose: Mantel test & Pearson correlation matrix plot using linkET
# Data: 30 patients, 12 ODE model parameters
# Output: Figure/Mantel_Corr_Plot.png (300 dpi)
#-----------------------------------------------------------------------
# R version       : R version 4.5.2 (2025-10-31)
# Required packages:
#   linkET        : 0.1.0
#   ggplot2       : 4.0.2
#   ggtext        : 0.1.2
#   dplyr         : 1.2.1
#   RColorBrewer  : 1.1.3
#   cols4all      : 0.10
#   tidyverse     : 2.0.0
#=======================================================================
rm(list = ls())
set.seed(111)

# Load required packages
library(linkET)
library(ggplot2)
library(ggtext)
library(dplyr)
library(RColorBrewer)
library(cols4all)
library(tidyverse)

# Import parameter table and remove patient ID column
params_read <- read.csv("patient_12parameters.csv")
params <- params_read[, -1]

# Correlation matrix (Pearson)
cor2 <- correlate(params)

# Mantel test: grouping 12 parameters into four modules
mantel <- mantel_test(
  params, params,
  spec_select = list(
    Hematopoiesis = 1:4,
    Chemotherapy  = 5:6,
    "G-CSF"       = 7:9,
    Microenvironment = 10:12
  )
) %>%
  mutate(
    rd = cut(r, breaks = c(-Inf, 0.2, 0.4, Inf),
             labels = c("< 0.2", "0.2 - 0.4", "≥ 0.4")),
    pd = cut(p, breaks = c(-Inf, 0.01, 0.05, Inf),
             labels = c("< 0.01", "0.01 - 0.05", "≥ 0.05"))
  )

# Plot: correlation heatmap combined with Mantel links
p <- qcorrplot(
  cor2,
  type = "upper",
  diag = FALSE,
  grid_col = "black",
  grid_size = 0.2
) +
  geom_square() +
  geom_mark(
    size = 4.5,
    only_mark = TRUE,
    sig_level = c(0.05, 0.01, 0.001),
    sig_thres = 0.05,
    colour = "black"
  ) +
  geom_couple(
    data = mantel,
    aes(colour = pd, size = rd),
    curvature = nice_curvature()
  ) +
  scale_fill_gradientn(
    colours = c("#00BFFF", "white", "#E91E63"),
    limits = c(-1, 1)
  ) +
  scale_size_manual(values = c(0.3, 1.5, 2)) +
  scale_colour_manual(values = c4a("brewer.set2", 3)) +
  guides(
    size = guide_legend(title = "Mantel's r", order = 2),
    colour = guide_legend(title = "Mantel's p", order = 1),
    fill = guide_colorbar(title = "Pearson's r", order = 3)
  ) +
  theme(
    text = element_text(size = 16, family = "serif"),
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 15),
    axis.text.x = element_text(size = 15, angle = 0, hjust = 0.5),
    axis.text.y = element_text(size = 15, hjust = 1)
  )

# Render figure in RStudio viewer
print(p)

# ==========================================
# Export Figure (Standardized)
# ==========================================
output_dir <- "Figure"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

out_file <- file.path(output_dir, "Mantel_Corr_Plot.png")

ggsave(
  filename = out_file,
  plot = p,
  width = 10,
  height = 9,
  units = "in",
  dpi = 300,
  bg = "white"
)

cat("Saved:", out_file, "\n")