# Build a MAPS multi-scale item pool for LLM-assisted DIF screening.
#
# This script creates a long-format item response file across selected parent
# and youth MAPS scales. It is intentionally a broad screening dataset, not a
# final longitudinal MNLFA analysis file.
#
# Outputs:
#   llm_dif_output/maps_multiscale_long.csv
#   llm_dif_output/maps_llm_item_catalog.csv
#   llm_dif_output/maps_llm_prediction_template.csv

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Package 'dplyr' is required.")
}

library(dplyr)

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0 || is.na(x)) y else x

source_root <- "MAPS 2기 패널_Data_CSV (1)"
parent_dir <- file.path(source_root, "학부모(1~6차)")
youth_dir <- file.path(source_root, "청소년(1~6차)")
out_dir <- "llm_dif_output"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

valid_ord <- function(x) {
  x <- suppressWarnings(as.numeric(x))
  x[!(x %in% 1:5)] <- NA_real_
  x
}

valid_positive <- function(x) {
  x <- suppressWarnings(as.numeric(x))
  x[x < 0] <- NA_real_
  x
}

valid_int <- function(x) {
  suppressWarnings(as.integer(x))
}

recode_yes_no <- function(x) {
  x <- suppressWarnings(as.integer(x))
  out <- rep(NA_integer_, length(x))
  out[x == 1] <- 1L
  out[x == 2] <- 0L
  out
}

first_existing <- function(dat, candidates, default = NA_real_) {
  hit <- candidates[candidates %in% names(dat)]
  if (length(hit) == 0) {
    rep(default, nrow(dat))
  } else {
    dat[[hit[1]]]
  }
}

row_mean_existing <- function(dat, candidates, clean = valid_ord) {
  hit <- candidates[candidates %in% names(dat)]
  if (length(hit) == 0) {
    return(rep(NA_real_, nrow(dat)))
  }
  mat <- as.data.frame(lapply(dat[hit], clean))
  out <- rowMeans(mat, na.rm = TRUE)
  out[is.nan(out)] <- NA_real_
  out
}

find_wave_file <- function(dir, respondent_label, wave) {
  file <- list.files(
    dir,
    pattern = paste0(respondent_label, " ", wave, "차년도[.]csv$"),
    full.names = TRUE
  )
  if (length(file) != 1) {
    stop("Could not find exactly one ", respondent_label, " CSV for wave ", wave)
  }
  file
}

scale_spec <- function(scale_id, scale_name, stems) {
  list(scale_id = scale_id, scale_name = scale_name, stems = stems)
}

parent_scales <- list(
  scale_spec("parent_acculturative_stress", "Parent acculturative stress",
             sprintf("p_accul_str_%02d", 1:8)),
  scale_spec("parent_self_esteem", "Parent self-esteem",
             sprintf("p_esteem_%02d", 1:9)),
  scale_spec("parent_parenting_efficacy", "Parenting efficacy",
             sprintf("p_efficacy_%02d", 1:9)),
  scale_spec("parent_acculturation", "Parent acculturation",
             sprintf("p_accul_%02d", 1:12))
)

youth_scales <- list(
  scale_spec("youth_acculturative_stress", "Youth acculturative stress",
             sprintf("s_accul_str_%02d", 1:9)),
  scale_spec("youth_bicultural_acceptance", "Bicultural acceptance",
             sprintf("biticul_acc_%02d", 1:10)),
  # s_worry_01 is only directly comparable in wave 1; waves 2-5 split it into
  # s_worry_01_1 and s_worry_01_2. Keep the stable repeated stems for screening.
  scale_spec("youth_worry", "Youth worry",
             sprintf("s_worry_%02d", 2:14)),
  scale_spec("youth_national_identity", "National identity",
             sprintf("s_national_iden_%02d", 1:4)),
  scale_spec("youth_life_satisfaction", "Life satisfaction",
             sprintf("life_satis_%02d", 1:3)),
  scale_spec("youth_parent_support", "Parent support",
             sprintf("p_support_a%02d", 1:6)),
  scale_spec("youth_parenting", "Parenting / parent relationship",
             c(sprintf("parenting_a%02d", 1:3), sprintf("parenting_b%02d", 1:7))),
  scale_spec("youth_friend_support", "Friend support",
             sprintf("fr_sup_%02d", 1:3)),
  scale_spec("youth_teacher_support", "Teacher support",
             sprintf("te_sup_%02d", 1:3)),
  scale_spec("youth_bullying", "Bullying victimization",
             sprintf("bullying_%02d", 1:6))
)

build_item_rows <- function(dat, base, scales, suffix) {
  rows <- list()
  idx <- 1L
  for (sc in scales) {
    for (stem in sc$stems) {
      col <- paste0(stem, suffix)
      if (!col %in% names(dat)) {
        next
      }
      resp <- valid_ord(dat[[col]])
      rows[[idx]] <- cbind(
        base,
        data.frame(
          scale_id = sc$scale_id,
          scale_name = sc$scale_name,
          item_stem = stem,
          item_variable = col,
          item_id = paste(sc$scale_id, stem, sep = "__"),
          item_text = NA_character_,
          item_text_status = "needs_user_guide_text",
          resp = resp,
          stringsAsFactors = FALSE
        )
      )
      idx <- idx + 1L
    }
  }
  if (length(rows) == 0) {
    return(NULL)
  }
  bind_rows(rows) %>% filter(!is.na(resp))
}

