#====================================================================
# Script name : Likert_plot.R
# Purpose     : Generate a diverging stacked bar chart (Likert plot)
#               to visualize clinical expert agreement on 8 features
#               (Age, N staging, Platelet, Lymphocyte, Neutrophil,
#                CA125, CEA, ALB), and export the figure as PNG.
# Input data  : Clinicalexpert.xlsx (columns: expert, question, score)
# Output      : Figure/Likert_plot.png (300 dpi)
#--------------------------------------------------------------------
# R version       : R version 4.5.2 (2025-10-31)
# Required packages:
#   tidyverse 2.0.0
#   readxl    1.5.0
#   ggtext    0.1.2
#   magrittr  2.0.4
#   ggprism   1.0.7
#   MetBrewer 0.2.0
#   plotly    4.12.0
#====================================================================

# ==========================================
# 1. Load data and update labels
# ==========================================
df <- read_excel("Clinicalexpert.xlsx")
colnames(df)[1] <- "expert"
df$score <- as.numeric(df$score)

q_labels <- c("Age", "N staging", "Platelet", "Lymphocyte",
              "Neutrophil", "CA125", "CEA", "ALB")

likert_labels <- c("Strongly disagree", "Disagree", "Neutral",
                   "Agree", "Strongly agree")

# ==========================================
# 2. Prepare data
# ==========================================
df_summary <- df %>%
  mutate(
    expert = as.character(expert),
    type = factor(likert_labels[score], levels = likert_labels),
    question = factor(q_labels[as.numeric(gsub("Q", "", question))],
                      levels = rev(q_labels))
  ) %>%
  group_by(question, type) %>%
  summarise(value = n(), .groups = 'drop') %>%
  complete(question, type, fill = list(value = 0)) %>%
  group_by(question) %>%
  mutate(total = sum(value)) %>%
  ungroup()

# ==========================================
# 3. Compute diverging stacked bar offsets (neutral left bound = 0)
# ==========================================
df_plot <- df_summary %>%
  group_by(question) %>%
  mutate(
    left_val  = -sum(value[type %in% c("Agree", "Strongly agree")]),
    right_val =  sum(value[type %in% c("Disagree", "Strongly disagree")]),
    neutral_w =  value[type == "Neutral"],
    y_num     = as.numeric(question),
    
    xmin = case_when(
      type == "Strongly agree"    ~ left_val,
      type == "Agree"             ~ left_val + value[type == "Strongly agree"],
      type == "Neutral"           ~ 0,
      type == "Disagree"          ~ neutral_w,
      type == "Strongly disagree" ~ neutral_w + value[type == "Disagree"],
      .default = 0
    ),
    xmax = case_when(
      type == "Strongly agree"    ~ left_val + value,
      type == "Agree"             ~ left_val + value[type == "Strongly agree"] + value,
      type == "Neutral"           ~ neutral_w,
      type == "Disagree"          ~ neutral_w + value,
      type == "Strongly disagree" ~ right_val,
      .default = 0
    ),
    
    x_mid = (xmin + xmax) / 2,
    pct   = value / total,
    pct_label = paste0(sprintf("%.1f", pct * 100), "%"),
    pct_label = ifelse(pct < 0.03, "", pct_label),
    text_color = case_when(
      type %in% c("Strongly disagree", "Strongly agree") ~ "white",
      TRUE ~ "black"
    )
  ) %>%
  ungroup()

# ==========================================
# 4. Colors
# ==========================================
custom_colors <- c(
  "Strongly disagree" = "#1F4E79",
  "Disagree"          = "#5B9BD5",
  "Neutral"           = "#D9D9D9",
  "Agree"             = "#FF7C80",
  "Strongly agree"    = "#C00000"
)

# ==========================================
# 5. Label data
# ==========================================
df_label_neutral <- df_plot %>%
  filter(type == "Neutral") %>%
  mutate(x_label = x_mid)

df_label_other <- df_plot %>%
  filter(type != "Neutral") %>%
  mutate(x_label = x_mid)

# ==========================================
# 6. X-axis range and ticks (ensure 8 is visible)
# ==========================================
x_lim <- max(abs(c(df_plot$xmin, df_plot$xmax)), na.rm = TRUE) + 0.5
if (!is.finite(x_lim) || x_lim <= 0) x_lim <- 8

# Force x-axis to extend to at least 8.5 so that 8 is within range
x_lim <- max(x_lim, 8.5)

# Ticks fixed from -8 to 8, step 2, explicitly including 8
x_breaks <- seq(-8, 8, by = 2)
x_labels <- abs(x_breaks)

stopifnot(length(x_breaks) == length(x_labels))

# ==========================================
# 7. Plot
# ==========================================
p <- df_plot %>%
  ggplot() +
  geom_rect(aes(xmin = xmin, xmax = xmax,
                ymin = y_num - 0.4,
                ymax = y_num + 0.4,
                fill = type),
            color = NA) +
  
  geom_text(
    data = df_label_other,
    aes(x = x_label, y = y_num, label = pct_label, color = text_color),
    size = 3, fontface = "bold", inherit.aes = FALSE
  ) +
  
  geom_text(
    data = df_label_neutral,
    aes(x = x_label, y = y_num, label = pct_label, color = text_color),
    size = 3, fontface = "bold", inherit.aes = FALSE
  ) +
  
  scale_color_identity() +
  scale_fill_manual(values = custom_colors,
                    breaks = likert_labels,
                    name = NULL) +
  
  scale_x_continuous(
    expand = c(0, 0),
    limits = c(-x_lim, x_lim),
    breaks = x_breaks,
    labels = x_labels
  ) +
  
  scale_y_continuous(breaks = 1:8,
                     labels = levels(df_plot$question)) +
  
  labs(x = "Number of Experts",
       y = "",
       title = "",
       subtitle = "Left: Positive (Red) | Neutral from 0 (Grey) | Right: Negative (Blue)") +
  
  theme_prism(border = TRUE, base_size = 12) +
  theme(
    legend.position = c(0.85, 0.6),
    legend.direction = "vertical",
    legend.key.width = unit(2, "cm"),
    legend.key.height = unit(0.6, "cm"),
    legend.background = element_blank(),
    legend.box.background = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8),
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "gray50"),
    axis.text.y = element_text(size = 12)
  )

# Optional interactive preview
# plotly::ggplotly(p)

# ==========================================
# 8. Export (Standardized)
# ==========================================
output_dir <- "Figure"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

out_file <- file.path(output_dir, "Likert_plot.png")

ggsave(
  filename = out_file,
  plot = p,
  width = 10,
  height = 6,
  units = "in",
  dpi = 300,
  bg = "white"
)

cat("Saved:", out_file, "\n")