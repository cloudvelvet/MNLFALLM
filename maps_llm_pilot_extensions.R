# API-free robustness extensions for the MAPS LLM-DIF pilot.
#
# Usage:
#   Rscript maps_llm_pilot_extensions.R
#
# Inputs:
#   llm_dif_output/maps_llm_gemini_pilot_eval_joined.csv
#   llm_dif_output/maps_llm_full_item_covariate_pairs.csv
#
# Outputs:
#   llm_dif_output/maps_llm_pilot_bootstrap_ci.csv
#   llm_dif_output/maps_llm_pilot_permutation_tests.csv
#   llm_dif_output/maps_llm_pilot_threshold_metrics.csv
#   llm_dif_output/maps_llm_pilot_rationale_code_flags.csv
#   llm_dif_output/maps_llm_pilot_rationale_code_summary.csv
#   llm_dif_output/maps_llm_pilot_lexical_baseline_predictions.csv
#   llm_dif_output/maps_llm_pilot_extended_baseline_metrics.csv

out_dir <- "llm_dif_output"
joined_csv <- file.path(out_dir, "maps_llm_gemini_pilot_eval_joined.csv")
pairs_csv <- file.path(out_dir, "maps_llm_full_item_covariate_pairs.csv")

if (!file.exists(joined_csv)) {
  stop("Missing joined pilot evaluation file: ", joined_csv)
}
if (!file.exists(pairs_csv)) {
  stop("Missing item-covariate pair file: ", pairs_csv)
}

set.seed(20260524)

