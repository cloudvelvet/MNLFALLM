# Ordinal DIF screening with respondent-level cluster-robust SEs.
#
# This script mirrors maps_llm_dif_gold_screen.R, but it recomputes the
# covariate p-values using sandwich::vcovCL clustered on person_id. The
# coefficient estimates are unchanged from the proportional-odds model; only
# the standard errors, Wald tests, FDR values, and screening labels change.
#
# Usage:
#   Rscript maps_llm_dif_gold_screen_cluster_robust.R full
#
# Outputs:
#   llm_dif_output/maps_dif_screening_gold_cluster_robust_<mode>.csv
#   llm_dif_output/maps_dif_screening_gold_cluster_robust_summary_<mode>.csv
#   llm_dif_output/maps_llm_gemini_sensitivity_eval_metrics_cluster_robust_<mode>.csv
#   llm_dif_output/maps_llm_gemini_sensitivity_eval_joined_cluster_robust_<mode>.csv
#   llm_dif_output/maps_cluster_robust_label_comparison_<mode>.csv

args <- commandArgs(trailingOnly = TRUE)
mode <- if (length(args) >= 1) args[1] else "full"
if (!mode %in% c("quick", "full")) {
  stop("Mode must be 'quick' or 'full'.")
}

for (pkg in c("dplyr", "MASS", "sandwich")) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop("Package '", pkg, "' is required.")
  }
}

library(dplyr)

out_dir <- "llm_dif_output"
in_csv <- file.path(out_dir, "maps_multiscale_long.csv")
main_gold_csv <- file.path(out_dir, paste0("maps_dif_screening_gold_", mode, ".csv"))
pred_csv <- file.path(out_dir, "maps_llm_gemini_sensitivity_predictions_flat.csv")
kw_csv <- file.path(out_dir, "maps_keyword_baseline_predictions.csv")

if (!file.exists(in_csv)) {
  stop("Missing ", in_csv, ". Run maps_multiscale_llm_prep.R first.")
}
if (!file.exists(main_gold_csv)) {
  stop("Missing ", main_gold_csv, ". Run maps_llm_dif_gold_screen.R first.")
}

message("Reading: ", in_csv)
dat <- read.csv(in_csv, stringsAsFactors = FALSE)

reverse_key_candidates <- c(
  "p_esteem_03", "p_esteem_05", "p_esteem_08", "p_esteem_09",
  "p_efficacy_08",
  "parenting_b01", "parenting_b02", "parenting_b03", "parenting_b04",
  "parenting_b05"
)

if (mode == "quick") {
  keep_scales <- c(
    "parent_acculturative_stress",
    "parent_self_esteem",
    "youth_acculturative_stress",
    "youth_bicultural_acceptance"
  )
  dat <- dat[dat$scale_id %in% keep_scales, ]
}

dat <- dat %>%
  group_by(scale_id) %>%
  mutate(
    max_resp_scale = max(resp, na.rm = TRUE),
    reverse_key_candidate = item_stem %in% reverse_key_candidates,
    resp_model = ifelse(reverse_key_candidate, max_resp_scale + 1 - resp, resp)
  ) %>%
  ungroup() %>%
  group_by(respondent_type, scale_id, person_id, wave) %>%
  mutate(
    scale_n = sum(!is.na(resp_model)),
    scale_sum = sum(resp_model, na.rm = TRUE),
    theta_proxy = ifelse(scale_n > 1, (scale_sum - resp_model) / (scale_n - 1), NA_real_)
  ) %>%
  ungroup()

covariates_for <- function(respondent_type) {
  base <- c("discrim_any", "korean_c", "income_c", "age_c")
  if (respondent_type == "youth") {
    return(c(base, "gender"))
  }
  base
}

