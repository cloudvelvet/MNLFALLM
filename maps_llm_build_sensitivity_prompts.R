# Build full-item prompt-sensitivity JSONL files for MAPS LLM-DIF.
#
# This script does not call any API. It creates one prompt file per prompt
# version so the Gemini runner can process them slowly on the free tier.
#
# Usage:
#   Rscript maps_llm_build_sensitivity_prompts.R
#
# Outputs:
#   llm_dif_output/maps_llm_sensitivity_prompts_original.jsonl
#   llm_dif_output/maps_llm_sensitivity_prompts_strict_dif.jsonl
#   llm_dif_output/maps_llm_sensitivity_prompts_response_process.jsonl
#   llm_dif_output/maps_llm_sensitivity_prompt_manifest.csv

if (!requireNamespace("jsonlite", quietly = TRUE)) {
  stop("Package 'jsonlite' is required.")
}

out_dir <- "llm_dif_output"
items_csv <- file.path(out_dir, "maps_llm_full_items.csv")
if (!file.exists(items_csv)) {
  stop("Missing ", items_csv, ". Run maps_multiscale_llm_prep.R and text-fill first.")
}

items <- read.csv(items_csv, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
items$item_order <- seq_len(nrow(items))

json_line <- function(x) {
  jsonlite::toJSON(x, auto_unbox = TRUE, null = "null")
}

target_population <- function(respondent_type) {
  if (respondent_type == "parent") {
    "Parents in a multicultural-family longitudinal panel study in Korea."
  } else {
    "Adolescents in a multicultural-family longitudinal panel study in Korea."
  }
}

covariate_block <- function(respondent_type) {
  covs <- c(
    "- discrim_any: whether the respondent reported discrimination experience.",
    "- korean_c: Korean proficiency.",
    "- income_c: household income / socioeconomic resources."
  )
  if (respondent_type == "youth") {
    covs <- c(covs, "- gender: respondent gender.")
  }
  covs <- c(covs, "- age_c: respondent age.")
  paste(covs, collapse = "\n")
}

system_message <- function(version) {
  if (version == "strict_dif") {
    paste(
      "You are assisting a psychometrician with blinded DIF hypothesis generation.",
      "You do not determine whether DIF exists.",
      "Only score high when the item wording gives a plausible threshold mechanism at the same latent construct level.",
      "Reject explanations that only describe latent construct differences, group mean differences, or general risk factors.",
      "Return valid JSON only."
    )
  } else if (version == "response_process") {
    paste(
      "You are assisting a psychometrician with blinded DIF hypothesis generation.",
      "Focus on response-process mechanisms: comprehension, interpretation, recall, judgment, reference group, and response-category use.",
      "Do not treat general social risk, group mean differences, or stereotypes as DIF evidence.",
      "Return valid JSON only."
    )
  } else {
    paste(
      "You are assisting a psychometrician with blinded DIF hypothesis generation.",
      "You do not determine whether DIF exists.",
      "Generate text-based hypotheses that will later be compared against empirical psychometric models.",
      "Separate true latent construct differences from DIF at the same latent construct level.",
      "Return valid JSON only."
    )
  }
}

version_instruction <- function(version) {
  if (version == "strict_dif") {
    paste0(
      "Strict DIF scoring rule:\n",
      "- First ask whether the rationale still holds after conditioning on the same latent construct level.\n",
      "- Give a high score only if the item wording, response categories, or construct context imply different response thresholds.\n",
      "- Give a low score when the covariate is merely a predictor of the latent construct itself.\n",
      "- The rationale must explicitly separate impact from DIF.\n\n"
    )
  } else if (version == "response_process") {
    paste0(
      "Response-process scoring rule:\n",
      "- Base the score only on comprehension, interpretation, recall, judgment, reference group, social desirability, or response-category use.\n",
      "- Do not score high because the covariate may affect the true level of the construct.\n",
      "- Do not rely on broad demographic generalizations or stereotypes.\n",
      "- The rationale must describe a response-process mechanism or explain why one is absent.\n\n"
    )
  } else {
    paste0(
      "Score high only when the item wording gives a plausible reason for different ",
      "response thresholds at the same latent level. Do not score high merely because ",
      "the covariate could predict the construct itself. If the covariate is only a ",
      "general risk factor, use a low or moderate score.\n\n"
    )
  }
}

build_prompt <- function(row, version) {
  paste0(
    "Construct: ", row$scale_name, "\n\n",
    "Target population: ", target_population(row$respondent_type), "\n\n",
    "Item variable: ", row$item_stem, "\n",
    "Item text: ", row$item_text, "\n",
    "Response options: ", row$response_options, "\n",
    "Wording note: ", row$wording_note, "\n\n",
    "Respondent-valid covariates:\n", covariate_block(row$respondent_type), "\n\n",
    "Task: For each respondent-valid covariate listed above, estimate whether this item is likely ",
    "to show uniform/threshold-like DIF.\n\n",
    "Important distinction:\n",
    "- Latent construct difference means a group may truly have more or less of the construct.\n",
    "- DIF means that, at the SAME latent construct level, the item wording may lead ",
    "respondents with different covariate values to endorse higher or lower categories ",
    "more easily.\n\n",
    version_instruction(version),
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
    "      \"rationale\": \"one short sentence explaining the item-wording or response-process mechanism, or why there is little basis for DIF\"\n",
    "    }\n",
    "  ]\n",
    "}\n"
  )
}

versions <- c("original", "strict_dif", "response_process")
manifest <- data.frame()

for (version in versions) {
  lines <- character(nrow(items))
  for (i in seq_len(nrow(items))) {
    row <- items[i, ]
    payload <- list(
      custom_id = paste0("sens_", version, "_", sprintf("%03d", i)),
      prompt_version = version,
      item_order = i,
      respondent_type = row$respondent_type,
      scale_id = row$scale_id,
      item_id = row$item_id,
      messages = list(
        list(role = "system", content = system_message(version)),
        list(role = "user", content = build_prompt(row, version))
      )
    )
    lines[i] <- json_line(payload)
  }

  out_path <- file.path(out_dir, paste0("maps_llm_sensitivity_prompts_", version, ".jsonl"))
  writeLines(lines, out_path, useBytes = TRUE)

  preview_path <- file.path(out_dir, paste0("maps_llm_sensitivity_prompt_preview_", version, ".txt"))
  writeLines(
    paste0("SYSTEM:\n", system_message(version), "\n\nUSER:\n", build_prompt(items[1, ], version)),
    preview_path,
    useBytes = TRUE
  )

  manifest <- rbind(
    manifest,
    data.frame(
      prompt_version = version,
      prompt_path = out_path,
      preview_path = preview_path,
      n_prompts = length(lines),
      stringsAsFactors = FALSE
    )
  )

  message("Saved: ", out_path)
}

manifest_path <- file.path(out_dir, "maps_llm_sensitivity_prompt_manifest.csv")
write.csv(manifest, manifest_path, row.names = FALSE)
message("Saved: ", manifest_path)
