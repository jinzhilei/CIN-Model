#====================================================================
# Script name: main_Figure_4A.R
# Purpose: Generate paired half-violin plot with paired lines, boxplots,
#          mean ± SD error bars, and Wilcoxon signed-rank test for E-index
# Required packages: ggplot2, dplyr, tidyr, gghalves
# Input data: Eindex.csv (columns: y0, y1; n=30 paired samples)
#--------------------------------------------------------------------
#   R version : R version 4.5.2 (2025-10-31)
#   ggplot2   : 4.0.2
#   dplyr     : 1.2.1
#   tidyr     : 1.3.2
#   gghalves  : 0.1.4
#====================================================================
# Clear environment
rm(list = ls())

# Load libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(gghalves)

# Record package versions for reproducibility
pkg_versions <- sapply(
  c("ggplot2", "dplyr", "tidyr", "gghalves"),
  function(p) as.character(packageVersion(p))
)
cat("===== Package versions =====\n")
print(pkg_versions)
cat("R version:", R.version.string, "\n")

#==================== Data import ====================
df_read <- read.csv("New_Eindex.csv")
y0 <- df_read$y0
y1 <- df_read$y1

#==================== Statistical test ====================
# Paired t-test (for normally distributed data)
p_t <- t.test(y0, y1, paired = TRUE, alternative = "two.sided")$p.value
# Wilcoxon signed-rank test (nonparametric test, recommended for biomedical data)
p_wilcox <- wilcox.test(y0, y1, paired = TRUE, exact = FALSE)$p.value

# Print statistical results to console
cat("===== Paired statistical test results =====\n")
cat("Paired t-test p-value =", round(p_t, 4), "\n")
cat("Wilcoxon signed-rank test p-value =", round(p_wilcox, 4), "\n")

# Reshape dataset to long format for ggplot
df <- tibble(
  id = 1:30,
  `Pre-chemo` = y0,
  `Post-chemo` = y1
) %>%
  pivot_longer(cols = -id, names_to = "group", values_to = "value") %>%
  mutate(group = factor(group, levels = c("Pre-chemo", "Post-chemo")))

# Set random seed for reproducible jitter
set.seed(123)
df <- df %>%
  group_by(id) %>%
  mutate(x_pos = case_when(
    group == "Pre-chemo" ~ 1.15 + runif(n(), 0, 0.08),
    group == "Post-chemo"  ~ 1.85 + runif(n(), -0.08, 0)
  )) %>%
  ungroup()

#==================== Plot generation ====================
p <- ggplot(df, aes(x = x_pos, y = value)) +
  ## Half-violin layer
  geom_half_violin(
    data = filter(df, group == "Pre-chemo"),
    aes(x = 1, y = value, fill = group),
    position = position_nudge(x = 0, y = 0),
    side = "l", width = 0.5, color = "black", fill = "#10B981"
  ) +
  geom_half_violin(
    data = filter(df, group == "Post-chemo"),
    aes(x = 2, y = value, fill = group),
    position = position_nudge(x = 0, y = 0),
    side = "r", width = 0.5, color = "black", fill = "#F59E0B"
  ) +
  
  ## Boxplot layer (hide outliers)
  geom_boxplot(
    data = filter(df, group == "Pre-chemo"),
    aes(x = 1.075), width = 0.08, fill = "#10B981",
    color = "black", outlier.shape = NA
  ) +
  geom_boxplot(
    data = filter(df, group == "Post-chemo"),
    aes(x = 1.925), width = 0.08, fill = "#F59E0B",
    color = "black", outlier.shape = NA
  ) +
  
  ## Paired connecting lines for individual samples
  geom_line(aes(group = id), color = "gray80", linewidth = 1) +
  
  ## Individual scatter points
  geom_point(aes(color = group), size = 8) +
  
  ## Mean ± SD error bars and mean markers
  # Pre-chemo group (Pre)
  stat_summary(
    data = filter(df, group == "Pre-chemo"),
    aes(x = 1.3),
    fun = mean,
    fun.min = function(x) mean(x) - sd(x),
    fun.max = function(x) mean(x) + sd(x),
    geom = "errorbar", width = 0.04, linewidth = 3, color = "#10B981"
  ) +
  stat_summary(
    data = filter(df, group == "Pre-chemo"),
    aes(x = 1.3),
    fun = mean, geom = "point",
    size = 8, color = "#10B981", fill = "black", shape = 21
  ) +
  # Post-chemo group (Post)
  stat_summary(
    data = filter(df, group == "Post-chemo"),
    aes(x = 1.7),
    fun = mean,
    fun.min = function(x) mean(x) - sd(x),
    fun.max = function(x) mean(x) + sd(x),
    geom = "errorbar", width = 0.04, linewidth = 3, color = "#F59E0B"
  ) +
  stat_summary(
    data = filter(df, group == "Post-chemo"),
    aes(x = 1.7),
    fun = mean, geom = "point",
    size = 8, color = "#F59E0B", fill = "black", shape = 21
  ) +
  
  ## Line connecting group means
  annotate("segment", x = 1.3, xend = 1.7,
           y = mean(y0), yend = mean(y1), linewidth = 1.2, color = "black") +
  
  ## Significance bar and p-value label
  annotate("segment", x = 1.2, xend = 1.8, y = 1.01, yend = 1.01, linewidth = 1) +
  annotate("segment", x = 1.2, xend = 1.2, y = 1.01, yend = 0.998, linewidth = 1) +
  annotate("segment", x = 1.8, xend = 1.8, y = 1.01, yend = 0.998, linewidth = 1) +
  annotate("text", x = 1.5, y = 1.025,
           label = paste0("p = ", signif(p_wilcox, 3)), size = 10) +
  
  ## Color & axis scaling
  scale_color_manual(values = c("#10B981", "#F59E0B")) +
  scale_x_continuous(breaks = c(1.2, 1.8), labels = c("Pre", "Post")) +
  scale_y_continuous(limits = c(0.55, 1.07), expand = c(0, 0)) +
  labs(x = "", y = "Microenvironment") +
  
  ## Figure theme (journal standard)
  theme_bw() +
  theme(
    text = element_text(size = 22),
    axis.text = element_text(size = 22),
    axis.title = element_text(size = 22),
    axis.ticks.length = unit(-0.25, "cm"),
    axis.line = element_line(linewidth = 0),
    panel.border = element_rect(linewidth = 1.5, color = "black", fill = NA),
    legend.position = "none",
    panel.grid = element_blank(),
    plot.margin = unit(c(0.5, 0.5, 0.5, 1.5), "cm"),
    aspect.ratio = 0.9
  )

#==================== Save Figure ====================
output_dir <- "Figure"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

out_file <- file.path(output_dir, "Figure_4A.png")

# Save with 300 dpi. Width/height are in inches.
# Since your plot has an aspect ratio of 0.9, we set height = width * 0.9.
ggsave(
  filename = out_file,
  plot = p,
  width = 8,       # Width in inches
  height = 7.2,    # Height in inches (8 * 0.9)
  dpi = 300,
  bg = "white"
)

cat("Saved:", out_file, "\n")