fit_one <- function(d, covariate) {
  needed <- c("resp_model", "theta_proxy", "wave", "person_id", covariate)
  d <- d[stats::complete.cases(d[, needed]), needed, drop = FALSE]
  names(d)[names(d) == covariate] <- "covariate_value"

  n_clusters <- length(unique(d$person_id))
  if (nrow(d) < 200 ||
      n_clusters < 30 ||
      length(unique(d$resp_model)) < 3 ||
      length(unique(d$covariate_value)) < 2 ||
      stats::sd(d$covariate_value, na.rm = TRUE) == 0 ||
      length(unique(d$wave)) < 2) {
    return(data.frame(
      beta = NA_real_,
      se_model = NA_real_,
      z_model = NA_real_,
      p_model = NA_real_,
      se_cluster = NA_real_,
      z_cluster = NA_real_,
      p_cluster = NA_real_,
      n = nrow(d),
      clusters = n_clusters,
      categories = length(unique(d$resp_model)),
      status = "skipped_insufficient_data",
      robust_status = NA_character_,
      stringsAsFactors = FALSE
    ))
  }

  d$resp_model <- as.ordered(d$resp_model)
  d$wave <- factor(d$wave)

  fit <- tryCatch(
    suppressWarnings(MASS::polr(
      resp_model ~ theta_proxy + covariate_value + wave,
      data = d,
      method = "logistic",
      Hess = TRUE
    )),
    error = function(e) e
  )

  if (inherits(fit, "error")) {
    return(data.frame(
      beta = NA_real_,
      se_model = NA_real_,
      z_model = NA_real_,
      p_model = NA_real_,
      se_cluster = NA_real_,
      z_cluster = NA_real_,
      p_cluster = NA_real_,
      n = nrow(d),
      clusters = n_clusters,
      categories = length(unique(d$resp_model)),
      status = paste0("error: ", fit$message),
      robust_status = NA_character_,
      stringsAsFactors = FALSE
    ))
  }

  coefs <- coef(summary(fit))
  if (!"covariate_value" %in% rownames(coefs)) {
    return(data.frame(
      beta = NA_real_,
      se_model = NA_real_,
      z_model = NA_real_,
      p_model = NA_real_,
      se_cluster = NA_real_,
      z_cluster = NA_real_,
      p_cluster = NA_real_,
      n = nrow(d),
      clusters = n_clusters,
      categories = length(unique(d$resp_model)),
      status = "missing_covariate_coefficient",
      robust_status = NA_character_,
      stringsAsFactors = FALSE
    ))
  }

  beta <- unname(coefs["covariate_value", "Value"])
  se_model <- unname(coefs["covariate_value", "Std. Error"])
  z_model <- beta / se_model
  p_model <- 2 * stats::pnorm(abs(z_model), lower.tail = FALSE)

  robust <- tryCatch({
    vc <- sandwich::vcovCL(fit, cluster = d$person_id, type = "HC0")
    se_cluster <- sqrt(diag(vc))[["covariate_value"]]
    z_cluster <- beta / se_cluster
    p_cluster <- 2 * stats::pnorm(abs(z_cluster), lower.tail = FALSE)
    list(
      se_cluster = se_cluster,
      z_cluster = z_cluster,
      p_cluster = p_cluster,
      robust_status = "ok"
    )
  }, error = function(e) {
    list(
      se_cluster = NA_real_,
      z_cluster = NA_real_,
      p_cluster = NA_real_,
      robust_status = paste0("robust_error: ", e$message)
    )
  })

  data.frame(
    beta = beta,
    se_model = se_model,
    z_model = z_model,
    p_model = p_model,
    se_cluster = robust$se_cluster,
    z_cluster = robust$z_cluster,
    p_cluster = robust$p_cluster,
    n = nrow(d),
    clusters = n_clusters,
    categories = length(unique(d$resp_model)),
    status = "ok",
    robust_status = robust$robust_status,
    stringsAsFactors = FALSE
  )
}

groups <- dat %>%
  distinct(respondent_type, scale_id, scale_name, item_id, item_stem) %>%
  arrange(respondent_type, scale_id, item_stem)

message("Fitting cluster-robust screening models: ", nrow(groups),
        " items x respondent-valid covariates")

rows <- list()
idx <- 1L
for (i in seq_len(nrow(groups))) {
  g <- groups[i, ]
  if (i %% 10L == 0L) {
    message("Item ", i, "/", nrow(groups), ": ", g$item_id)
  }
  item_dat <- dat %>%
    filter(
      respondent_type == g$respondent_type,
      scale_id == g$scale_id,
      item_id == g$item_id
    )

  for (covar in covariates_for(g$respondent_type)) {
    res <- fit_one(item_dat, covar)
    rows[[idx]] <- cbind(
      data.frame(
        respondent_type = g$respondent_type,
        scale_id = g$scale_id,
        scale_name = g$scale_name,
        item_id = g$item_id,
        item_stem = g$item_stem,
        covariate = covar,
        model = "uniform_ordinal_logit_cluster_robust_person",
        dif_type = "uniform_threshold_proxy_cluster_robust",
        stringsAsFactors = FALSE
      ),
      res
    )
    idx <- idx + 1L
  }
}

out <- bind_rows(rows)
out$p_fdr_cluster <- NA_real_
ok <- out$status == "ok" & out$robust_status == "ok" & !is.na(out$p_cluster)
out$p_fdr_cluster[ok] <- p.adjust(out$p_cluster[ok], method = "BH")
out$practical_nonzero <- ok & abs(out$beta) >= 0.20
out$dif_label_cluster <- ok & out$p_fdr_cluster < 0.05 & out$practical_nonzero
out$direction <- ifelse(is.na(out$beta), NA_character_,
                        ifelse(out$beta > 0, "positive", "negative"))
out$se_ratio_cluster_to_model <- out$se_cluster / out$se_model

robust_csv <- file.path(out_dir, paste0("maps_dif_screening_gold_cluster_robust_", mode, ".csv"))
write.csv(out, robust_csv, row.names = FALSE)

summary <- out %>%
  group_by(respondent_type, scale_id, covariate) %>%
  summarise(
    tests = n(),
    ok = sum(status == "ok" & robust_status == "ok"),
    dif_positive_cluster = sum(dif_label_cluster, na.rm = TRUE),
    mean_abs_beta = mean(abs(beta), na.rm = TRUE),
    median_se_ratio = median(se_ratio_cluster_to_model, na.rm = TRUE),
    .groups = "drop"
  )

