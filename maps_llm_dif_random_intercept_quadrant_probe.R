# Targeted random-intercept ordinal DIF probes for LLM/keyword quadrant cases.
#
# This is not a full MNLFA or final DIF validation. It is a focal empirical
# triangulation layer for selected item-covariate combinations:
#   resp_model ~ theta_proxy + covariate_value + wave + (1 | person_id)
#
# Outputs:
#   llm_dif_output/maps_dif_random_intercept_quadrant_probe.csv
#   llm_dif_output/maps_dif_random_intercept_quadrant_probe_summary.csv

for (pkg in c("dplyr", "ordinal")) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop("Package '", pkg, "' is required.")
  }
}

library(dplyr)

out_dir <- "llm_dif_output"

dat <- read.csv(file.path(out_dir, "maps_multiscale_long.csv"), stringsAsFactors = FALSE)
joined <- read.csv(file.path(out_dir, "maps_llm_gemini_sensitivity_eval_joined_binary_keyword.csv"),
                   stringsAsFactors = FALSE)
cluster <- read.csv(file.path(out_dir, "maps_llm_gemini_sensitivity_eval_joined_cluster_robust_full.csv"),
                    stringsAsFactors = FALSE)

as_bool <- function(x) {
  tolower(as.character(x)) %in% c("true", "t", "1", "yes")
}

cluster_small <- cluster %>%
  transmute(
    prompt_version, respondent_type, scale_id, item_id, covariate,
    beta_cluster = beta,
    p_fdr_cluster = p_fdr_cluster,
    dif_label_cluster = as_bool(dif_label_cluster)
  )

frame <- joined %>%
  filter(parse_status == "ok") %>%
  left_join(cluster_small,
            by = c("prompt_version", "respondent_type", "scale_id", "item_id", "covariate")) %>%
  mutate(
    llm_score = threshold_dif_probability_0_100,
    keyword_high = as_bool(keyword_hit) | keyword_score_0_100 >= 100,
    dif_label_main = as_bool(dif_label),
    quadrant = case_when(
      llm_score >= 70 & !keyword_high ~ "LLM-high / keyword-low",
      llm_score <= 30 & keyword_high ~ "keyword-high / LLM-low",
      llm_score >= 70 & keyword_high ~ "both-high",
      llm_score <= 30 & !keyword_high ~ "both-low",
      TRUE ~ "middle"
    )
  ) %>%
  filter(quadrant != "middle")

# Pick a very small but balanced focal sample to keep ordinal mixed models tractable.
# The ordering is deterministic and favors empirically informative/extreme cases.
selected <- frame %>%
  group_by(prompt_version, quadrant) %>%
  arrange(
    case_when(
      quadrant == "both-high" ~ p_fdr_cluster,
      quadrant == "keyword-high / LLM-low" ~ p_fdr_cluster,
      quadrant == "LLM-high / keyword-low" ~ desc(llm_score),
      quadrant == "both-low" ~ llm_score,
      TRUE ~ p_fdr_cluster
    ),
    .by_group = TRUE
  ) %>%
  slice_head(n = 1) %>%
  ungroup() %>%
  distinct(prompt_version, quadrant, respondent_type, scale_id, item_id, covariate,
           .keep_all = TRUE)

reverse_key_candidates <- c(
  "p_esteem_03", "p_esteem_05", "p_esteem_08", "p_esteem_09",
  "p_efficacy_08",
  "parenting_b01", "parenting_b02", "parenting_b03", "parenting_b04",
  "parenting_b05"
)

dat <- dat %>%
  group_by(scale_id) %>%
  mutate(
    max_resp_scale = max(resp, na.rm = TRUE),
    resp_model = ifelse(item_stem %in% reverse_key_candidates,
                        max_resp_scale + 1 - resp, resp)
  ) %>%
  ungroup() %>%
  group_by(respondent_type, scale_id, person_id, wave) %>%
  mutate(
    scale_n = sum(!is.na(resp_model)),
    scale_sum = sum(resp_model, na.rm = TRUE),
    theta_proxy = ifelse(scale_n > 1, (scale_sum - resp_model) / (scale_n - 1), NA_real_)
  ) %>%
  ungroup()

