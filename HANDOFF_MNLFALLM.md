# MNLFALLM handoff

Purpose: LLM-assisted DIF hypothesis generation for MAPS item-covariate pairs.

This repository is for the exploratory LLM-DIF project. The core idea is to use LLMs as semantic DIF hypothesis generators, not as final DIF detectors. Psychometric validation remains necessary through keyword baselines, ordinal DIF screening, and later MNLFA-style models.

## What belongs here

- MAPS item/covariate catalog preparation scripts
- Prompt templates and prompt-building scripts
- Gemini/OpenAI runner scripts
- Parsing and evaluation scripts for LLM outputs
- Keyword baseline and provisional DIF screening scripts
- Literature scan and professor-pitch notes for the LLM-DIF idea

## What does not belong here

- MAPS raw source data
- `llm_dif_output/` generated results
- API keys or `.Renviron`
- MNLFA poster/model output folders
- Poster-specific Stan/R scripts unrelated to LLM-DIF

## Local-only folders

Move these through MYBOX/private storage, not GitHub:

```text
C:\chen_bauer_2024\MAPS 2기 패널_Data_CSV (1)
C:\chen_bauer_2024\llm_dif_output
```

## Other computer setup

Clone the repo:

```powershell
git clone https://github.com/cloudvelvet/MNLFALLM.git C:\chen_bauer_2024\MNLFALLM
```

Copy data/results from MYBOX if available:

```text
MYBOX\MNLFA_STRESS_shared\data\MAPS 2기 패널_Data_CSV (1)
-> C:\chen_bauer_2024\MAPS 2기 패널_Data_CSV (1)

MYBOX\MNLFA_STRESS_shared\outputs\llm_dif_output
-> C:\chen_bauer_2024\MNLFALLM\llm_dif_output
```

Set Gemini API key on the new computer:

```powershell
[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", "YOUR_KEY", "User")
```

Open a new PowerShell and verify:

```powershell
powershell -ExecutionPolicy Bypass -File .\check_gemini_api_key.ps1
```

## Main workflow

Prepare item/covariate data:

```powershell
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' .\maps_multiscale_llm_prep.R
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' .\maps_llm_fill_item_text.R
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' .\maps_llm_make_batches.R
```

Run provisional DIF screening:

```powershell
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' .\maps_llm_dif_gold_screen.R full
```

Run Gemini slowly with resume:

```powershell
powershell -ExecutionPolicy Bypass -File .\run_maps_llm_gemini_pilot.ps1 -Limit 10 -Resume -SleepSeconds 90 -RateLimitBaseSeconds 90 -RateLimitMaxSeconds 600
```

Parse/evaluate:

```powershell
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' .\maps_llm_parse_gemini_results.R
& 'C:\Program Files\R\R-4.4.2\bin\Rscript.exe' .\maps_llm_eval_gemini_pilot.R
```

## Current interpretation

Do not claim that LLMs detect DIF. The safer framing is:

> LLMs may help generate semantically plausible DIF hypotheses, but empirical psychometric validation is required. A key research target is where LLMs confuse latent trait differences with measurement-function differences.
