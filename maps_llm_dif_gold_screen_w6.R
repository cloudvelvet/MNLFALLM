# Single-wave ordinal DIF screening for MAPS wave 6.
#
# This script creates provisional DIF labels for evaluating already-generated
# LLM item-covariate hypotheses. It is not a final DIF or MNLFA analysis.
#
# Output:
#   llm_dif_output/maps_dif_screening_gold_w6.csv
#   llm_dif_output/maps_dif_screening_gold_summary_w6.csv

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Package 'dplyr' is required.")
}
if (!requireNamespace("MASS", quietly = TRUE)) {
  stop("Package 'MASS' is required.")
}

library(dplyr)

out_dir <- "llm_dif_output"
in_csv <- file.path(out_dir, "maps_multiscale_long_w6.csv")
if (!file.exists(in_csv)) {
  stop("Missing ", in_csv, ". Run maps_multiscale_llm_prep_w6.py first.")
}

message("Reading: ", in_csv)
dat <- read.csv(in_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM")

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
  needed <- c("resp_model", "theta_proxy", covariate)
  d <- d[stats::complete.cases(d[, needed]), needed, drop = FALSE]
  names(d)[names(d) == covariate] <- "covariate_value"

  if (nrow(d) < 200 ||
      length(unique(d$resp_model)) < 3 ||
      length(unique(d$covariate_value)) < 2 ||
      stats::sd(d$covariate_value, na.rm = TRUE) == 0) {
    return(data.frame(
      beta = NA_real_, se = NA_real_, z = NA_real_, p = NA_real_,
      n = nrow(d), categories = length(unique(d$resp_model)),
      status = "skipped_insufficient_data"
    ))
  }

  d$resp_model <- as.ordered(d$resp_model)

  fit <- tryCatch(
    suppressWarnings(MASS::polr(
      resp_model ~ theta_proxy + covariate_value,
      data = d,
      method = "logistic",
      Hess = TRUE
    )),
    error = function(e) e
  )

  if (inherits(fit, "error")) {
    return(data.frame(
      beta = NA_real_, se = NA_real_, z = NA_real_, p = NA_real_,
      n = nrow(d), categories = length(unique(d$resp_model)),
      status = paste0("error: ", fit$message)
    ))
  }

  coefs <- coef(summary(fit))
  if (!"covariate_value" %in% rownames(coefs)) {
    return(data.frame(
      beta = NA_real_, se = NA_real_, z = NA_real_, p = NA_real_,
      n = nrow(d), categories = length(unique(d$resp_model)),
      status = "missing_covariate_coefficient"
    ))
  }

  beta <- unname(coefs["covariate_value", "Value"])
  se <- unname(coefs["covariate_value", "Std. Error"])
  z <- beta / se
  p <- 2 * stats::pnorm(abs(z), lower.tail = FALSE)

  data.frame(
    beta = beta,
    se = se,
    z = z,
    p = p,
    n = nrow(d),
    categories = length(unique(d$resp_model)),
    status = "ok"
  )
}

groups <- dat %>%
  distinct(respondent_type, scale_id, scale_name, item_id, item_stem) %>%
  arrange(respondent_type, scale_id, item_stem)

message("Fitting wave-6 screening DIF models: ", nrow(groups), " items")

rows <- list()
idx <- 1L
for (i in seq_len(nrow(groups))) {
  g <- groups[i, ]
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
        model = "single_wave6_uniform_ordinal_logit_item_on_keyed_theta_proxy_covariate",
        dif_type = "uniform_threshold_proxy_w6",
        stringsAsFactors = FALSE
      ),
      res
    )
    idx <- idx + 1L
  }
}

out <- bind_rows(rows)
out$p_fdr <- NA_real_
ok <- out$status == "ok" & !is.na(out$p)
out$p_fdr[ok] <- p.adjust(out$p[ok], method = "BH")
out$practical_nonzero <- ok & abs(out$beta) >= 0.20
out$dif_label <- ok & out$p_fdr < 0.05 & out$practical_nonzero
out$direction <- ifelse(is.na(out$beta), NA_character_,
                        ifelse(out$beta > 0, "positive", "negative"))

out_csv <- file.path(out_dir, "maps_dif_screening_gold_w6.csv")
write.csv(out, out_csv, row.names = FALSE)

summary <- out %>%
  group_by(respondent_type, scale_id, covariate) %>%
  summarise(
    tests = n(),
    ok = sum(status == "ok"),
    dif_positive = sum(dif_label, na.rm = TRUE),
    mean_abs_beta = mean(abs(beta), na.rm = TRUE),
    .groups = "drop"
  )

summary_csv <- file.path(out_dir, "maps_dif_screening_gold_summary_w6.csv")
write.csv(summary, summary_csv, row.names = FALSE)

message("Saved: ", out_csv)
message("Saved: ", summary_csv)
print(summary)
