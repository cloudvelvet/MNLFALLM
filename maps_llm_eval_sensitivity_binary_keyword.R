# Evaluate Gemini prompt-sensitivity predictions with the binary keyword baseline.
#
# Existing weighted-keyword evaluation files are not overwritten.

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Package 'dplyr' is required.")
}

library(dplyr)

out_dir <- "llm_dif_output"
pred_csv <- file.path(out_dir, "maps_llm_gemini_sensitivity_predictions_flat.csv")
kw_csv <- file.path(out_dir, "maps_keyword_binary_baseline_predictions.csv")

if (!file.exists(pred_csv)) {
  stop("Missing ", pred_csv, ". Run maps_llm_parse_sensitivity_results.R first.")
}
if (!file.exists(kw_csv)) {
  stop("Missing ", kw_csv, ". Run maps_llm_keyword_binary_eval.R first.")
}

average_precision <- function(label, score) {
  ok <- !is.na(label) & !is.na(score)
  label <- as.logical(label[ok])
  score <- score[ok]
  if (length(label) == 0L || sum(label) == 0L) return(NA_real_)
  ord <- order(score, decreasing = TRUE)
  label <- label[ord]
  precision <- cumsum(label) / seq_along(label)
  sum(precision[label]) / sum(label)
}

precision_at_k <- function(label, score, k) {
  ok <- !is.na(label) & !is.na(score)
  label <- as.logical(label[ok])
  score <- score[ok]
  if (length(label) == 0L) return(NA_real_)
  k <- min(k, length(label))
  ord <- order(score, decreasing = TRUE)[seq_len(k)]
  mean(label[ord])
}

metric_one <- function(d, group_label, prompt_version, model) {
  data.frame(
    prompt_version = prompt_version,
    model = model,
    group = group_label,
    n_pairs = nrow(d),
    n_items = length(unique(d$item_id)),
    positives = sum(d$dif_label, na.rm = TRUE),
    positive_prevalence = mean(d$dif_label, na.rm = TRUE),
    mean_llm_score = mean(d$threshold_dif_probability_0_100, na.rm = TRUE),
    keyword_hit_rate = mean(d$keyword_hit, na.rm = TRUE),
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

evaluate_one <- function(gold_path, suffix) {
  if (!file.exists(gold_path)) stop("Missing gold file: ", gold_path)

  pred <- read.csv(pred_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
  gold <- read.csv(gold_path, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
  kw <- read.csv(kw_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")

  joined <- pred %>%
    filter(parse_status == "ok") %>%
    left_join(
      gold %>% select(scale_id, item_id, covariate, beta, p_fdr, dif_label, direction),
      by = c("scale_id", "item_id", "covariate")
    ) %>%
    left_join(
      kw %>% select(scale_id, item_id, covariate, keyword_score_0_100, keyword_hit),
      by = c("scale_id", "item_id", "covariate")
    ) %>%
    mutate(
      dif_label = as.logical(dif_label),
      keyword_hit = as.logical(keyword_hit),
      llm_flag_50 = threshold_dif_probability_0_100 >= 50,
      llm_flag_70 = threshold_dif_probability_0_100 >= 70
    )

  metrics <- list()
  idx <- 1L
  for (pv in sort(unique(joined$prompt_version))) {
    for (mod in sort(unique(joined$model[joined$prompt_version == pv]))) {
      one <- joined[joined$prompt_version == pv & joined$model == mod, ]
      metrics[[idx]] <- metric_one(one, "overall", pv, mod)
      idx <- idx + 1L
      for (cv in sort(unique(one$covariate))) {
        metrics[[idx]] <- metric_one(
          one[one$covariate == cv, ],
          paste0("covariate:", cv),
          pv,
          mod
        )
        idx <- idx + 1L
      }
    }
  }
  metrics <- bind_rows(metrics)

  write.csv(
    joined,
    file.path(out_dir, paste0("maps_llm_gemini_sensitivity_eval_joined_binary_keyword", suffix, ".csv")),
    row.names = FALSE,
    fileEncoding = "UTF-8"
  )
  write.csv(
    metrics,
    file.path(out_dir, paste0("maps_llm_gemini_sensitivity_eval_metrics_binary_keyword", suffix, ".csv")),
    row.names = FALSE,
    fileEncoding = "UTF-8"
  )

  metrics
}

main_metrics <- evaluate_one(
  file.path(out_dir, "maps_dif_screening_gold_full.csv"),
  ""
)
w6_metrics <- evaluate_one(
  file.path(out_dir, "maps_dif_screening_gold_w6.csv"),
  "_w6"
)

message("Main metrics with binary keyword baseline:")
print(main_metrics)
message("Wave-6 metrics with binary keyword baseline:")
print(w6_metrics)
