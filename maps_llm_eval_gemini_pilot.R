# Evaluate parsed Gemini pilot predictions against provisional DIF labels.
#
# Usage:
#   Rscript maps_llm_eval_gemini_pilot.R
#
# Outputs:
#   llm_dif_output/maps_llm_gemini_pilot_eval_joined.csv
#   llm_dif_output/maps_llm_gemini_pilot_eval_metrics.csv

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Package 'dplyr' is required.")
}

library(dplyr)

out_dir <- "llm_dif_output"
pred_csv <- file.path(out_dir, "maps_llm_gemini_pilot_predictions_flat.csv")
gold_csv <- file.path(out_dir, "maps_dif_screening_gold_full.csv")
kw_csv <- file.path(out_dir, "maps_keyword_baseline_predictions.csv")

pred <- read.csv(pred_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
gold <- read.csv(gold_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
kw <- read.csv(kw_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")

joined <- pred %>%
  filter(parse_status == "ok") %>%
  left_join(
    gold %>%
      select(scale_id, item_id, covariate, beta, p_fdr, dif_label, direction),
    by = c("scale_id", "item_id", "covariate")
  ) %>%
  left_join(
    kw %>%
      select(scale_id, item_id, covariate, keyword_score_0_100),
    by = c("scale_id", "item_id", "covariate")
  ) %>%
  mutate(
    dif_label = as.logical(dif_label),
    llm_flag_50 = threshold_dif_probability_0_100 >= 50,
    llm_flag_70 = threshold_dif_probability_0_100 >= 70
  )

average_precision <- function(label, score) {
  ok <- !is.na(label) & !is.na(score)
  label <- as.logical(label[ok])
  score <- score[ok]
  if (sum(label) == 0) return(NA_real_)
  ord <- order(score, decreasing = TRUE)
  label <- label[ord]
  precision <- cumsum(label) / seq_along(label)
  sum(precision[label]) / sum(label)
}

precision_at_k <- function(label, score, k) {
  ok <- !is.na(label) & !is.na(score)
  label <- as.logical(label[ok])
  score <- score[ok]
  if (length(label) == 0) return(NA_real_)
  k <- min(k, length(label))
  ord <- order(score, decreasing = TRUE)[seq_len(k)]
  mean(label[ord])
}

metric_one <- function(d, group_label) {
  data.frame(
    group = group_label,
    n_pairs = nrow(d),
    positives = sum(d$dif_label, na.rm = TRUE),
    mean_llm_score = mean(d$threshold_dif_probability_0_100, na.rm = TRUE),
    llm_average_precision =
      average_precision(d$dif_label, d$threshold_dif_probability_0_100),
    llm_precision_at_5 =
      precision_at_k(d$dif_label, d$threshold_dif_probability_0_100, 5),
    llm_precision_at_10 =
      precision_at_k(d$dif_label, d$threshold_dif_probability_0_100, 10),
    keyword_average_precision =
      average_precision(d$dif_label, d$keyword_score_0_100),
    keyword_precision_at_5 =
      precision_at_k(d$dif_label, d$keyword_score_0_100, 5),
    keyword_precision_at_10 =
      precision_at_k(d$dif_label, d$keyword_score_0_100, 10),
    stringsAsFactors = FALSE
  )
}

metrics <- list(metric_one(joined, "overall"))
idx <- 2L
for (cv in sort(unique(joined$covariate))) {
  metrics[[idx]] <- metric_one(joined[joined$covariate == cv, ],
                               paste0("covariate:", cv))
  idx <- idx + 1L
}
metrics <- bind_rows(metrics)

write.csv(joined,
          file.path(out_dir, "maps_llm_gemini_pilot_eval_joined.csv"),
          row.names = FALSE)
write.csv(metrics,
          file.path(out_dir, "maps_llm_gemini_pilot_eval_metrics.csv"),
          row.names = FALSE)

print(metrics)