read_parent_wave <- function(wave) {
  file <- find_wave_file(parent_dir, "학부모", wave)
  dat <- read.csv(file, fileEncoding = "CP949", check.names = FALSE,
                  stringsAsFactors = FALSE)
  suffix <- paste0("_w", wave)

  parent_age <- valid_positive(first_existing(dat, paste0("par_age_1", suffix)))
  income <- valid_positive(first_existing(dat, paste0("income_a01", suffix)))
  korean <- row_mean_existing(dat, paste0("ko_language_c", 1:4, suffix))

  base <- data.frame(
    respondent_type = "parent",
    source_file = basename(file),
    ID = as.integer(dat$ID),
    person_id = paste0("parent_", dat$ID),
    wave = wave,
    age = parent_age,
    gender = NA_real_,
    nation = valid_int(first_existing(dat, paste0("par_nat_1", suffix))),
    education = valid_int(first_existing(dat, paste0("par_edu_1", suffix))),
    income = income,
    log_income = log(pmax(income, 1)),
    korean_score = korean,
    discrim_any = recode_yes_no(first_existing(dat, paste0("p_discrim_a01", suffix))),
    stringsAsFactors = FALSE
  )

  build_item_rows(dat, base, parent_scales, suffix)
}

read_youth_wave <- function(wave) {
  file <- find_wave_file(youth_dir, "청소년", wave)
  dat <- read.csv(file, fileEncoding = "CP949", check.names = FALSE,
                  stringsAsFactors = FALSE)
  suffix <- paste0("_w", wave)

  age <- valid_positive(first_existing(dat, paste0("S_AGE", suffix)))
  income <- valid_positive(first_existing(dat, paste0("income_a01", suffix)))
  korean <- row_mean_existing(dat, paste0("korean_ab_b0", 1:4, suffix))

  gender_raw <- valid_int(first_existing(dat, paste0("S_GENDER", suffix)))
  gender01 <- rep(NA_real_, length(gender_raw))
  gender01[gender_raw == 1] <- 0
  gender01[gender_raw == 2] <- 1

  base <- data.frame(
    respondent_type = "youth",
    source_file = basename(file),
    ID = as.integer(dat$ID),
    person_id = paste0("youth_", dat$ID),
    wave = wave,
    age = age,
    gender = gender01,
    nation = valid_int(first_existing(dat, paste0("par_nat_1", suffix))),
    education = valid_int(first_existing(dat, paste0("par_edu_1", suffix))),
    income = income,
    log_income = log(pmax(income, 1)),
    korean_score = korean,
    discrim_any = recode_yes_no(first_existing(dat, paste0("s_discrim_a01", suffix))),
    stringsAsFactors = FALSE
  )

  build_item_rows(dat, base, youth_scales, suffix)
}

message("Reading parent waves...")
parent_long <- bind_rows(lapply(1:5, read_parent_wave))
message("Reading youth waves...")
youth_long <- bind_rows(lapply(1:5, read_youth_wave))

longdat <- bind_rows(parent_long, youth_long) %>%
  group_by(respondent_type) %>%
  mutate(
    age_c = as.numeric(scale(age)),
    income_c = as.numeric(scale(log_income)),
    korean_c = as.numeric(scale(korean_score))
  ) %>%
  ungroup() %>%
  arrange(respondent_type, person_id, wave, scale_id, item_stem)

item_catalog <- longdat %>%
  distinct(respondent_type, scale_id, scale_name, item_stem, item_id,
           item_text, item_text_status) %>%
  arrange(respondent_type, scale_id, item_stem)

covariates <- data.frame(
  covariate = c("discrim_any", "korean_c", "income_c", "gender", "age_c"),
  covariate_label = c(
    "reported discrimination experience",
    "Korean proficiency",
    "household income",
    "youth gender",
    "age"
  ),
  applies_to = c("both", "both", "both", "youth", "both"),
  stringsAsFactors = FALSE
)

prediction_template <- merge(item_catalog, covariates, by = NULL) %>%
  filter(applies_to == "both" | respondent_type == applies_to) %>%
  arrange(respondent_type, scale_id, item_stem, covariate)

write.csv(longdat, file.path(out_dir, "maps_multiscale_long.csv"),
          row.names = FALSE)
write.csv(item_catalog, file.path(out_dir, "maps_llm_item_catalog.csv"),
          row.names = FALSE)
write.csv(prediction_template, file.path(out_dir, "maps_llm_prediction_template.csv"),
          row.names = FALSE)

qc <- longdat %>%
  group_by(respondent_type, scale_id, scale_name) %>%
  summarise(
    persons = n_distinct(person_id),
    waves = n_distinct(wave),
    items = n_distinct(item_id),
    rows = n(),
    missing_discrim_rows = sum(is.na(discrim_any)),
    missing_korean_rows = sum(is.na(korean_score)),
    missing_income_rows = sum(is.na(log_income)),
    .groups = "drop"
  )
write.csv(qc, file.path(out_dir, "maps_multiscale_qc.csv"),
          row.names = FALSE)

message("Saved outputs in: ", out_dir)
print(qc)
