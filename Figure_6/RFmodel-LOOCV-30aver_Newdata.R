#====================================================================
# Figure_6: Boruta feature selection + Random Forest with LOOCV
# Purpose: Predict myelosuppression severity in colorectal cancer patients
# Packages: readxl, dplyr, caret, randomForest, pROC, ggplot2, rms, Boruta
#--------------------------------------------------------------------
# R version       : R version 4.5.2 (2025-10-31)
# Required packages:
#   readxl        : 1.5.0
#   dplyr         : 1.2.1
#   caret         : 7.0.1
#   randomForest  : 4.7.1.2
#   pROC          : 1.19.0.1
#   ggplot2       : 4.0.2
#   rms           : 8.1.1
#   Boruta        : 9.0.0
#====================================================================
rm(list = ls())
library(readxl)
library(dplyr)
library(caret)
library(randomForest)
library(pROC)
library(ggplot2)
library(rms)
library(Boruta)

# ======================
# Output directory setup
# ======================
output_dir <- "Figure"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# ======================
# Set random seed for reproducibility
# ======================
set.seed(111)

# ======================
# Data import and preprocessing
# ======================
df <- read_excel("data_Newcluster.xlsx")
colnames(df) <- c(
  "ID","Age","Gender","BMI","Neutrophil","Platelet","Lymphocyte","WBC",
  "T","N","M","Ki67","RBC","HGB","DD","ALT","AST","TBIL","ALB","CREA",
  "CEA","CA125","CA199","Label"
)
df <- df %>% select(-ID)
df$Label <- factor(ifelse(df$Label == 1, "class1", "class2"))
factor_cols <- c("T","N","M","Gender","Label")
df[factor_cols] <- lapply(df[factor_cols], factor)
numeric_cols <- setdiff(names(df), factor_cols)

# Impute missing Ki67 with median
df$Ki67[is.na(df$Ki67)] <- median(df$Ki67, na.rm=T)

# Winsorization (5%–95%)
winsorize <- function(x, probs = c(0.05, 0.95)) {
  q <- quantile(x, probs = probs, na.rm = TRUE)
  x[x < q[1]] <- q[1]
  x[x > q[2]] <- q[2]
  return(x)
}
for (col in numeric_cols) {
  df[[col]] <- winsorize(df[[col]], probs = c(0.05, 0.95))
}

# Standardization (z-score)
preProc <- preProcess(df[, numeric_cols], method = c("center", "scale"))
df[, numeric_cols] <- predict(preProc, df[, numeric_cols])

# ======================================================================
# Boruta feature selection
# ======================================================================
cat("\n==================================================\n")
cat("Running Boruta Feature Selection...\n")
set.seed(444)
boruta_output <- Boruta(
  Label ~ .,
  data = df,
  ntree = 1000,
  maxRuns = 400
)
cat("\nBoruta finished!\n")
print(boruta_output)

# Extract Boruta importance statistics
imp_df <- attStats(boruta_output)
imp_df$Feature <- rownames(imp_df)
imp_df <- imp_df %>%
  select(Feature, meanImp, medianImp, decision) %>%
  arrange(desc(meanImp))
cat("\nBoruta feature importance:\n")
print(imp_df)

# Plot Boruta feature importance (Save to PNG)
out_boruta <- file.path(output_dir, "Figure6_Boruta_Importance.png")
png(out_boruta, width = 2000, height = 1600, res = 300)
plot(boruta_output, las=2, main="Boruta Feature Importance")
dev.off()
cat("Saved:", out_boruta, "\n")

# Select top 8 features
final_selected_features <- imp_df %>%
  filter(!Feature %in% c("shadowMin", "shadowMean", "shadowMax")) %>%
  slice_head(n = 8) %>%
  pull(Feature)
cat("\nFinal selected features: top 8 ranked features\n")
print(final_selected_features)
cat("==================================================\n")

# Subset dataset with selected predictors and outcome
df_final <- df %>% select(all_of(final_selected_features), Label)

