# MAPS LLM-DIF Pipeline Status

## Implemented Files

- `maps_multiscale_llm_prep.R`
  - Builds a multi-scale parent/youth MAPS item pool.
  - Outputs long item-response data, item catalog, and LLM prediction template.

- `maps_llm_dif_gold_screen.R`
  - Runs fast ordinal-logit DIF screening.
  - Uses an item-specific model with a leave-one-item-out scale mean proxy,
    covariate effect, and wave adjustment.
  - This is a provisional screening model, not final MNLFA evidence.

- `maps_llm_dif_prompt_template.md`
  - Structured JSON prompt template for blinded LLM DIF hypothesis generation.

- `maps_llm_build_pilot_prompts.R`
  - Builds 30 JSONL prompts for the low-cost pilot without calling any API.

- `maps_llm_keyword_baseline_eval.R`
  - Runs a free keyword baseline that future LLM predictions should beat.

- `run_maps_llm_openai_pilot.ps1`
  - PowerShell OpenAI runner for a tiny paid pilot when `OPENAI_API_KEY` is set.

## Generated Local Outputs

These files are intentionally ignored by Git under `llm_dif_output/`.

- `maps_multiscale_long.csv`
- `maps_multiscale_qc.csv`
- `maps_llm_item_catalog.csv`
- `maps_llm_prediction_template.csv`
- `maps_dif_screening_gold_quick.csv`
- `maps_dif_screening_gold_summary_quick.csv`
- `maps_dif_screening_gold_full.csv`
- `maps_dif_screening_gold_summary_full.csv`
- `maps_llm_pilot_items_30.csv`
- `maps_llm_pilot_prompts_30.jsonl`
- `maps_llm_pilot_prompt_preview.txt`
- `maps_keyword_baseline_predictions.csv`
- `maps_keyword_baseline_metrics.csv`

## Current Item Pool

The preprocessing script found 14 repeated MAPS scale batteries:

- Parent acculturation: 12 items
- Parent acculturative stress: 8 items
- Parent parenting efficacy: 9 items
- Parent self-esteem: 9 items
- Youth acculturative stress: 9 items
- Youth bicultural acceptance: 10 items
- Youth bullying: 6 items
- Youth friend support: 3 items
- Youth life satisfaction: 3 items
- Youth national identity: 4 items
- Youth parent support: 6 items
- Youth parenting / parent relationship: 10 items
- Youth teacher support: 3 items
- Youth worry: 14 items

Total screening units:

- 105 items after excluding the unstable youth worry split item
- respondent-valid covariates only
- 487 item-by-covariate tests

## Verification Runs

The following commands were run successfully:

```powershell
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' maps_multiscale_llm_prep.R
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' maps_llm_fill_item_text.R
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' maps_llm_make_batches.R
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' maps_llm_dif_gold_screen.R quick
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' maps_llm_dif_gold_screen.R full
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' maps_llm_build_pilot_prompts.R
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' maps_llm_keyword_baseline_eval.R
```

The OpenAI runner was tested without a key:

```powershell
powershell -ExecutionPolicy Bypass -File .\run_maps_llm_openai_pilot.ps1 -Limit 1
```

It correctly stopped without making a paid call because `OPENAI_API_KEY` was not
set.

## Caveats

- `item_text` is filled for all current pilot items from the MAPS user guide.
- The screening model is a practical ordinal DIF screen using a proxy latent
  score. It is not a final longitudinal MNLFA.
- Parent gender is unavailable in the current parent file and is excluded from
  the LLM prediction template and screening tests.
- Some youth Korean-proficiency values are missing across many item rows because
  those variables are not consistently available for every respondent/wave.
- DIF labels are currently based on FDR-adjusted p-values plus a practical
  coefficient threshold of `|beta| >= 0.20`.

## Next Step

Fill item text from the MAPS user guide, then run a small LLM pilot on 20-30
items before spending money on multi-model API calls.

Current next step:

```powershell
$env:OPENAI_API_KEY = "..."
powershell -ExecutionPolicy Bypass -File .\run_maps_llm_openai_pilot.ps1 -Limit 3
```