joined <- read.csv(joined_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
pairs <- read.csv(pairs_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")

joined$valid_label <- !(is.na(joined$dif_label) | joined$dif_label == "")
joined$label <- joined$dif_label == "TRUE" | joined$dif_label == TRUE
joined$llm_score <- joined$threshold_dif_probability_0_100
joined$keyword_score <- joined$keyword_score_0_100

average_precision <- function(label, score) {
  ok <- !is.na(label) & !is.na(score)
  label <- as.logical(label[ok])
  score <- as.numeric(score[ok])
  if (length(label) == 0L || sum(label) == 0L) return(NA_real_)
  ord <- order(score, decreasing = TRUE)
  label <- label[ord]
  precision <- cumsum(label) / seq_along(label)
  sum(precision[label]) / sum(label)
}

precision_at_k <- function(label, score, k) {
  ok <- !is.na(label) & !is.na(score)
  label <- as.logical(label[ok])
  score <- as.numeric(score[ok])
  if (length(label) == 0L) return(NA_real_)
  k <- min(k, length(label))
  ord <- order(score, decreasing = TRUE)[seq_len(k)]
  mean(label[ord])
}

metric_row <- function(d, group_label) {
  d <- d[d$valid_label, , drop = FALSE]
  data.frame(
    group = group_label,
    n_pairs = nrow(d),
    positives = sum(d$label, na.rm = TRUE),
    llm_ap = average_precision(d$label, d$llm_score),
    keyword_ap = average_precision(d$label, d$keyword_score),
    lexical_ap = if ("lexical_tfidf_score_0_100" %in% names(d)) {
      average_precision(d$label, d$lexical_tfidf_score_0_100)
    } else {
      NA_real_
    },
    llm_p5 = precision_at_k(d$label, d$llm_score, 5),
    keyword_p5 = precision_at_k(d$label, d$keyword_score, 5),
    lexical_p5 = if ("lexical_tfidf_score_0_100" %in% names(d)) {
      precision_at_k(d$label, d$lexical_tfidf_score_0_100, 5)
    } else {
      NA_real_
    },
    llm_p10 = precision_at_k(d$label, d$llm_score, 10),
    keyword_p10 = precision_at_k(d$label, d$keyword_score, 10),
    lexical_p10 = if ("lexical_tfidf_score_0_100" %in% names(d)) {
      precision_at_k(d$label, d$lexical_tfidf_score_0_100, 10)
    } else {
      NA_real_
    },
    stringsAsFactors = FALSE
  )
}

compute_pair_metrics <- function(d) {
  c(
    llm_ap = average_precision(d$label, d$llm_score),
    keyword_ap = average_precision(d$label, d$keyword_score),
    diff_ap = average_precision(d$label, d$llm_score) -
      average_precision(d$label, d$keyword_score)
  )
}

bootstrap_ci <- function(d, group_label, unit_col = "custom_id", n_boot = 2000L) {
  d <- d[d$valid_label & !is.na(d$llm_score) & !is.na(d$keyword_score), ,
         drop = FALSE]
  units <- unique(d[[unit_col]])
  reps <- matrix(NA_real_, nrow = n_boot, ncol = 3L)
  colnames(reps) <- c("llm_ap", "keyword_ap", "diff_ap")
  for (b in seq_len(n_boot)) {
    sampled <- sample(units, length(units), replace = TRUE)
    boot <- do.call(rbind, lapply(sampled, function(u) d[d[[unit_col]] == u, ,
                                                           drop = FALSE]))
    reps[b, ] <- compute_pair_metrics(boot)
  }
  out <- data.frame(
    group = group_label,
    n_units = length(units),
    n_pairs = nrow(d),
    positives = sum(d$label),
    valid_reps = colSums(!is.na(reps)),
    metric = colnames(reps),
    estimate = compute_pair_metrics(d),
    ci_low = apply(reps, 2L, quantile, probs = 0.025, na.rm = TRUE),
    ci_high = apply(reps, 2L, quantile, probs = 0.975, na.rm = TRUE),
    stringsAsFactors = FALSE
  )
  rownames(out) <- NULL
  out
}

permutation_test <- function(d, group_label, n_perm = 5000L) {
  d <- d[d$valid_label & !is.na(d$llm_score) & !is.na(d$keyword_score), ,
         drop = FALSE]
  obs <- compute_pair_metrics(d)[["diff_ap"]]
  perm <- rep(NA_real_, n_perm)
  for (i in seq_len(n_perm)) {
    swap <- sample(c(FALSE, TRUE), nrow(d), replace = TRUE)
    llm_s <- d$llm_score
    kw_s <- d$keyword_score
    llm_s[swap] <- d$keyword_score[swap]
    kw_s[swap] <- d$llm_score[swap]
    perm[i] <- average_precision(d$label, llm_s) -
      average_precision(d$label, kw_s)
  }
  data.frame(
    group = group_label,
    n_pairs = nrow(d),
    positives = sum(d$label),
    observed_diff_ap = obs,
    permutation_mean_diff = mean(perm, na.rm = TRUE),
    p_two_sided = mean(abs(perm) >= abs(obs), na.rm = TRUE),
    p_one_sided_llm_gt_keyword = mean(perm >= obs, na.rm = TRUE),
    stringsAsFactors = FALSE
  )
}

threshold_metrics <- function(d, thresholds = c(50, 70)) {
  d <- d[d$valid_label, , drop = FALSE]
  rows <- lapply(thresholds, function(th) {
    pred <- d$llm_score >= th
    pos <- d$label
    tp <- sum(pred & pos, na.rm = TRUE)
    fp <- sum(pred & !pos, na.rm = TRUE)
    fn <- sum(!pred & pos, na.rm = TRUE)
    tn <- sum(!pred & !pos, na.rm = TRUE)
    precision <- ifelse(tp + fp == 0, NA_real_, tp / (tp + fp))
    recall <- ifelse(tp + fn == 0, NA_real_, tp / (tp + fn))
    specificity <- ifelse(tn + fp == 0, NA_real_, tn / (tn + fp))
    f1 <- ifelse(is.na(precision + recall) || precision + recall == 0,
                 NA_real_, 2 * precision * recall / (precision + recall))
    data.frame(
      threshold = th, TP = tp, FP = fp, FN = fn, TN = tn,
      precision = precision, recall = recall, specificity = specificity,
      F1 = f1
    )
  })
  do.call(rbind, rows)
}

# Bootstrap and permutation outputs.
groups <- c("overall", paste0("covariate:", sort(unique(joined$covariate))))
group_data <- lapply(groups, function(g) {
  if (g == "overall") joined else joined[joined$covariate == sub("^covariate:", "", g), ]
})
names(group_data) <- groups

boot <- do.call(rbind, Map(function(d, g) bootstrap_ci(d, g), group_data, groups))
perm <- do.call(rbind, Map(function(d, g) permutation_test(d, g), group_data, groups))
thr <- threshold_metrics(joined)

write.csv(boot, file.path(out_dir, "maps_llm_pilot_bootstrap_ci.csv"),
          row.names = FALSE)
write.csv(perm, file.path(out_dir, "maps_llm_pilot_permutation_tests.csv"),
          row.names = FALSE)
write.csv(thr, file.path(out_dir, "maps_llm_pilot_threshold_metrics.csv"),
          row.names = FALSE)

# Rule-based rationale coding.
contains <- function(x, pattern) {
  grepl(pattern, x, ignore.case = TRUE, perl = TRUE)
}

r <- ifelse(is.na(joined$rationale), "", joined$rationale)
has_same_latent <- contains(r, "same latent|at the same|given.*latent")
has_threshold <- contains(r, "threshold|endorse|endorsement|response|report|interpret|perceiv|salien|articulat|express")
has_direction_words <- contains(
  r,
  "lower|higher|easier|harder|more likely|less likely|raise|shift|increase|decrease|underreport|overreport"
)

codes <- joined
codes$code_WORDING <- contains(r, "wording|phrase|term|language|straightforward|interpretation of|specific wording")
codes$code_RESPONSE_PROCESS <- has_threshold
codes$code_CULTURE_LANGUAGE_CONTEXT <- contains(
  r,
  "Korean|language|communication|culture|foreign|home country|Korea|acculturation|linguistic"
)
codes$code_COVARIATE_MECHANISM <- contains(
  r,
  "discrimination|prejudice|Korean proficiency|income|socioeconomic|gender|age|older|younger|developmental"
)
codes$code_CONSTRUCT_RELEVANCE <- contains(
  r,
  "latent|construct|true level|actual experience|overall level|actual feelings"
)
codes$code_DIRECTIONAL_HYPOTHESIS <- codes$expected_direction != "unclear" & has_direction_words
codes$code_TESTABLE_HYPOTHESIS <- has_same_latent | contains(r, "DIF|differential|response threshold")
codes$code_ALTERNATIVE_EXPLANATION <- contains(
  r,
  "rather than|more likely to influence|true level|latent construct difference|not a differential|not directly"
)

codes$code_IMPACT_DIF_CONFUSION <- codes$llm_score >= 50 & contains(
  r,
  "actual experience|true level|overall level|directly impacts|resources that can alleviate|access to|opportunities"
)
codes$code_NO_WITHIN_TRAIT_CONDITIONING <- codes$llm_score >= 50 & !has_same_latent
codes$code_STEREOTYPE_GENDER_AGE <- codes$covariate %in% c("gender", "age_c") &
  codes$llm_score >= 50 & contains(
    r,
    "gendered|gender differences|societal gender|older|younger|age-related|developmental|adolescents"
  )
codes$code_VAGUE_GENERALITY <- contains(
  r,
  "may influence|could lead|might subtly|general demographic|not clear"
)
codes$code_ITEM_IRRELEVANT_SPECULATION <- codes$llm_score >= 50 & contains(
  r,
  "general resource|general risk factor|general demographic|societal norms|opportunities|overall life satisfaction"
)
codes$code_DIRECTION_UNSUPPORTED <- codes$expected_direction != "unclear" & !has_direction_words
codes$code_HALLUCINATED_ITEM_CONTENT <- FALSE
codes$code_OVERCLAIM_DIF <- contains(r, "definitely|certainly|clear DIF|obvious DIF|must be DIF")
codes$code_CONSTRUCT_CONFUSION <- FALSE
codes$code_UNFAIR_ATTRIBUTION <- contains(r, "irrational|inferior|ignorant|incapable")

codes$outcome_70 <- ifelse(!codes$valid_label, "missing_label",
                           ifelse(codes$llm_score >= 70 & codes$label, "TP70",
                                  ifelse(codes$llm_score >= 70 & !codes$label, "FP70",
                                         ifelse(codes$llm_score < 70 & codes$label, "FN70", "TN70"))))

code_cols <- grep("^code_", names(codes), value = TRUE)
summary_rows <- list()
idx <- 1L
for (cc in code_cols) {
  flag <- as.logical(codes[[cc]])
  valid <- codes$valid_label
  summary_rows[[idx]] <- data.frame(
    code = sub("^code_", "", cc),
    group = "overall",
    n = sum(valid),
    flagged = sum(flag & valid, na.rm = TRUE),
    rate = mean(flag[valid], na.rm = TRUE),
    stringsAsFactors = FALSE
  )
  idx <- idx + 1L
  for (og in c("TP70", "FP70", "FN70", "TN70")) {
    subset <- valid & codes$outcome_70 == og
    summary_rows[[idx]] <- data.frame(
      code = sub("^code_", "", cc),
      group = og,
      n = sum(subset),
      flagged = sum(flag & subset, na.rm = TRUE),
      rate = ifelse(sum(subset) == 0, NA_real_, mean(flag[subset], na.rm = TRUE)),
      stringsAsFactors = FALSE
    )
    idx <- idx + 1L
  }
}
code_summary <- do.call(rbind, summary_rows)

write.csv(codes, file.path(out_dir, "maps_llm_pilot_rationale_code_flags.csv"),
          row.names = FALSE)
write.csv(code_summary,
          file.path(out_dir, "maps_llm_pilot_rationale_code_summary.csv"),
          row.names = FALSE)

# TF-IDF lexical similarity baseline.
cov_docs <- data.frame(
  covariate = c("discrim_any", "korean_c", "income_c", "gender", "age_c"),
  cov_doc = c(
    "discrimination prejudice unfair treatment ignored bullying ostracism foreign minority acculturative stress social exclusion",
    "korean language proficiency communication korea culture acculturation linguistic comprehension foreign",
    "income household economic financial resources poverty career health worry opportunity",
    "gender male female peer relationship appearance social expectation self esteem bullying",
    "age developmental grade older younger adolescent career future parent child maturity"
  ),
  stringsAsFactors = FALSE
)

pairs_small <- pairs[, c("scale_id", "item_id", "covariate", "scale_name",
                         "item_stem", "item_text", "covariate_label")]
lex <- merge(joined, pairs_small,
             by = c("scale_id", "item_id", "covariate"),
             all.x = TRUE, sort = FALSE)
lex <- merge(lex, cov_docs, by = "covariate", all.x = TRUE, sort = FALSE)

clean_tokens <- function(x) {
  x <- tolower(ifelse(is.na(x), "", x))
  x <- gsub("[^[:alnum:]_]+", " ", x, perl = TRUE)
  toks <- unlist(strsplit(x, "\\s+"), use.names = FALSE)
  toks <- toks[nchar(toks) >= 3L]
  toks[!toks %in% c("the", "and", "for", "with", "item", "parent", "youth")]
}

item_docs <- paste(lex$scale_name, lex$item_stem, lex$item_id, lex$item_text,
                   lex$covariate_label)
cov_texts <- lex$cov_doc
all_docs <- c(item_docs, cov_texts)
doc_tokens <- lapply(all_docs, clean_tokens)
vocab <- sort(unique(unlist(doc_tokens, use.names = FALSE)))

tfidf_matrix <- function(tokens_list, vocab) {
  m <- matrix(0, nrow = length(tokens_list), ncol = length(vocab))
  colnames(m) <- vocab
  for (i in seq_along(tokens_list)) {
    tab <- table(tokens_list[[i]])
    common <- intersect(names(tab), vocab)
    if (length(common) > 0L) m[i, common] <- as.numeric(tab[common])
  }
  df <- colSums(m > 0)
  idf <- log((nrow(m) + 1) / (df + 1)) + 1
  sweep(m, 2L, idf, `*`)
}

mat <- tfidf_matrix(doc_tokens, vocab)
n <- nrow(lex)
item_mat <- mat[seq_len(n), , drop = FALSE]
cov_mat <- mat[n + seq_len(n), , drop = FALSE]
cosine <- function(a, b) {
  num <- rowSums(a * b)
  den <- sqrt(rowSums(a * a)) * sqrt(rowSums(b * b))
  ifelse(den == 0, 0, num / den)
}
sim <- cosine(item_mat, cov_mat)
if (max(sim, na.rm = TRUE) > min(sim, na.rm = TRUE)) {
  score <- 100 * (sim - min(sim, na.rm = TRUE)) /
    (max(sim, na.rm = TRUE) - min(sim, na.rm = TRUE))
} else {
  score <- rep(0, length(sim))
}
lex$lexical_tfidf_similarity <- sim
lex$lexical_tfidf_score_0_100 <- score

write.csv(lex, file.path(out_dir, "maps_llm_pilot_lexical_baseline_predictions.csv"),
          row.names = FALSE)

joined_ext <- joined
joined_ext$lexical_tfidf_score_0_100 <- lex$lexical_tfidf_score_0_100

metric_groups <- c("overall", paste0("covariate:", sort(unique(joined_ext$covariate))))
metrics <- lapply(metric_groups, function(g) {
  if (g == "overall") {
    metric_row(joined_ext, g)
  } else {
    cv <- sub("^covariate:", "", g)
    metric_row(joined_ext[joined_ext$covariate == cv, , drop = FALSE], g)
  }
})
metrics <- do.call(rbind, metrics)
write.csv(metrics, file.path(out_dir, "maps_llm_pilot_extended_baseline_metrics.csv"),
          row.names = FALSE)

cat("Saved API-free pilot extension outputs.\n")
cat("Bootstrap/permutation, rationale coding, threshold metrics, and lexical baseline are complete.\n")
print(metrics)
