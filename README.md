# MNLFALLM

LLM-assisted DIF hypothesis generation for MAPS multicultural panel items.

This repository is separated from the MAPS MNLFA/poster repository. It contains only the LLM-DIF workflow: item/covariate preparation, prompt construction, Gemini/OpenAI runner scaffolds, provisional empirical DIF screening, keyword baselines, LLM result parsing/evaluation, and literature/pitch notes.

## Core framing

LLMs are used as **DIF hypothesis generators**, not final DIF detectors. Final interpretation requires psychometric validation with ordinal DIF/MNLFA-style models and substantive review.

## Main files

- `maps_multiscale_llm_prep.R`: build MAPS multi-scale long file and item/covariate catalog.
- `maps_llm_fill_item_text.R`: fill item text from MAPS user-guide-derived text.
- `maps_llm_make_batches.R`: create pilot/full item-covariate batches.
- `maps_llm_dif_gold_screen.R`: provisional ordinal-logit DIF screening.
- `maps_llm_build_pilot_prompts.R`: build LLM prompt JSONL.
- `run_maps_llm_gemini_pilot.ps1`: Gemini runner with resume/rate-limit handling.
- `maps_llm_parse_gemini_results.R`: parse Gemini JSONL outputs.
- `maps_llm_eval_gemini_pilot.R`: compare LLM scores with provisional DIF labels and keyword baseline.
- `RESEARCH/ai_llm_dif_requirements/`: requirements, professor pitch, and pipeline notes.
- `RESEARCH/llm_dif_prior_work/`: prior-work scan and key sources.
- `HANDOFF_MNLFALLM.md`: practical handoff for another computer.

## Not tracked

The following stay outside GitHub:

- MAPS raw data
- `llm_dif_output/`
- API keys / `.Renviron`
- large generated model or simulation outputs

See `HANDOFF_MNLFALLM.md` for setup details.
