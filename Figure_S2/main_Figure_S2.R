# ==============================================================
# main_Figure_S2
# Predicted vs. observed ANC (log-log scale with fixed ticks)
# ==============================================================
# R version : R version 4.5.2 (2025-10-31)
# Required packages:
#   tidyverse 2.0.0
#   ggpubr    (version determined by user environment)
#--------------------------------------------------------------------
# Input : y_obs.csv, y_pred.csv
# Output: Figure/Figure_S2.png (300 dpi)
# ==============================================================
library(tidyverse)
library(ggpubr)

# ----------------------------------------------
# 1. Load raw data (keep NaN for now)
# ----------------------------------------------
# Read CSV, coerce to numeric to avoid parsing errors
true_df <- read.csv("y_obs.csv",  header = FALSE,
                    na.strings = c("NA", "NaN", ""))
pred_df <- read.csv("y_pred.csv", header = FALSE,
                    na.strings = c("NA", "NaN", ""))

true_df <- as.data.frame(lapply(true_df, function(x) as.numeric(as.character(x))))
pred_df <- as.data.frame(lapply(pred_df, function(x) as.numeric(as.character(x))))

# Time points (must match the 6 columns)
times <- c(0, 4, 21, 25, 42, 46)
n_patient <- nrow(true_df)  # number of patients

# ----------------------------------------------
# 2. Flatten to vector form (before dropping NaN)
# ----------------------------------------------
# Rule: expand by "time point -> patient"; both datasets use the same order
true_vec <- as.vector(t(true_df))
pred_vec <- as.vector(t(pred_df))

# Matching patient ID and time point for each entry
patient_vec <- rep(1:n_patient, length(times))
day_vec     <- rep(times, each = n_patient)

# ----------------------------------------------
# 3. Remove indices where the observed value is NaN
# ----------------------------------------------
nan_idx <- which(is.na(true_vec))

true_vec_clean    <- true_vec[-nan_idx]
pred_vec_clean    <- pred_vec[-nan_idx]
patient_vec_clean <- patient_vec[-nan_idx]
day_vec_clean     <- day_vec[-nan_idx]

cat("Total raw points: ",        length(true_vec),        "\n")
cat("NaN points in observed: ",  length(nan_idx),         "\n")
cat("Valid paired points: ",     length(true_vec_clean),  "\n")

# ----------------------------------------------
# 4. Assemble plotting data; drop non-positive values
#    (log scale requires values > 0)
# ----------------------------------------------
df_clean <- data.frame(
  patient    = patient_vec_clean,
  day        = day_vec_clean,
  true_value = true_vec_clean,
  pred_value = pred_vec_clean
) %>%
  filter(true_value > 0, pred_value > 0)

# ----------------------------------------------
# 5. Plot: log-log scale with fixed ticks 0.1 / 1 / 10 / 100
# ----------------------------------------------
p <- ggplot(df_clean, aes(x = pred_value, y = true_value)) +
  geom_point(size = 4, alpha = 0.9, color = "#2E86AB") +
  geom_abline(slope = 1, intercept = 0,
              color = "red", linetype = "dashed", linewidth = 1.5) +
  geom_smooth(method = "lm", color = "black", se = TRUE) +
  stat_cor(label.x.npc = 0.05, label.y.npc = 0.95, size = 8) +
  
  # Log scale with fixed ticks (0 is not valid on log scale; kept for original intent)
  scale_x_log10(breaks = c(0, 1, 10, 100)) +
  scale_y_log10(breaks = c(0, 1, 10, 100)) +
  
  labs(x = "Calculated ANC", y = "Observed ANC") +
  theme_bw() +
  theme(
    text             = element_text(size = 20),
    axis.text        = element_text(size = 20),
    axis.title       = element_text(size = 20),
    axis.ticks.length = unit(-0.25, "cm"),
    panel.border     = element_rect(linewidth = 1.5, color = "black", fill = NA),
    legend.position  = "none",
    panel.grid       = element_blank(),
    plot.margin      = unit(c(0.5, 0.5, 0.5, 1.5), "cm"),
    aspect.ratio     = 1  # fixed aspect ratio for a square plotting box
  )

# ==========================================
# 6. Export (Standardized)
# ==========================================
output_dir <- "Figure"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

out_file <- file.path(output_dir, "Figure_S2.png")

ggsave(
  filename = out_file,
  plot = p,
  width = 6,      # inches; aspect ratio = 1 so height equals width
  height = 6,
  units = "in",
  dpi = 300,
  bg = "white"
)

cat("Saved:", out_file, "\n")
