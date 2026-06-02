# Binary lexical baseline for MAPS LLM-DIF sensitivity analyses.
#
# This version removes covariate-specific weights. A pair receives 100 when the
# item text contains at least one predefined keyword for the covariate, and 0
# otherwise. Existing weighted keyword files are not overwritten.

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Package 'dplyr' is required.")
}

library(dplyr)

out_dir <- "llm_dif_output"
pairs_csv <- file.path(out_dir, "maps_llm_full_item_covariate_pairs.csv")

if (!file.exists(pairs_csv)) {
  stop("Missing input file: ", pairs_csv)
}

pairs <- read.csv(pairs_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")

keywords <- list(
  discrim_any = c("다른 대우", "편견", "무시", "위축", "사회적 지위", "따돌",
                  "못살게", "외국", "욕", "놀림", "소문"),
  korean_c = c("한국어", "한국문화", "한국 사람", "한국사람", "한국에",
               "한국의", "모국", "외국", "문화", "언어"),
  income_c = c("경제", "형편", "물건", "장소", "제공", "대학", "회사",
               "지위", "건강", "병원"),
  gender = c("외모", "이성친구", "신체적 특징", "친구", "따돌림", "소문",
             "욕설", "놀림"),
  age_c = c("진학", "진로", "미래", "부모역할", "자녀", "아이", "대학",
            "회사", "체류", "비자")
)

has_any <- function(text, words) {
  text <- ifelse(is.na(text), "", text)
  vapply(text, function(one) {
    any(vapply(words, function(w) grepl(w, one, fixed = TRUE), logical(1)))
  }, logical(1))
}

score_one <- function(text, covariate) {
  if (!covariate %in% names(keywords)) {
    return(rep(0, length(text)))
  }
  as.integer(has_any(text, keywords[[covariate]])) * 100
}

pred <- pairs %>%
  rowwise() %>%
  mutate(
    keyword_hit = score_one(item_text, covariate) > 0,
    keyword_score_0_100 = ifelse(keyword_hit, 100, 0)
  ) %>%
  ungroup()

write.csv(
  pred,
  file.path(out_dir, "maps_keyword_binary_baseline_predictions.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

hit_summary <- pred %>%
  group_by(covariate) %>%
  summarise(
    n_pairs = n(),
    keyword_hits = sum(keyword_hit),
    hit_rate = mean(keyword_hit),
    .groups = "drop"
  )

write.csv(
  hit_summary,
  file.path(out_dir, "maps_keyword_binary_baseline_hit_summary.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

message("Saved binary keyword baseline predictions.")
print(hit_summary)
