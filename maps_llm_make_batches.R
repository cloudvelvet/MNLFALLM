# Create prompt-ready batches for LLM DIF hypothesis generation.
#
# Run after:
#   Rscript maps_multiscale_llm_prep.R
#   Rscript maps_llm_fill_item_text.R
#
# Outputs:
#   llm_dif_output/maps_llm_pilot_items_30.csv
#   llm_dif_output/maps_llm_full_items.csv
#   llm_dif_output/maps_llm_full_item_covariate_pairs.csv

if (!requireNamespace("dplyr", quietly = TRUE)) {
  stop("Package 'dplyr' is required.")
}

library(dplyr)

out_dir <- "llm_dif_output"
catalog_csv <- file.path(out_dir, "maps_llm_item_catalog_filled.csv")
template_csv <- file.path(out_dir, "maps_llm_prediction_template_filled.csv")

if (!file.exists(catalog_csv) || !file.exists(template_csv)) {
  stop("Run maps_llm_fill_item_text.R before this script.")
}

catalog <- read.csv(catalog_csv, stringsAsFactors = FALSE)
template <- read.csv(template_csv, stringsAsFactors = FALSE)

full_items <- catalog %>%
  filter(item_text_status == "filled_from_user_guide") %>%
  arrange(respondent_type, scale_id, item_stem)

pilot_plan <- data.frame(
  scale_id = c(
    "parent_acculturative_stress",
    "youth_acculturative_stress",
    "parent_self_esteem",
    "youth_bicultural_acceptance",
    "parent_acculturation",
    "youth_worry",
    "youth_bullying"
  ),
  n_items = c(8, 9, 4, 4, 2, 2, 1),
  stringsAsFactors = FALSE
)

pilot_items <- bind_rows(lapply(seq_len(nrow(pilot_plan)), function(i) {
  full_items %>%
    filter(scale_id == pilot_plan$scale_id[i]) %>%
    arrange(item_stem) %>%
    slice_head(n = pilot_plan$n_items[i])
})) %>%
  mutate(pilot_order = row_number()) %>%
  select(pilot_order, everything())

write.csv(pilot_items,
          file.path(out_dir, "maps_llm_pilot_items_30.csv"),
          row.names = FALSE)
write.csv(full_items,
          file.path(out_dir, "maps_llm_full_items.csv"),
          row.names = FALSE)
write.csv(template,
          file.path(out_dir, "maps_llm_full_item_covariate_pairs.csv"),
          row.names = FALSE)

message("Saved pilot and full LLM batches in: ", out_dir)
message("Pilot items: ", nrow(pilot_items))
message("Full items: ", nrow(full_items))
message("Full item-covariate pairs: ", nrow(template))

