# Parse Gemini pilot JSONL results into a flat CSV.
#
# Usage:
#   Rscript maps_llm_parse_gemini_results.R
#
# Output:
#   llm_dif_output/maps_llm_gemini_pilot_predictions_flat.csv

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Package 'dplyr' is required.")
}
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  stop("Package 'jsonlite' is required.")
}

library(dplyr)
library(jsonlite)

out_dir <- "llm_dif_output"
files <- list.files(
  out_dir,
  pattern = "^maps_llm_gemini_pilot_results_.*[.]jsonl$",
  full.names = TRUE
)
if (length(files) == 0) {
  stop("No Gemini pilot result JSONL files found.")
}

latest <- files[which.max(file.info(files)$mtime)]
message("Parsing latest Gemini result file: ", latest)

rows <- readLines(latest, encoding = "UTF-8", warn = FALSE)
records <- lapply(rows[nzchar(rows)], function(line) fromJSON(line, simplifyVector = FALSE))

flat <- list()
idx <- 1L
for (rec in records) {
  if (!is.null(rec$error) || is.null(rec$content)) {
    flat[[idx]] <- data.frame(
      custom_id = rec$custom_id %||% NA_character_,
      model = rec$model %||% NA_character_,
      scale_id = NA_character_,
      item_id = NA_character_,
      covariate = NA_character_,
      threshold_dif_probability_0_100 = NA_real_,
      expected_direction = NA_character_,
      confidence_0_100 = NA_real_,
      rationale = NA_character_,
      parse_status = paste0("api_error: ", rec$message %||% rec$error %||% "unknown"),
      stringsAsFactors = FALSE
    )
    idx <- idx + 1L
    next
  }

  parsed <- tryCatch(fromJSON(rec$content, simplifyVector = FALSE), error = function(e) e)
  if (inherits(parsed, "error") || is.null(parsed$predictions)) {
    flat[[idx]] <- data.frame(
      custom_id = rec$custom_id %||% NA_character_,
      model = rec$model %||% NA_character_,
      scale_id = NA_character_,
      item_id = NA_character_,
      covariate = NA_character_,
      threshold_dif_probability_0_100 = NA_real_,
      expected_direction = NA_character_,
      confidence_0_100 = NA_real_,
      rationale = NA_character_,
      parse_status = "json_parse_error",
      stringsAsFactors = FALSE
    )
    idx <- idx + 1L
    next
  }

  for (pred in parsed$predictions) {
    flat[[idx]] <- data.frame(
      custom_id = rec$custom_id %||% NA_character_,
      model = rec$model %||% NA_character_,
      scale_id = parsed$scale_id %||% NA_character_,
      item_id = parsed$item_id %||% NA_character_,
      covariate = pred$covariate %||% NA_character_,
      threshold_dif_probability_0_100 =
        as.numeric(pred$threshold_dif_probability_0_100 %||% NA_real_),
      expected_direction = pred$expected_direction %||% NA_character_,
      confidence_0_100 = as.numeric(pred$confidence_0_100 %||% NA_real_),
      rationale = pred$rationale %||% NA_character_,
      parse_status = "ok",
      stringsAsFactors = FALSE
    )
    idx <- idx + 1L
  }
}

out <- bind_rows(flat)
write.csv(out,
          file.path(out_dir, "maps_llm_gemini_pilot_predictions_flat.csv"),
          row.names = FALSE)
print(out)

