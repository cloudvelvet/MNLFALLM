# Build JSONL prompt payloads for the low-cost MAPS LLM-DIF pilot.
#
# This does not call any paid API. It creates prompt-ready JSONL files from the
# filled MAPS item catalog.
#
# Usage:
#   Rscript maps_llm_build_pilot_prompts.R
#
# Outputs:
#   llm_dif_output/maps_llm_pilot_prompts_30.jsonl
#   llm_dif_output/maps_llm_pilot_prompt_preview.txt

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Package 'dplyr' is required.")
}

library(dplyr)

out_dir <- "llm_dif_output"
pilot_csv <- file.path(out_dir, "maps_llm_pilot_items_30.csv")
if (!file.exists(pilot_csv)) {
  stop("Missing ", pilot_csv, ". Run maps_llm_make_batches.R first.")
}

pilot <- read.csv(pilot_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")

json_escape <- function(x) {
  x <- ifelse(is.na(x), "", x)
  x <- gsub("\\\\", "\\\\\\\\", x)
  x <- gsub("\"", "\\\\\"", x)
  x <- gsub("\r", "\\\\r", x)
  x <- gsub("\n", "\\\\n", x)
  x
}

covariate_block <- paste(
  "- discrim_any: whether the respondent reported discrimination experience.",
  "- korean_c: Korean proficiency.",
  "- income_c: household income / socioeconomic resources.",
  "- gender: respondent gender when available; use only for youth items.",
  "- age_c: respondent age.",
  sep = "\n"
)

build_prompt <- function(row) {
  paste0(
    "Construct: ", row$scale_name, "\n\n",
    "Target population: ",
    ifelse(row$respondent_type == "parent",
           "Parents in a multicultural-family longitudinal panel study in Korea.",
           "Adolescents in a multicultural-family longitudinal panel study in Korea."),
    "\n\n",
    "Item variable: ", row$item_stem, "\n",
    "Item text: ", row$item_text, "\n",
    "Response options: ", row$response_options, "\n",
    "Wording note: ", row$wording_note, "\n\n",
    "Covariates:\n", covariate_block, "\n\n",
    "Task: For each respondent-valid covariate, estimate whether this item is likely ",
    "to show uniform/threshold-like DIF.\n\n",
    "Important distinction:\n",
    "- Latent construct difference means a group may truly have more or less of the construct.\n",
    "- DIF means that, at the SAME latent construct level, the item wording may lead ",
    "respondents with different covariate values to endorse higher or lower categories ",
    "more easily.\n\n",
    "Score high only when the item wording gives a plausible reason for different ",
    "response thresholds at the same latent level. Do not score high merely because ",
    "the covariate could predict the construct itself. If the covariate is only a ",
    "general risk factor, use a low or moderate score.\n\n",
    "Use only the item wording and construct context. Do not claim that DIF exists. ",
    "Do not predict loading/nonuniform DIF. Do not use causal language or stereotypes.\n\n",
    "Return valid JSON only with this schema:\n",
    "{\n",
    "  \"scale_id\": \"", row$scale_id, "\",\n",
    "  \"item_id\": \"", row$item_id, "\",\n",
    "  \"predictions\": [\n",
    "    {\n",
    "      \"covariate\": \"discrim_any\",\n",
    "      \"threshold_dif_probability_0_100\": 0,\n",
    "      \"expected_direction\": \"positive | negative | unclear\",\n",
    "      \"confidence_0_100\": 0,\n",
    "      \"rationale\": \"one short sentence explaining the item-wording mechanism, or why there is little basis for DIF\"\n",
    "    }\n",
    "  ]\n",
    "}\n"
  )
}

system_message <- paste(
  "You are assisting a psychometrician with blinded DIF hypothesis generation.",
  "You do not determine whether DIF exists.",
  "Generate text-based hypotheses that will later be compared against empirical psychometric models.",
  "Separate true latent construct differences from DIF at the same latent construct level.",
  "Return valid JSON only."
)

lines <- character(nrow(pilot))
for (i in seq_len(nrow(pilot))) {
  row <- pilot[i, ]
  prompt <- build_prompt(row)
  lines[i] <- paste0(
    "{\"custom_id\":\"pilot_", sprintf("%03d", i), "\",",
    "\"respondent_type\":\"", json_escape(row$respondent_type), "\",",
    "\"scale_id\":\"", json_escape(row$scale_id), "\",",
    "\"item_id\":\"", json_escape(row$item_id), "\",",
    "\"messages\":[",
    "{\"role\":\"system\",\"content\":\"", json_escape(system_message), "\"},",
    "{\"role\":\"user\",\"content\":\"", json_escape(prompt), "\"}",
    "]}"
  )
}

jsonl_path <- file.path(out_dir, "maps_llm_pilot_prompts_30.jsonl")
writeLines(lines, jsonl_path, useBytes = TRUE)

preview <- paste0(
  "SYSTEM:\n", system_message, "\n\nUSER:\n", build_prompt(pilot[1, ])
)
writeLines(preview, file.path(out_dir, "maps_llm_pilot_prompt_preview.txt"),
           useBytes = TRUE)

message("Saved: ", jsonl_path)
message("Saved: ", file.path(out_dir, "maps_llm_pilot_prompt_preview.txt"))
message("Prompts: ", length(lines))
