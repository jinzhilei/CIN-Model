#====================================================================
# Script: main_Figure_4C.R
# Purpose: Half-violin plot comparing absolute neutrophil count at cycle initiation (Day0/Day21/Day42)
#          between two patient groups, with Mann–Whitney U (Wilcoxon rank-sum) test and significance labels
# Required packages: tidyverse, gghalves
# Input data: neutrophil_time_series.csv (time + 30 patients' neutrophil values, NA for missing data)
# Unit of y-axis: 10^8 cells/kg
#====================================================================
# R version : R version 4.5.2 (2025-10-31)
# Required packages:
#   tidyverse 2.0.0
#   gghalves  0.1.4 

library(tidyverse)
library(gghalves)
set.seed(111)

# ===================== 1. Load data =====================
df_read <- read.csv("neutrophil_time_series.csv", na.strings = c("NA",""))
time_read <- df_read$time
data_matrix_read <- as.matrix(df_read[,-1])

# Group label for 30 patients: 1 = Severe, 2 = Moderate
group_idx <- c(1,1,1,2,1,2,1,1,2,2,2,1,1,2,2,2,2,2,1,2,2,1,2,1,1,2,2,2,2,1)

# ===================== 2. Data wrangling =====================
df <- as.data.frame(data_matrix_read) %>%
  mutate(day = time_read)
colnames(df) <- c(paste0("P",1:30), "day")

# Keep only initial time points of each cycle: Day0, Day21, Day42
df_target <- df %>% filter(day %in% c(0, 21, 42))

# Reshape to long format
df_long <- df_target %>%
  pivot_longer(cols = -day, names_to = "patient", values_to = "value") %>%
  mutate(
    patient_id = as.integer(str_remove(patient, "P")),
    group = factor(group_idx[patient_id], levels = c(1,2), labels = c("G1","G2")),
    day_fac = factor(day, levels = c(0,21,42), labels = c("Day 0","Day 21","Day 42"))
  ) %>%
  filter(!is.na(group), !is.na(value))

# Map time factor to x-axis coordinate
pos_map <- tibble(
  day_fac = c("Day 0","Day 21","Day 42"),
  x_pos = c(1,2,3)
)
df_long <- df_long %>% left_join(pos_map, by = "day_fac")

# ===================== 3. Statistical test (Mann–Whitney U test) =====================
stat_res <- df_long %>%
  group_by(day_fac, x_pos) %>%
  summarise(
    pval = wilcox.test(value ~ group, exact = FALSE)$p.value,
    .groups = "drop"
  ) %>%
  mutate(
    lab = case_when(
      pval >= 0.05 ~ "ns",
      pval < 0.05 & pval >= 0.01 ~ "*",
      pval < 0.01 & pval >= 0.001 ~ "**",
      TRUE ~ "***"
    ),
    y_h = max(df_long$value, na.rm = TRUE) * 1.05
  )

