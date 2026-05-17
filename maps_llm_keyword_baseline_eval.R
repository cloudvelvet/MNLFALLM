# Free lexical baseline for the MAPS LLM-DIF pilot.
#
# This is not an LLM. It is a simple keyword/rule baseline that future LLM
# predictions should outperform.
#
# Usage:
#   Rscript maps_llm_keyword_baseline_eval.R
#
# Outputs:
#   llm_dif_output/maps_keyword_baseline_predictions.csv
#   llm_dif_output/maps_keyword_baseline_metrics.csv

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Package 'dplyr' is required.")
}

library(dplyr)

out_dir <- "llm_dif_output"
pairs_csv <- file.path(out_dir, "maps_llm_full_item_covariate_pairs.csv")
gold_csv <- file.path(out_dir, "maps_dif_screening_gold_full.csv")

if (!file.exists(pairs_csv) || !file.exists(gold_csv)) {
  stop("Missing input files. Run prep, text-fill, batch, and DIF screen first.")
}

pairs <- read.csv(pairs_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
gold <- read.csv(gold_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")

has_any <- function(text, words) {
  text <- ifelse(is.na(text), "", text)
  vapply(text, function(one) {
    any(vapply(words, function(w) grepl(w, one, fixed = TRUE), logical(1)))
  }, logical(1))
}

score_one <- function(text, covariate) {
  base <- rep(15, length(text))

  if (covariate == "discrim_any") {
    words <- c("다른 대우", "편견", "무시", "위축", "사회적 지위", "따돌",
               "못살게", "외국", "욕", "놀림", "소문")
    base <- base + 55 * has_any(text, words)
  } else if (covariate == "korean_c") {
    words <- c("한국어", "한국문화", "한국 사람", "한국사람", "한국에",
               "한국의", "모국", "외국", "문화", "언어")
    base <- base + 50 * has_any(text, words)
  } else if (covariate == "income_c") {
    words <- c("경제", "형편", "물건", "장소", "제공", "대학", "회사",
               "지위", "건강", "병원")
    base <- base + 45 * has_any(text, words)
  } else if (covariate == "gender") {
    words <- c("외모", "이성친구", "신체적 특징", "친구", "따돌림", "소문",
               "욕설", "놀림")
    base <- base + 35 * has_any(text, words)
  } else if (covariate == "age_c") {
    words <- c("진학", "진로", "미래", "부모역할", "자녀", "아이", "대학",
               "회사", "체류", "비자")
    base <- base + 35 * has_any(text, words)
  }

  pmin(95, pmax(5, base))
}

pred <- pairs %>%
  rowwise() %>%
  mutate(keyword_score_0_100 = score_one(item_text, covariate)) %>%
  ungroup() %>%
  left_join(
    gold %>%
      select(respondent_type, scale_id, item_id, item_stem, covariate,
             beta, p_fdr, dif_label, direction),
    by = c("respondent_type", "scale_id", "item_id", "item_stem", "covariate")
  ) %>%
  mutate(dif_label = as.logical(dif_label))

average_precision <- function(label, score) {
  ok <- !is.na(label) & !is.na(score)
  label <- as.logical(label[ok])
  score <- score[ok]
  if (sum(label) == 0) {
    return(NA_real_)
  }
  ord <- order(score, decreasing = TRUE)
  label <- label[ord]
  precision <- cumsum(label) / seq_along(label)
  sum(precision[label]) / sum(label)
}

precision_at_k <- function(label, score, k) {
  ok <- !is.na(label) & !is.na(score)
  label <- as.logical(label[ok])
  score <- score[ok]
  if (length(label) == 0) {
    return(NA_real_)
  }
  k <- min(k, length(label))
  ord <- order(score, decreasing = TRUE)[seq_len(k)]
  mean(label[ord])
}

metric_one <- function(d, group_label) {
  data.frame(
    group = group_label,
    n_pairs = nrow(d),
    positives = sum(d$dif_label, na.rm = TRUE),
    average_precision = average_precision(d$dif_label, d$keyword_score_0_100),
    precision_at_5 = precision_at_k(d$dif_label, d$keyword_score_0_100, 5),
    precision_at_10 = precision_at_k(d$dif_label, d$keyword_score_0_100, 10),
    precision_at_20 = precision_at_k(d$dif_label, d$keyword_score_0_100, 20)
  )
}

metrics <- list(metric_one(pred, "overall"))
idx <- 2L
for (cv in sort(unique(pred$covariate))) {
  metrics[[idx]] <- metric_one(pred[pred$covariate == cv, ],
                               paste0("covariate:", cv))
  idx <- idx + 1L
}
for (rt in sort(unique(pred$respondent_type))) {
  metrics[[idx]] <- metric_one(pred[pred$respondent_type == rt, ],
                               paste0("respondent:", rt))
  idx <- idx + 1L
}
metrics <- bind_rows(metrics)

write.csv(pred, file.path(out_dir, "maps_keyword_baseline_predictions.csv"),
          row.names = FALSE)
write.csv(metrics, file.path(out_dir, "maps_keyword_baseline_metrics.csv"),
          row.names = FALSE)

message("Saved keyword baseline predictions and metrics.")
print(metrics)