summary_csv <- file.path(out_dir, paste0("maps_dif_screening_gold_cluster_robust_summary_", mode, ".csv"))
write.csv(summary, summary_csv, row.names = FALSE)

main_gold <- read.csv(main_gold_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
label_comparison <- main_gold %>%
  dplyr::select(respondent_type, scale_id, item_id, item_stem, covariate,
                beta_main = beta, se_main = se, p_fdr_main = p_fdr,
                dif_label_main = dif_label) %>%
  left_join(
    out %>%
      dplyr::select(respondent_type, scale_id, item_id, item_stem, covariate,
                    beta, se_model, se_cluster, se_ratio_cluster_to_model,
                    p_fdr_cluster, dif_label_cluster),
    by = c("respondent_type", "scale_id", "item_id", "item_stem", "covariate")
  ) %>%
  mutate(
    dif_label_main = as.logical(dif_label_main),
    dif_label_cluster = as.logical(dif_label_cluster),
    label_change = case_when(
      dif_label_main & dif_label_cluster ~ "positive_both",
      dif_label_main & !dif_label_cluster ~ "main_only",
      !dif_label_main & dif_label_cluster ~ "cluster_only",
      TRUE ~ "negative_both"
    )
  )

comparison_csv <- file.path(out_dir, paste0("maps_cluster_robust_label_comparison_", mode, ".csv"))
write.csv(label_comparison, comparison_csv, row.names = FALSE)

average_precision <- function(label, score) {
  ok2 <- !is.na(label) & !is.na(score)
  label <- as.logical(label[ok2])
  score <- score[ok2]
  if (length(label) == 0L || sum(label) == 0L) return(NA_real_)
  ord <- order(score, decreasing = TRUE)
  label <- label[ord]
  precision <- cumsum(label) / seq_along(label)
  sum(precision[label]) / sum(label)
}

precision_at_k <- function(label, score, k) {
  ok2 <- !is.na(label) & !is.na(score)
  label <- as.logical(label[ok2])
  score <- score[ok2]
  if (length(label) == 0L) return(NA_real_)
  k <- min(k, length(label))
  ord <- order(score, decreasing = TRUE)[seq_len(k)]
  mean(label[ord])
}

if (file.exists(pred_csv) && file.exists(kw_csv)) {
  pred <- read.csv(pred_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
  kw <- read.csv(kw_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")

  joined <- pred %>%
    filter(parse_status == "ok") %>%
    left_join(
      out %>%
        dplyr::select(scale_id, item_id, covariate, beta, p_fdr_cluster,
                      dif_label_cluster, direction, se_cluster,
                      se_ratio_cluster_to_model),
      by = c("scale_id", "item_id", "covariate")
    ) %>%
    left_join(
      kw %>%
        dplyr::select(scale_id, item_id, covariate, keyword_score_0_100),
      by = c("scale_id", "item_id", "covariate")
    ) %>%
    mutate(dif_label_cluster = as.logical(dif_label_cluster))

  metric_one <- function(d, group_label, prompt_version, model) {
    data.frame(
      prompt_version = prompt_version,
      model = model,
      group = group_label,
      n_pairs = nrow(d),
      n_items = length(unique(d$item_id)),
      positives = sum(d$dif_label_cluster, na.rm = TRUE),
      positive_prevalence = mean(d$dif_label_cluster, na.rm = TRUE),
      mean_llm_score = mean(d$threshold_dif_probability_0_100, na.rm = TRUE),
      llm_average_precision =
        average_precision(d$dif_label_cluster, d$threshold_dif_probability_0_100),
      llm_precision_at_5 =
        precision_at_k(d$dif_label_cluster, d$threshold_dif_probability_0_100, 5),
      llm_precision_at_10 =
        precision_at_k(d$dif_label_cluster, d$threshold_dif_probability_0_100, 10),
      keyword_average_precision =
        average_precision(d$dif_label_cluster, d$keyword_score_0_100),
      keyword_precision_at_5 =
        precision_at_k(d$dif_label_cluster, d$keyword_score_0_100, 5),
      keyword_precision_at_10 =
        precision_at_k(d$dif_label_cluster, d$keyword_score_0_100, 10),
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

  joined_csv <- file.path(out_dir, paste0("maps_llm_gemini_sensitivity_eval_joined_cluster_robust_", mode, ".csv"))
  metrics_csv <- file.path(out_dir, paste0("maps_llm_gemini_sensitivity_eval_metrics_cluster_robust_", mode, ".csv"))
  write.csv(joined, joined_csv, row.names = FALSE)
  write.csv(metrics, metrics_csv, row.names = FALSE)

  message("Saved: ", joined_csv)
  message("Saved: ", metrics_csv)
  print(metrics)
}

message("Saved: ", robust_csv)
message("Saved: ", summary_csv)
message("Saved: ", comparison_csv)
print(table(label_comparison$label_change, useNA = "ifany"))
print(summary(out$se_ratio_cluster_to_model))