fit_one <- function(row) {
  covariate <- row$covariate
  d <- dat %>%
    filter(
      respondent_type == row$respondent_type,
      scale_id == row$scale_id,
      item_id == row$item_id
    ) %>%
    dplyr::select(resp_model, theta_proxy, wave, person_id,
                  covariate_value = all_of(covariate)) %>%
    filter(stats::complete.cases(.))

  # clmm can be slow in the full pooled panel. For focal triangulation, use a
  # deterministic cluster subsample when a case has many respondents.
  set.seed(20260531)
  unique_persons <- unique(d$person_id)
  if (length(unique_persons) > 400) {
    keep_persons <- sample(unique_persons, 400)
    d <- d %>% filter(person_id %in% keep_persons)
  }

  if (nrow(d) < 200 ||
      length(unique(d$resp_model)) < 3 ||
      length(unique(d$covariate_value)) < 2 ||
      stats::sd(d$covariate_value, na.rm = TRUE) == 0 ||
      length(unique(d$wave)) < 2 ||
      length(unique(d$person_id)) < 30) {
    return(data.frame(
      beta_ri = NA_real_, se_ri = NA_real_, z_ri = NA_real_, p_ri = NA_real_,
      random_intercept_sd = NA_real_, n_ri = nrow(d),
      clusters_ri = length(unique(d$person_id)),
      elapsed_sec = NA_real_,
      status_ri = "skipped_insufficient_data"
    ))
  }

  d$resp_model <- as.ordered(d$resp_model)
  d$wave <- factor(d$wave)
  d$person_id <- factor(d$person_id)

  start_time <- Sys.time()
  fit <- tryCatch(
    suppressWarnings(ordinal::clmm(
      resp_model ~ theta_proxy + covariate_value + wave + (1 | person_id),
      data = d,
      link = "logit",
      Hess = TRUE,
      nAGQ = 1L,
      control = ordinal::clmm.control(maxIter = 25, gradTol = 1e-3)
    )),
    error = function(e) e
  )
  elapsed_sec <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

  if (inherits(fit, "error")) {
    return(data.frame(
      beta_ri = NA_real_, se_ri = NA_real_, z_ri = NA_real_, p_ri = NA_real_,
      random_intercept_sd = NA_real_, n_ri = nrow(d),
      clusters_ri = length(unique(d$person_id)),
      elapsed_sec = elapsed_sec,
      status_ri = paste0("error: ", fit$message)
    ))
  }

  sm <- summary(fit)
  coefs <- sm$coefficients
  if (!"covariate_value" %in% rownames(coefs)) {
    return(data.frame(
      beta_ri = NA_real_, se_ri = NA_real_, z_ri = NA_real_, p_ri = NA_real_,
      random_intercept_sd = NA_real_, n_ri = nrow(d),
      clusters_ri = length(unique(d$person_id)),
      elapsed_sec = elapsed_sec,
      status_ri = "missing_covariate_coefficient"
    ))
  }

  beta <- unname(coefs["covariate_value", "Estimate"])
  se <- unname(coefs["covariate_value", "Std. Error"])
  z <- beta / se
  p <- 2 * stats::pnorm(abs(z), lower.tail = FALSE)
  ri_sd <- tryCatch(as.numeric(ordinal::VarCorr(fit)$person_id[1, 2]), error = function(e) NA_real_)

  data.frame(
    beta_ri = beta,
    se_ri = se,
    z_ri = z,
    p_ri = p,
    random_intercept_sd = ri_sd,
    n_ri = nrow(d),
    clusters_ri = length(unique(d$person_id)),
    elapsed_sec = elapsed_sec,
    status_ri = "ok"
  )
}

rows <- list()
out_csv <- file.path(out_dir, "maps_dif_random_intercept_quadrant_probe.csv")
for (i in seq_len(nrow(selected))) {
  message("Fitting RI quadrant probe ", i, "/", nrow(selected), ": ",
          selected$prompt_version[i], " | ", selected$quadrant[i], " | ",
          selected$item_id[i], " x ", selected$covariate[i])
  rows[[i]] <- cbind(selected[i, ], fit_one(selected[i, ]))
  partial <- bind_rows(rows)
  write.csv(partial, out_csv, row.names = FALSE)
}

out <- bind_rows(rows)
out$p_fdr_ri <- NA_real_
ok <- out$status_ri == "ok" & !is.na(out$p_ri)
out$p_fdr_ri[ok] <- p.adjust(out$p_ri[ok], method = "BH")
out$dif_label_ri <- ok & out$p_fdr_ri < 0.05 & abs(out$beta_ri) >= 0.20
out$sign_agree_cluster_ri <- ok & !is.na(out$beta_cluster) & sign(out$beta_cluster) == sign(out$beta_ri)
out$label_agree_cluster_ri <- ok & !is.na(out$dif_label_cluster) & out$dif_label_cluster == out$dif_label_ri

write.csv(out, out_csv, row.names = FALSE)
message("Saved: ", out_csv)

summary_out <- out %>%
  group_by(prompt_version, quadrant) %>%
  summarise(
    n_cases = n(),
    ok_cases = sum(status_ri == "ok", na.rm = TRUE),
    cluster_positive = sum(dif_label_cluster %in% TRUE, na.rm = TRUE),
    ri_positive = sum(dif_label_ri %in% TRUE, na.rm = TRUE),
    sign_agree_rate = mean(sign_agree_cluster_ri %in% TRUE, na.rm = TRUE),
    label_agree_rate = mean(label_agree_cluster_ri %in% TRUE, na.rm = TRUE),
    median_elapsed_sec = median(elapsed_sec, na.rm = TRUE),
    .groups = "drop"
  )

summary_csv <- file.path(out_dir, "maps_dif_random_intercept_quadrant_probe_summary.csv")
write.csv(summary_out, summary_csv, row.names = FALSE)
message("Saved: ", summary_csv)

print(out[, c("prompt_version", "quadrant", "item_id", "covariate", "llm_score",
              "keyword_high", "dif_label_cluster", "beta_cluster",
              "p_fdr_cluster", "beta_ri", "p_fdr_ri", "dif_label_ri",
              "sign_agree_cluster_ri", "label_agree_cluster_ri",
              "elapsed_sec", "status_ri")])
