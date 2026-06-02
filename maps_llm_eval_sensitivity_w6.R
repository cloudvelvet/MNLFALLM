# Evaluate Gemini sensitivity predictions against wave-6 provisional DIF labels.
#
# Inputs:
#   llm_dif_output/maps_llm_gemini_sensitivity_predictions_flat.csv
#   llm_dif_output/maps_dif_screening_gold_w6.csv
#   llm_dif_output/maps_keyword_baseline_predictions.csv
#
# Outputs:
#   llm_dif_output/maps_llm_gemini_sensitivity_eval_joined_w6.csv
#   llm_dif_output/maps_llm_gemini_sensitivity_eval_metrics_w6.csv
#   llm_dif_output/maps_llm_gemini_sensitivity_rank_overlap_w6.csv

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Package 'dplyr' is required.")
}

library(dplyr)

out_dir <- "llm_dif_output"
pred_csv <- file.path(out_dir, "maps_llm_gemini_sensitivity_predictions_flat.csv")
gold_csv <- file.path(out_dir, "maps_dif_screening_gold_w6.csv")
kw_csv <- file.path(out_dir, "maps_keyword_baseline_predictions.csv")

if (!file.exists(pred_csv)) {
  stop("Missing ", pred_csv, ". Run maps_llm_parse_sensitivity_results.R first.")
}
if (!file.exists(gold_csv)) {
  stop("Missing ", gold_csv, ". Run maps_llm_dif_gold_screen_w6.R first.")
}

pred <- read.csv(pred_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
gold <- read.csv(gold_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
kw <- read.csv(kw_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")

joined <- pred %>%
  filter(parse_status == "ok") %>%
  left_join(
    gold %>% select(scale_id, item_id, covariate, beta, p_fdr, dif_label, direction),
    by = c("scale_id", "item_id", "covariate")
  ) %>%
  left_join(
    kw %>% select(scale_id, item_id, covariate, keyword_score_0_100),
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
    mean_llm_score = mean(d$threshold_dif_probability_0_100, na.rm = TRUE),
    llm_average_precision = average_precision(d$dif_label, d$threshold_dif_probability_0_100),
    llm_precision_at_5 = precision_at_k(d$dif_label, d$threshold_dif_probability_0_100, 5),
    llm_precision_at_10 = precision_at_k(d$dif_label, d$threshold_dif_probability_0_100, 10),
    keyword_average_precision = average_precision(d$dif_label, d$keyword_score_0_100),
    keyword_precision_at_5 = precision_at_k(d$dif_label, d$keyword_score_0_100, 5),
    keyword_precision_at_10 = precision_at_k(d$dif_label, d$keyword_score_0_100, 10),
    stringsAsFactors = FALSE
  )
}

metrics <- list()
idx <- 1L
for (pv in sort(unique(joined$prompt_version))) {
  for (mod in sort(unique(joined$model[joined$prompt_version == pv]))) {
    one <- joined[joined$prompt_version == pv & joined$model == mod, ]
    metrics[[idx]] <- metric_one(one, "overall", pv, mod)
    idx <- idx + 1L
    for (cv in sort(unique(one$covariate))) {
      metrics[[idx]] <- metric_one(one[one$covariate == cv, ],
                                   paste0("covariate:", cv), pv, mod)
      idx <- idx + 1L
    }
  }
}
metrics <- bind_rows(metrics)

rank_overlap <- data.frame()
versions <- sort(unique(joined$prompt_version))
if (length(versions) >= 2L) {
  for (i in seq_len(length(versions) - 1L)) {
    for (j in (i + 1L):length(versions)) {
      a <- joined[joined$prompt_version == versions[i], ]
      b <- joined[joined$prompt_version == versions[j], ]
      key_a <- paste(a$scale_id, a$item_id, a$covariate, sep = "::")
      key_b <- paste(b$scale_id, b$item_id, b$covariate, sep = "::")
      common <- intersect(key_a, key_b)
      if (length(common) == 0L) next
      a <- a[match(common, key_a), ]
      b <- b[match(common, key_b), ]
      for (k in c(5, 10, 20)) {
        ka <- paste(a$scale_id, a$item_id, a$covariate, sep = "::")[
          order(a$threshold_dif_probability_0_100, decreasing = TRUE)[seq_len(min(k, nrow(a)))]
        ]
        kb <- paste(b$scale_id, b$item_id, b$covariate, sep = "::")[
          order(b$threshold_dif_probability_0_100, decreasing = TRUE)[seq_len(min(k, nrow(b)))]
        ]
        rank_overlap <- rbind(rank_overlap, data.frame(
          prompt_version_a = versions[i],
          prompt_version_b = versions[j],
          k = k,
          common_pairs = length(common),
          topk_overlap = length(intersect(ka, kb)) / min(length(ka), length(kb)),
          spearman_score_cor = suppressWarnings(cor(
            a$threshold_dif_probability_0_100,
            b$threshold_dif_probability_0_100,
            method = "spearman",
            use = "complete.obs"
          )),
          stringsAsFactors = FALSE
        ))
      }
    }
  }
}

write.csv(joined, file.path(out_dir, "maps_llm_gemini_sensitivity_eval_joined_w6.csv"),
          row.names = FALSE)
write.csv(metrics, file.path(out_dir, "maps_llm_gemini_sensitivity_eval_metrics_w6.csv"),
          row.names = FALSE)
write.csv(rank_overlap, file.path(out_dir, "maps_llm_gemini_sensitivity_rank_overlap_w6.csv"),
          row.names = FALSE)

print(metrics)
if (nrow(rank_overlap) > 0L) print(rank_overlap)
