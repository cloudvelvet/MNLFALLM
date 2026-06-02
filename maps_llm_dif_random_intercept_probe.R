# Probe random-intercept ordinal DIF models for selected item-covariate pairs.
#
# This is a feasibility and sensitivity probe, not the main full screening.
# It fits ordinal::clmm with a respondent random intercept:
#   resp_model ~ theta_proxy + covariate_value + wave + (1 | person_id)
#
# Outputs:
#   llm_dif_output/maps_dif_random_intercept_probe.csv

for (pkg in c("dplyr", "ordinal")) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop("Package '", pkg, "' is required.")
  }
}

library(dplyr)

out_dir <- "llm_dif_output"
dat <- read.csv(file.path(out_dir, "maps_multiscale_long.csv"), stringsAsFactors = FALSE)
comparison <- read.csv(file.path(out_dir, "maps_cluster_robust_label_comparison_full.csv"),
                       stringsAsFactors = FALSE)

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

selected <- bind_rows(
  comparison %>%
    filter(label_change == "main_only") %>%
    arrange(p_fdr_cluster) %>%
    head(10),
  comparison %>%
    filter(label_change == "positive_both") %>%
    arrange(p_fdr_cluster) %>%
    head(10)
) %>%
  distinct(respondent_type, scale_id, item_id, item_stem, covariate, .keep_all = TRUE)

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

  if (nrow(d) < 200 ||
      length(unique(d$resp_model)) < 3 ||
      length(unique(d$covariate_value)) < 2 ||
      stats::sd(d$covariate_value, na.rm = TRUE) == 0 ||
      length(unique(d$wave)) < 2 ||
      length(unique(d$person_id)) < 30) {
    return(data.frame(
      beta_ri = NA_real_, se_ri = NA_real_, z_ri = NA_real_, p_ri = NA_real_,
      random_intercept_sd = NA_real_, n = nrow(d),
      clusters = length(unique(d$person_id)),
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
      control = ordinal::clmm.control(maxIter = 60, gradTol = 1e-4)
    )),
    error = function(e) e
  )
  elapsed_sec <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

  if (inherits(fit, "error")) {
    return(data.frame(
      beta_ri = NA_real_, se_ri = NA_real_, z_ri = NA_real_, p_ri = NA_real_,
      random_intercept_sd = NA_real_, n = nrow(d),
      clusters = length(unique(d$person_id)),
      elapsed_sec = elapsed_sec,
      status_ri = paste0("error: ", fit$message)
    ))
  }

  sm <- summary(fit)
  coefs <- sm$coefficients
  if (!"covariate_value" %in% rownames(coefs)) {
    return(data.frame(
      beta_ri = NA_real_, se_ri = NA_real_, z_ri = NA_real_, p_ri = NA_real_,
      random_intercept_sd = NA_real_, n = nrow(d),
      clusters = length(unique(d$person_id)),
      elapsed_sec = elapsed_sec,
      status_ri = "missing_covariate_coefficient"
    ))
  }

  beta <- unname(coefs["covariate_value", "Estimate"])
  se <- unname(coefs["covariate_value", "Std. Error"])
  z <- beta / se
  p <- 2 * stats::pnorm(abs(z), lower.tail = FALSE)
  ri_sd <- tryCatch(as.numeric(VarCorr(fit)$person_id[1, 2]), error = function(e) NA_real_)

  data.frame(
    beta_ri = beta,
    se_ri = se,
    z_ri = z,
    p_ri = p,
    random_intercept_sd = ri_sd,
    n = nrow(d),
    clusters = length(unique(d$person_id)),
    elapsed_sec = elapsed_sec,
    status_ri = "ok"
  )
}

rows <- list()
for (i in seq_len(nrow(selected))) {
  message("Fitting RI probe ", i, "/", nrow(selected), ": ",
          selected$item_id[i], " x ", selected$covariate[i])
  rows[[i]] <- cbind(selected[i, ], fit_one(selected[i, ]))
}

out <- bind_rows(rows)
out$p_fdr_ri <- NA_real_
ok <- out$status_ri == "ok" & !is.na(out$p_ri)
out$p_fdr_ri[ok] <- p.adjust(out$p_ri[ok], method = "BH")
out$dif_label_ri <- ok & out$p_fdr_ri < 0.05 & abs(out$beta_ri) >= 0.20

out_csv <- file.path(out_dir, "maps_dif_random_intercept_probe.csv")
write.csv(out, out_csv, row.names = FALSE)
message("Saved: ", out_csv)
print(out[, c("item_id", "covariate", "label_change", "beta_main",
              "p_fdr_main", "p_fdr_cluster", "beta_ri", "p_fdr_ri",
              "dif_label_ri", "elapsed_sec", "status_ri")])
