# Rule-based rationale coding for full Gemini sensitivity outputs.
#
# Usage:
#   Rscript maps_llm_sensitivity_rationale_coding.R
#
# Inputs:
#   llm_dif_output/maps_llm_gemini_sensitivity_eval_joined.csv
#
# Outputs:
#   llm_dif_output/maps_llm_sensitivity_rationale_code_flags.csv
#   llm_dif_output/maps_llm_sensitivity_rationale_code_summary.csv
#   llm_dif_output/maps_llm_sensitivity_rationale_outcome_summary.csv

out_dir <- "llm_dif_output"
joined_csv <- file.path(out_dir, "maps_llm_gemini_sensitivity_eval_joined.csv")

if (!file.exists(joined_csv)) {
  stop("Missing sensitivity joined evaluation file: ", joined_csv,
       ". Run maps_llm_parse_sensitivity_results.R and maps_llm_eval_sensitivity.R first.")
}

joined <- read.csv(joined_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")

contains <- function(x, pattern) {
  grepl(pattern, x, ignore.case = TRUE, perl = TRUE)
}

num <- function(x) suppressWarnings(as.numeric(x))

joined$valid_label <- !(is.na(joined$dif_label) | joined$dif_label == "")
joined$label <- joined$dif_label == "TRUE" | joined$dif_label == TRUE
joined$llm_score <- num(joined$threshold_dif_probability_0_100)
joined$keyword_score <- num(joined$keyword_score_0_100)

r <- ifelse(is.na(joined$rationale), "", joined$rationale)
has_same_latent <- contains(r, "same latent|at the same|given.*latent|controlling for|conditioned on")
has_threshold <- contains(
  r,
  "threshold|endorse|endorsement|response|respond|report|interpret|perceiv|salien|articulat|express|reference group|social desirability"
)
has_direction_words <- contains(
  r,
  "lower|higher|easier|harder|more likely|less likely|raise|shift|increase|decrease|underreport|overreport"
)

codes <- joined
codes$code_WORDING <- contains(
  r,
  "wording|phrase|term|language|straightforward|interpretation of|specific wording|nuance|meaning"
)
codes$code_RESPONSE_PROCESS <- has_threshold
codes$code_CULTURE_LANGUAGE_CONTEXT <- contains(
  r,
  "Korean|language|communication|culture|foreign|home country|Korea|acculturation|linguistic|bicultural"
)
codes$code_COVARIATE_MECHANISM <- contains(
  r,
  "discrimination|prejudice|Korean proficiency|income|socioeconomic|gender|age|older|younger|developmental"
)
codes$code_CONSTRUCT_RELEVANCE <- contains(
  r,
  "latent|construct|true level|actual experience|overall level|actual feelings|actual level"
)
codes$code_DIRECTIONAL_HYPOTHESIS <- codes$expected_direction != "unclear" & has_direction_words
codes$code_TESTABLE_HYPOTHESIS <- has_same_latent | contains(r, "DIF|differential|response threshold")
codes$code_ALTERNATIVE_EXPLANATION <- contains(
  r,
  "rather than|more likely to influence|true level|latent construct difference|not a differential|not directly|impact"
)

codes$code_IMPACT_DIF_CONFUSION <- codes$llm_score >= 50 & contains(
  r,
  "actual experience|true level|overall level|directly impacts|directly contribute|resources that can|access to|opportunities|actual communication difficulties|genuinely harder|true construct"
)
codes$code_NO_WITHIN_TRAIT_CONDITIONING <- codes$llm_score >= 50 & !has_same_latent
codes$code_STEREOTYPE_GENDER_AGE <- codes$covariate %in% c("gender", "age_c") &
  codes$llm_score >= 50 & contains(
    r,
    "gendered|gender differences|societal gender|female|male|girls|boys|older|younger|age-related|developmental|adolescents"
  )
codes$code_VAGUE_GENERALITY <- contains(
  r,
  "may influence|could lead|might subtly|general demographic|not clear|potentially|may make|could make"
)
codes$code_ITEM_IRRELEVANT_SPECULATION <- codes$llm_score >= 50 & contains(
  r,
  "general resource|general risk factor|general demographic|societal norms|opportunities|overall life satisfaction|broad|general social"
)
codes$code_DIRECTION_UNSUPPORTED <- codes$expected_direction != "unclear" & !has_direction_words
codes$code_OVERCLAIM_DIF <- contains(r, "definitely|certainly|clear DIF|obvious DIF|must be DIF")
codes$code_UNFAIR_ATTRIBUTION <- contains(r, "irrational|inferior|ignorant|incapable")

codes$outcome_70 <- ifelse(
  !codes$valid_label, "missing_label",
  ifelse(codes$llm_score >= 70 & codes$label, "TP70",
         ifelse(codes$llm_score >= 70 & !codes$label, "FP70",
                ifelse(codes$llm_score < 70 & codes$label, "FN70", "TN70")))
)
codes$outcome_50 <- ifelse(
  !codes$valid_label, "missing_label",
  ifelse(codes$llm_score >= 50 & codes$label, "TP50",
         ifelse(codes$llm_score >= 50 & !codes$label, "FP50",
                ifelse(codes$llm_score < 50 & codes$label, "FN50", "TN50")))
)

code_cols <- grep("^code_", names(codes), value = TRUE)

summarize_codes <- function(d, group_vars = c("prompt_version")) {
  rows <- list()
  idx <- 1L
  split_key <- interaction(d[group_vars], drop = TRUE, sep = " | ")
  for (key in levels(split_key)) {
    subset_key <- split_key == key
    parts <- strsplit(as.character(key), " \\| ", perl = TRUE)[[1]]
    group_values <- as.list(parts)
    names(group_values) <- group_vars
    for (cc in code_cols) {
      flag <- d[[cc]]
      valid <- subset_key & d$valid_label
      base <- data.frame(
        code = sub("^code_", "", cc),
        n = sum(valid),
        flagged = sum(flag & valid, na.rm = TRUE),
        rate = ifelse(sum(valid) == 0, NA_real_, mean(flag[valid], na.rm = TRUE)),
        stringsAsFactors = FALSE
      )
      rows[[idx]] <- cbind(as.data.frame(group_values, stringsAsFactors = FALSE), base)
      idx <- idx + 1L
    }
  }
  do.call(rbind, rows)
}

summary_prompt <- summarize_codes(codes, c("prompt_version"))
summary_prompt_cov <- summarize_codes(codes, c("prompt_version", "covariate"))

outcome_rows <- list()
idx <- 1L
for (pv in sort(unique(codes$prompt_version))) {
  for (outcome_col in c("outcome_50", "outcome_70")) {
    for (og in sort(unique(codes[[outcome_col]]))) {
      subset <- codes$prompt_version == pv & codes[[outcome_col]] == og & codes$valid_label
      for (cc in code_cols) {
        flag <- codes[[cc]]
        outcome_rows[[idx]] <- data.frame(
          prompt_version = pv,
          cutoff = sub("^outcome_", "", outcome_col),
          outcome = og,
          code = sub("^code_", "", cc),
          n = sum(subset),
          flagged = sum(flag & subset, na.rm = TRUE),
          rate = ifelse(sum(subset) == 0, NA_real_, mean(flag[subset], na.rm = TRUE)),
          stringsAsFactors = FALSE
        )
        idx <- idx + 1L
      }
    }
  }
}
outcome_summary <- do.call(rbind, outcome_rows)

summary_prompt$covariate <- NA_character_
summary_prompt <- summary_prompt[, c("prompt_version", "covariate", "code", "n",
                                     "flagged", "rate")]
summary_prompt_cov <- summary_prompt_cov[, c("prompt_version", "covariate", "code",
                                             "n", "flagged", "rate")]

summary_all <- rbind(
  cbind(level = "prompt", summary_prompt),
  cbind(level = "prompt_covariate", summary_prompt_cov)
)

write.csv(codes,
          file.path(out_dir, "maps_llm_sensitivity_rationale_code_flags.csv"),
          row.names = FALSE)
write.csv(summary_all,
          file.path(out_dir, "maps_llm_sensitivity_rationale_code_summary.csv"),
          row.names = FALSE)
write.csv(outcome_summary,
          file.path(out_dir, "maps_llm_sensitivity_rationale_outcome_summary.csv"),
          row.names = FALSE)

cat("Saved full sensitivity rationale coding outputs.\n")
cat("Rows coded:", nrow(codes), "\n")
print(summary_prompt[summary_prompt$code %in% c(
  "IMPACT_DIF_CONFUSION",
  "NO_WITHIN_TRAIT_CONDITIONING",
  "STEREOTYPE_GENDER_AGE",
  "RESPONSE_PROCESS",
  "TESTABLE_HYPOTHESIS"
), ])
