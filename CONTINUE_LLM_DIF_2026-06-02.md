# LLM-DIF Manuscript Handoff

Last updated: 2026-06-02

## Current Branch

- Repository: `https://github.com/cloudvelvet/MNLFALLM.git`
- Branch: `llm-only-clean`
- Working directory used on the original machine: `C:\chen_bauer_2024\MNLFALLM`

## Current Manuscript State

The current submission-ready Word draft is stored in the repository at:

- `RESEARCH/llm_dif_paper_pipeline/outputs/LLM_DIF_submission_ready_final_2026-06-02.docx`

The local non-repository copy on the original machine was:

- `N:\개인\다음논문\LLM_DIF_full_manuscript_draft_psychometric_style_Gemini범위수정_투고압축본_최종.docx`

The final repository copy is the one to use on another computer.

## Manuscript Framing

Current working title:

> Gemini 2.5 Flash는 순서형 DIF 후보를 전문가 어휘 기준보다 효과적으로 우선순위화하는가?: 다문화청소년패널 문항-공변량 조합의 조건부 벤치마크 분석

Current framing:

- This is **not** a paper claiming that LLMs can detect DIF.
- The paper frames Gemini 2.5 Flash as a **candidate hypothesis generation / prioritization tool**.
- The main comparison is against:
  - binary expert lexical benchmark,
  - TF-IDF n-gram similarity baseline,
  - ordinal DIF screening criterion.
- The core conclusion is cautious:
  - Gemini produced structured reviewable hypotheses,
  - but did **not** show a stable advantage over expert lexical criteria,
  - results are sensitive to prompt condition, covariate type, and screening criterion.

## Current Manuscript Edits Completed

Completed by 2026-06-02:

- Compressed manuscript from about 37 pages to about 21 pages.
- Reduced detailed result tables from 19 to 9.
- Lowered rationale coding from a validity claim to a supplementary error-pattern audit.
- Removed or softened over-defensive wording.
- Replaced awkward terms such as:
  - `균질하다`
  - `참조 준거`
  - `zero-shot`
  - `입체적으로`
  - `기하급수적으로`
  - `failure-mode`
  - `focal ??`
  - `probe`
  - `schema`
- Koreanized or smoothed technical wording where appropriate:
  - `JSON schema` -> `JSON 출력 형식`
  - `probe` -> `보조 분석`
  - `provisional criterion` -> `예비 평가 기준`
  - `pooled 분석` -> `통합 분석`
  - `single wave` -> `단일 조사시점`
- Tables were reformatted:
  - table widths aligned,
  - numeric columns centered,
  - header rows shaded and bolded,
  - long explanation cells left-aligned.

## Key Analysis Results Currently Reported

Main pooled Wave 1-5 analysis:

- Gemini AP:
  - original prompt: `.382`
  - strict prompt: `.405`
- Binary expert lexical benchmark AP:
  - original condition comparison: `.376` or about `.375` depending table context
  - strict condition comparison: `.384`
- Bootstrap confidence intervals included zero.
- Paired permutation tests did not show a statistically clear Gemini advantage.
- P@5 and P@10 declined under the strict prompt.
- Wave 6 single-wave sensitivity analysis favored the expert lexical benchmark.

Important interpretation:

- Do **not** write that Gemini failed in an absolute sense.
- Write that disagreement between Gemini and the screening criterion cannot be separated into model failure versus criterion noise under the current design.
- The defensible claim is that Gemini did not **stably** outperform expert lexical criteria under the current screening setup.

## Important Scripts Added During Revision

Document/manuscript scripts:

- `make_submission_trim_docx.py`
- `fix_submission_trim_layout.py`
- `fix_submission_trim_table9.py`
- `finalize_submission_trim_docx.py`
- `finalize_submission_trim_black.py`
- `align_submission_tables.py`
- `humanize_terms_submission_docx.py`
- `repair_humanized_terms_docx.py`
- `final_korean_term_smoothing_docx.py`

Analysis/revision scripts:

- `maps_llm_build_sensitivity_prompts.R`
- `run_maps_llm_gemini_sensitivity.ps1`
- `run_maps_llm_gemini_sensitivity_auto.ps1`
- `maps_llm_parse_sensitivity_results.R`
- `maps_llm_eval_sensitivity.R`
- `maps_llm_eval_sensitivity_binary_keyword.R`
- `maps_llm_eval_binary_keyword_tie_bootstrap.R`
- `maps_llm_eval_sensitivity_w6.R`
- `maps_llm_dif_gold_screen_cluster_robust.R`
- `maps_llm_dif_gold_screen_w6.R`
- `maps_llm_embedding_similarity_baseline.py`
- `maps_llm_uncertainty_tests.py`
- `maps_llm_quadrant_validation_table.py`
- `maps_llm_dif_random_intercept_quadrant_probe.R`

## Data and Output Notes

The following are intentionally ignored by Git:

- `MAPS 2기 패널_Data_CSV (1)/`
- `llm_dif_output/`
- `docx_render_check/`
- `.kkirikkiri/`

Reason:

- MAPS source data are restricted.
- LLM raw output and rendered page images are large or machine-specific.
- The repository should carry scripts, manuscript drafts, and reproducible reporting artifacts, not restricted data.

If continuing on another computer, copy the restricted MAPS data folder separately into:

- `C:\chen_bauer_2024\MNLFALLM\MAPS 2기 패널_Data_CSV (1)\`

Then regenerate ignored outputs as needed.

## Recommended Next Step for SSCI Strengthening

The strongest next move is to add one more LLM for model-sensitivity analysis.

Recommended model:

- `gpt-4.1-mini`

Reason:

- Cheap enough for full rerun.
- Different provider from Gemini.
- Helps answer whether the finding is Gemini-specific or more general to LLM-assisted DIF candidate generation.

Suggested design:

- Run the same item-covariate combinations under:
  - original prompt,
  - strict DIF prompt.
- Compare:
  - AP,
  - P@5,
  - P@10,
  - Spearman rank correlation,
  - top-5/top-10 overlap with Gemini,
  - covariate-specific AP.

Possible stronger framing after adding GPT:

> 생성형 LLM은 순서형 DIF 후보를 안정적으로 우선순위화하는가?: 다문화청소년패널 문항-공변량 조합의 모델 및 지시문 민감도 분석

## Cost Estimate for Additional LLM

Approximate cost if using `gpt-4.1-mini`:

- 300 calls: less than about 1,000 KRW.
- full 487 combinations x 2 prompts = 974 calls: likely around 2,000-3,000 KRW, depending actual token usage.

## Practical Continuation Checklist

1. Pull the repository.
2. Open:
   - `RESEARCH/llm_dif_paper_pipeline/outputs/LLM_DIF_submission_ready_final_2026-06-02.docx`
3. If adding another LLM:
   - create an OpenAI runner analogous to `run_maps_llm_gemini_sensitivity.ps1`,
   - save outputs under ignored `llm_dif_output/`,
   - parse into a comparable `.csv` or `.jsonl`,
   - add model-sensitivity tables to the manuscript.
4. Keep the claim cautious:
   - LLM outputs are candidate hypotheses, not DIF evidence.
   - Rationale audit is an exploratory risk-signal summary, not validated qualitative coding.
5. Do not commit restricted MAPS source data or raw API output unless explicitly intended and allowed.