# ======================================================================
# Leave-one-out cross validation (LOOCV) for random forest classifier
# ======================================================================
n <- nrow(df_final)
pred_prob_all <- numeric(n)
pred_class_all <- factor(character(n), levels = levels(df_final$Label))

for(i in 1:n) {
  train_loo <- df_final[-i, ]
  test_loo  <- df_final[i, ]
  
  rf_loo <- randomForest(
    Label ~ ., data = train_loo,
    ntree = 800, mtry = sqrt(ncol(train_loo)-1), nodesize = 1,
    importance = TRUE
  )
  
  pred_prob_all[i] <- predict(rf_loo, test_loo, type = "prob")[, "class1"]
  pred_class_all[i] <- predict(rf_loo, test_loo)
}

# ======================
# Model performance evaluation
# ======================
true_label <- df_final$Label
roc_loo <- roc(true_label, pred_prob_all)
auc_loo <- auc(roc_loo)
cm_loo <- confusionMatrix(pred_class_all, true_label)
cat("\nLOOCV Results: AUC =", round(auc_loo, 3), "\n\n")
print(cm_loo)

# ======================================================================
# Plot ROC curves for each selected single feature (Save to PNG)
# ======================================================================
all_selected <- final_selected_features
n_plot <- length(all_selected)
if(n_plot > 0){
  out_single_roc <- file.path(output_dir, "Figure6_Single_Feature_ROC.png")
  png(out_single_roc, width = 3000, height = 1500, res = 300)
  par(mfrow = c(2, 4), mar = c(4, 4, 3, 1))
  for (feat in all_selected) {
    x <- df[[feat]]
    if(is.factor(x)){ x <- as.integer(x) }
    roc_single <- roc(true_label, x, quiet=TRUE)
    auc_single <- auc(roc_single)
    
    plot(roc_single, col = "#ff000f", lwd = 3, legacy.axes = TRUE,
         main = feat, xlab = "1-Specificity", ylab = "Sensitivity",
         cex.axis = 1.2, cex.lab = 1.2, cex.main = 1.4, font.lab = 2, font.main = 2)
    text(0.68, 0.95, paste0("AUC = ", round(auc_single, 3)), cex = 1.2, font = 2, col = "#ff000f")
  }
  dev.off()
  cat("Saved:", out_single_roc, "\n")
}

# ======================
# LOOCV ROC curve of final random forest model (Save to PNG)
# ======================
out_model_roc <- file.path(output_dir, "Figure6_LOOCV_ROC.png")
png(out_model_roc, width = 1800, height = 1800, res = 300)
par(mar = c(5, 5, 2, 2))
plot(roc_loo, main = "", col = "#ff000f", lwd = 4, legacy.axes = TRUE,
     xlab = "1-Specificity", ylab = "Sensitivity",
     cex.axis = 1.4, cex.lab = 1.6, lty = 1, font.lab = 2, bty = "o")
text(0.72, 0.92, paste0("AUC = ", round(auc_loo, 3)), cex = 1.8, font = 2, col = "#ff000f")
dev.off()
cat("Saved:", out_model_roc, "\n")

# ======================
# Confusion matrix heatmap (Save to PNG)
# ======================
cm_df <- as.data.frame(cm_loo$table)
colnames(cm_df) <- c("Actual", "Predict", "Number")
p_cm <- ggplot(cm_df, aes(x = Actual, y = Predict, fill = Number)) +
  geom_tile(color = "gray60", linewidth = 0.6) +
  geom_text(aes(label = Number), size = 8, fontface = "bold", color = "black") +
  scale_fill_gradient(low = "#FFFFFF", high = "#ff000f") +
  ggtitle("Confusion Matrix") +
  labs(x = "Actual", y = "Predicted") +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        axis.title = element_text(size = 16, face = "bold"),
        axis.text = element_text(size = 14, face = "bold"),
        legend.position = "right",
        panel.grid = element_blank()) +
  scale_y_discrete(limits = rev(levels(cm_df$Predict)))

out_cm <- file.path(output_dir, "Figure6_Confusion_Matrix.png")
ggsave(out_cm, plot = p_cm, width = 6, height = 5, dpi = 300, bg = "white")
cat("Saved:", out_cm, "\n")