# ===================== 4. Plot generation =====================
p <- ggplot() +
  ## Day 0
  geom_half_violin(
    data = filter(df_long, day_fac == "Day 0" & group == "G1"),
    aes(x = 1, y = value, fill = group),
    side = "l", width = 0.5, color = NA, alpha = 0.8
  ) +
  geom_half_violin(
    data = filter(df_long, day_fac == "Day 0" & group == "G2"),
    aes(x = 1, y = value, fill = group),
    side = "r", width = 0.5, color = NA, alpha = 0.8
  ) +
  geom_boxplot(
    data = filter(df_long, day_fac == "Day 0" & group == "G1"),
    aes(x = 1 - 0.1, y = value),
    width = 0.08, fill = "white", color = "black", outlier.shape = NA
  ) +
  geom_boxplot(
    data = filter(df_long, day_fac == "Day 0" & group == "G2"),
    aes(x = 1 + 0.1, y = value),
    width = 0.08, fill = "white", color = "black", outlier.shape = NA
  ) +
  geom_jitter(
    data = filter(df_long, day_fac == "Day 0" & group == "G1"),
    aes(x = 1 - 0.1, y = value, color = group),
    width = 0.05, size = 4
  ) +
  geom_jitter(
    data = filter(df_long, day_fac == "Day 0" & group == "G2"),
    aes(x = 1 + 0.1, y = value, color = group),
    width = 0.05, size = 4
  ) +
  
  ## Day 21
  geom_half_violin(
    data = filter(df_long, day_fac == "Day 21" & group == "G1"),
    aes(x = 2, y = value, fill = group),
    side = "l", width = 0.5, color = NA, alpha = 0.8
  ) +
  geom_half_violin(
    data = filter(df_long, day_fac == "Day 21" & group == "G2"),
    aes(x = 2, y = value, fill = group),
    side = "r", width = 0.5, color = NA, alpha = 0.8
  ) +
  geom_boxplot(
    data = filter(df_long, day_fac == "Day 21" & group == "G1"),
    aes(x = 2 - 0.1, y = value),
    width = 0.08, fill = "white", color = "black", outlier.shape = NA
  ) +
  geom_boxplot(
    data = filter(df_long, day_fac == "Day 21" & group == "G2"),
    aes(x = 2 + 0.1, y = value),
    width = 0.08, fill = "white", color = "black", outlier.shape = NA
  ) +
  geom_jitter(
    data = filter(df_long, day_fac == "Day 21" & group == "G1"),
    aes(x = 2 - 0.1, y = value, color = group),
    width = 0.05, size = 4
  ) +
  geom_jitter(
    data = filter(df_long, day_fac == "Day 21" & group == "G2"),
    aes(x = 2 + 0.1, y = value, color = group),
    width = 0.05, size = 4
  ) +
  
  ## Day 42
  geom_half_violin(
    data = filter(df_long, day_fac == "Day 42" & group == "G1"),
    aes(x = 3, y = value, fill = group),
    side = "l", width = 0.5, color = NA, alpha = 0.8
  ) +
  geom_half_violin(
    data = filter(df_long, day_fac == "Day 42" & group == "G2"),
    aes(x = 3, y = value, fill = group),
    side = "r", width = 0.5, color = NA, alpha = 0.8
  ) +
  geom_boxplot(
    data = filter(df_long, day_fac == "Day 42" & group == "G1"),
    aes(x = 3 - 0.1, y = value),
    width = 0.08, fill = "white", color = "black", outlier.shape = NA
  ) +
  geom_boxplot(
    data = filter(df_long, day_fac == "Day 42" & group == "G2"),
    aes(x = 3 + 0.1, y = value),
    width = 0.08, fill = "white", color = "black", outlier.shape = NA
  ) +
  geom_jitter(
    data = filter(df_long, day_fac == "Day 42" & group == "G1"),
    aes(x = 3 - 0.1, y = value, color = group),
    width = 0.05, size = 4
  ) +
  geom_jitter(
    data = filter(df_long, day_fac == "Day 42" & group == "G2"),
    aes(x = 3 + 0.1, y = value, color = group),
    width = 0.05, size = 4
  ) +
  
  ## Significance bar and label
  geom_segment(
    data = stat_res,
    aes(x = x_pos - 0.3, xend = x_pos + 0.3, y = y_h, yend = y_h),
    linewidth = 1
  ) +
  geom_text(
    data = stat_res,
    aes(x = x_pos, y = y_h + 0.05, label = lab),
    size = 6
  ) +
  
  ## Scales and color
  scale_x_continuous(breaks = c(1,2,3), labels = c("Day 0","Day 21","Day 42")) +
  scale_fill_manual(values = c("G1"="#D95319", "G2"="#0072BD")) +
  scale_color_manual(values = c("G1"="#b2182b", "G2"="#00009C")) +
  
  ## Axis label (unit noted in figure caption)
  labs(x = "", y = "Circulating neutrophils") +
  
  ## Journal style theme
  theme_bw() +
  theme(
    text = element_text(size = 22),
    axis.text = element_text(size = 22),
    axis.title = element_text(size = 22),
    axis.ticks.length = unit(-0.25, "cm"),
    panel.border = element_rect(linewidth = 1.2, color = "black", fill = NA),
    legend.position = "none",
    panel.grid = element_blank(),
    plot.margin = unit(c(0.5,0.5,0.5,1.5), "cm"),
    aspect.ratio = 0.9
  )

# Print statistical results (p-value and significance label for each time point)
print(stat_res)

# ===================== 5. Save Figure ====================
output_dir <- "Figure"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

out_file <- file.path(output_dir, "Figure_4C.png")

# Save with 300 dpi, maintaining aspect ratio ~ 0.9
ggsave(
  filename = out_file,
  plot = p,
  width = 8,
  height = 7.2,
  dpi = 300,
  bg = "white"
)

cat("Saved:", out_file, "\n")