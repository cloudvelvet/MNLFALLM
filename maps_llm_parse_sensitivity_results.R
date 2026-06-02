# Parse Gemini prompt-sensitivity JSONL results into a flat CSV.
#
# Usage:
#   Rscript maps_llm_parse_sensitivity_results.R
#
# Output:
#   llm_dif_output/maps_llm_gemini_sensitivity_predictions_flat.csv

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Package 'dplyr' is required.")
}
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  stop("Package 'jsonlite' is required.")
}

library(dplyr)
library(jsonlite)

`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0L) y else x
}

out_dir <- "llm_dif_output"
files <- list.files(
  out_dir,
  pattern = "^maps_llm_gemini_sensitivity_.*[.]jsonl$",
  full.names = TRUE
)
if (length(files) == 0L) {
  stop("No Gemini sensitivity result JSONL files found.")
}

message("Parsing Gemini sensitivity result files:")
message(paste(" -", files, collapse = "\n"))

read_records <- function(path) {
  rows <- readLines(path, encoding = "UTF-8", warn = FALSE)
  rows <- rows[nzchar(rows)]
  lapply(rows, function(line) {
    rec <- fromJSON(line, simplifyVector = FALSE)
    rec$result_file <- basename(path)
    rec
  })
}

records <- unlist(lapply(files, read_records), recursive = FALSE)

flat <- list()
idx <- 1L
for (rec in records) {
  if (!is.null(rec$error) || is.null(rec$content)) {
    flat[[idx]] <- data.frame(
      custom_id = rec$custom_id %||% NA_character_,
      prompt_version = rec$prompt_version %||% NA_character_,
      item_order = as.integer(rec$item_order %||% NA_integer_),
      respondent_type = rec$respondent_type %||% NA_character_,
      model = rec$model %||% NA_character_,
      scale_id = rec$scale_id %||% NA_character_,
      item_id = rec$item_id %||% NA_character_,
      covariate = NA_character_,
      threshold_dif_probability_0_100 = NA_real_,
      expected_direction = NA_character_,
      confidence_0_100 = NA_real_,
      rationale = NA_character_,
      parse_status = paste0("api_error: ", rec$message %||% rec$error %||% "unknown"),
      result_file = rec$result_file %||% NA_character_,
      stringsAsFactors = FALSE
    )
    idx <- idx + 1L
    next
  }

  parsed <- tryCatch(fromJSON(rec$content, simplifyVector = FALSE),
                     error = function(e) e)
  if (inherits(parsed, "error") || is.null(parsed$predictions)) {
    flat[[idx]] <- data.frame(
      custom_id = rec$custom_id %||% NA_character_,
      prompt_version = rec$prompt_version %||% NA_character_,
      item_order = as.integer(rec$item_order %||% NA_integer_),
      respondent_type = rec$respondent_type %||% NA_character_,
      model = rec$model %||% NA_character_,
      scale_id = rec$scale_id %||% NA_character_,
      item_id = rec$item_id %||% NA_character_,
      covariate = NA_character_,
      threshold_dif_probability_0_100 = NA_real_,
      expected_direction = NA_character_,
      confidence_0_100 = NA_real_,
      rationale = NA_character_,
      parse_status = "json_parse_error",
      result_file = rec$result_file %||% NA_character_,
      stringsAsFactors = FALSE
    )
    idx <- idx + 1L
    next
  }

  for (pred in parsed$predictions) {
    flat[[idx]] <- data.frame(
      custom_id = rec$custom_id %||% NA_character_,
      prompt_version = rec$prompt_version %||% NA_character_,
      item_order = as.integer(rec$item_order %||% NA_integer_),
      respondent_type = rec$respondent_type %||% NA_character_,
      model = rec$model %||% NA_character_,
      scale_id = parsed$scale_id %||% rec$scale_id %||% NA_character_,
      item_id = parsed$item_id %||% rec$item_id %||% NA_character_,
      covariate = pred$covariate %||% NA_character_,
      threshold_dif_probability_0_100 =
        as.numeric(pred$threshold_dif_probability_0_100 %||% NA_real_),
      expected_direction = pred$expected_direction %||% NA_character_,
      confidence_0_100 = as.numeric(pred$confidence_0_100 %||% NA_real_),
      rationale = pred$rationale %||% NA_character_,
      parse_status = "ok",
      result_file = rec$result_file %||% NA_character_,
      stringsAsFactors = FALSE
    )
    idx <- idx + 1L
  }
}

out <- bind_rows(flat)
out <- out %>%
  arrange(prompt_version, item_order, covariate)

out_path <- file.path(out_dir, "maps_llm_gemini_sensitivity_predictions_flat.csv")
write.csv(out, out_path, row.names = FALSE)
message("Saved: ", out_path)
print(table(out$prompt_version, out$parse_status, useNA = "ifany"))
