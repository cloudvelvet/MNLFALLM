# Tie-randomized evaluation for the binary keyword baseline.
#
# Binary keyword scores create large ties. This script repeatedly shuffles rows
# within equal keyword scores and reports mean AP/P@k for the keyword baseline.
# LLM metrics are deterministic and are included for comparison.

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Package 'dplyr' is required.")
}

library(dplyr)

set.seed(20260531)

out_dir <- "llm_dif_output"
n_rep <- 2000L

average_precision_ordered <- function(label) {
  label <- as.logical(label)
  if (length(label) == 0L || sum(label) == 0L) return(NA_real_)
  precision <- cumsum(label) / seq_along(label)
  sum(precision[label]) / sum(label)
}

precision_at_k_ordered <- function(label, k) {
  label <- as.logical(label)
  if (length(label) == 0L) return(NA_real_)
  k <- min(k, length(label))
  mean(label[seq_len(k)])
}

average_precision <- function(label, score) {
  ok <- !is.na(label) & !is.na(score)
  label <- as.logical(label[ok])
  score <- score[ok]
  if (length(label) == 0L || sum(label) == 0L) return(NA_real_)
  ord <- order(score, decreasing = TRUE)
  average_precision_ordered(label[ord])
}

precision_at_k <- function(label, score, k) {
  ok <- !is.na(label) & !is.na(score)
  label <- as.logical(label[ok])
  score <- score[ok]
  if (length(label) == 0L) return(NA_real_)
  ord <- order(score, decreasing = TRUE)
  precision_at_k_ordered(label[ord], k)
}

shuffle_ties <- function(score) {
  split_idx <- split(seq_along(score), score)
  lev <- sort(as.numeric(names(split_idx)), decreasing = TRUE)
  unlist(lapply(as.character(lev), function(x) sample(split_idx[[x]])), use.names = FALSE)
}

tie_eval_one <- function(d, group_label, prompt_version, model) {
  ok <- !is.na(d$dif_label) & !is.na(d$keyword_score_0_100)
  d <- d[ok, ]
  if (nrow(d) == 0L || sum(d$dif_label, na.rm = TRUE) == 0L) {
    return(NULL)
  }

  ap <- numeric(n_rep)
  p5 <- numeric(n_rep)
  p10 <- numeric(n_rep)
  for (i in seq_len(n_rep)) {
    ord <- shuffle_ties(d$keyword_score_0_100)
    lab <- d$dif_label[ord]
    ap[i] <- average_precision_ordered(lab)
    p5[i] <- precision_at_k_ordered(lab, 5)
    p10[i] <- precision_at_k_ordered(lab, 10)
  }

  data.frame(
    prompt_version = prompt_version,
    model = model,
    group = group_label,
    n_pairs = nrow(d),
    positives = sum(d$dif_label, na.rm = TRUE),
    positive_prevalence = mean(d$dif_label, na.rm = TRUE),
    keyword_hit_rate = mean(d$keyword_hit, na.rm = TRUE),
    llm_average_precision = average_precision(d$dif_label, d$threshold_dif_probability_0_100),
    llm_precision_at_5 = precision_at_k(d$dif_label, d$threshold_dif_probability_0_100, 5),
    llm_precision_at_10 = precision_at_k(d$dif_label, d$threshold_dif_probability_0_100, 10),
    keyword_ap_mean = mean(ap),
    keyword_ap_lo = unname(quantile(ap, .025)),
    keyword_ap_hi = unname(quantile(ap, .975)),
    keyword_p5_mean = mean(p5),
    keyword_p5_lo = unname(quantile(p5, .025)),
    keyword_p5_hi = unname(quantile(p5, .975)),
    keyword_p10_mean = mean(p10),
    keyword_p10_lo = unname(quantile(p10, .025)),
    keyword_p10_hi = unname(quantile(p10, .975)),
    stringsAsFactors = FALSE
  )
}

evaluate_one <- function(joined_path, suffix) {
  d <- read.csv(joined_path, stringsAsFactors = FALSE, fileEncoding = "UTF-8") %>%
    mutate(
      dif_label = as.logical(dif_label),
      keyword_hit = as.logical(keyword_hit)
    )

  rows <- list()
  idx <- 1L
  for (pv in sort(unique(d$prompt_version))) {
    for (mod in sort(unique(d$model[d$prompt_version == pv]))) {
      one <- d[d$prompt_version == pv & d$model == mod, ]
      rows[[idx]] <- tie_eval_one(one, "overall", pv, mod)
      idx <- idx + 1L
      for (cv in sort(unique(one$covariate))) {
        rows[[idx]] <- tie_eval_one(one[one$covariate == cv, ],
                                    paste0("covariate:", cv), pv, mod)
        idx <- idx + 1L
      }
    }
  }
  out <- bind_rows(rows)
  out_path <- file.path(out_dir, paste0("maps_llm_binary_keyword_tie_randomized_metrics", suffix, ".csv"))
  write.csv(out, out_path, row.names = FALSE, fileEncoding = "UTF-8")
  out
}

main <- evaluate_one(
  file.path(out_dir, "maps_llm_gemini_sensitivity_eval_joined_binary_keyword.csv"),
  ""
)
w6 <- evaluate_one(
  file.path(out_dir, "maps_llm_gemini_sensitivity_eval_joined_binary_keyword_w6.csv"),
  "_w6"
)

message("Main tie-randomized binary keyword metrics:")
print(main)
message("Wave-6 tie-randomized binary keyword metrics:")
print(w6)
