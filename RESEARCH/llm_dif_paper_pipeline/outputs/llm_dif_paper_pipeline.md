# Academic Pipeline: LLM-assisted DIF Hypothesis Generation

## Working Title

**LLM-Assisted Hypothesis Generation for Differential Item Functioning in Multicultural Panel Data**

Alternative titles:

1. Using Large Language Models to Generate Explanatory DIF Hypotheses: A Pilot Study with the MAPS Multicultural Panel
2. From Textual Cues to Psychometric Validation: LLM-Assisted DIF Hypothesis Generation in Multicultural Assessment
3. Can LLMs Help Explain Potential DIF? A Pilot Framework Combining Gemini, Keyword Baselines, and Ordinal DIF Models

## Thesis

This paper does not claim that LLMs detect DIF. It evaluates whether LLMs can serve as an interpretable, theory-guided hypothesis-generation layer that helps prioritize item-covariate pairs for subsequent psychometric validation.

## Prior-Work Positioning

Direct prior work exists, so the novelty cannot be "first LLM for DIF."

Closest sources:

- Li, Marchong, & Aldib (2024), *The Use of ChatGPT to Facilitate Differential Item Functioning (DIF) Detection*. Work-in-progress poster comparing ChatGPT/human DIF judgments with empirical `lordif` results.
- Maeda & Lu (2025), *Finding Words Associated with DIF: Predicting Differential Item Functioning Using LLMs and Explainable AI*. Journal of Educational Measurement. DOI: https://doi.org/10.1111/jedm.70017

Safe novelty claim:

> Prior work has begun using LLMs or Transformer models for DIF prediction and item review. What remains underdeveloped is an interpretable, theory-guided hypothesis-generation workflow that connects LLM-generated item-covariate rationales to empirical ordinal DIF/MNLFA-style validation in longitudinal, covariate-rich multicultural panel data.

## Research Questions

RQ1. Can an LLM generate semantically plausible DIF hypotheses for MAPS item-covariate pairs?

RQ2. Does the LLM add information beyond a keyword baseline when ranking item-covariate pairs for follow-up DIF validation?

RQ3. Does LLM utility vary by covariate type, especially discrimination experience, Korean proficiency, income, age, and gender?

RQ4. Where does the LLM fail, especially by confusing latent trait differences with measurement-function differences?

RQ5. Can the resulting workflow support expert review prioritization without overstating the LLM as a DIF detector?

## Stage 1. Research Lock and Leakage Audit

Purpose: Freeze analysis units, labels, and prompt boundaries before full LLM runs.

Inputs:

- MAPS item text and covariate catalog
- `maps_llm_item_catalog_filled.csv`
- `maps_llm_full_item_covariate_pairs.csv`
- provisional DIF screening rules
- prompt template

Deliverables:

- `gold-standard-spec.md`
- `pair-registry.csv`
- `decision-rule-table.csv`
- `prompt-leakage-audit.md`

Quality gate:

- Every item-covariate pair has a stable ID.
- No empirical DIF labels, statistics, prior flagged IDs, or expert rationales are present in LLM generation prompts.
- DIF labels are separated into `screen-positive`, `validation-positive`, and `indeterminate`.

Stop/Go:

- Go if pair registry and leakage audit pass.
- Stop if prompt inputs contain outcome information.

## Stage 2. Data, Text, and Baseline Preparation

Purpose: Make the non-LLM comparison condition reproducible.

Inputs:

- MAPS long analytic file
- item text
- covariate definitions

Deliverables:

- item catalog
- pair catalog
- keyword baseline predictions
- lexical baseline predictions if feasible
- baseline design note

Primary baseline:

- keyword/covariate semantic marker score

Optional lexical baselines:

- item length
- lexical diversity
- covariate-specific vocabulary flags

Quality gate:

- 0% missing item text.
- all generated item-covariate pairs have baseline scores.
- baseline scripts rerun from scratch.

## Stage 3. LLM Hypothesis Generation

Purpose: Generate structured candidate DIF hypotheses without access to empirical DIF outcomes.

Outputs per item-covariate pair:

- threshold DIF probability
- expected direction
- confidence
- rationale
- parse status

Required artifacts:

- raw response JSONL
- parsed predictions CSV
- prompt manifest
- run log
- model/version/temperature settings

Quality gate:

- at least 90% parseable responses.
- prompt version, model version, and pair ID traceable for every prediction.
- no conversation carryover or result-aware prompting.

Stop/Go:

- Go if parsing and traceability pass.
- Conditional Go if API failures are limited and recoverable with `-Resume`.
- Stop if prompt drift or output parsing makes pair-level alignment unreliable.

## Stage 4. First Evaluation: Ranking Utility

Purpose: Evaluate whether LLM scores are useful for prioritizing validation, not whether they are perfect classifiers.

Primary metrics:

- Average Precision / AUPRC
- Precision@5 and Precision@10
- NDCG@k if graded relevance is added

Secondary metrics:

- AUROC
- recall@k
- calibration summaries
- covariate-specific error profiles

Required comparisons:

- LLM vs keyword baseline
- prompt guardrail vs naive prompt, if available
- covariate-specific results

Quality gate:

- report overall and by-covariate metrics.
- report top-k item-covariate lists.
- distinguish discrimination, Korean proficiency, income, age, and gender.

Stop/Go:

- Go if LLM matches or improves over keyword baseline in at least one theoretically meaningful lane, or if failure modes are theoretically informative.
- Conditional Go if overall performance is weak but covariate-specific patterns or failure modes support a cautionary paper.
- Stop if LLM is uniformly below baseline and error patterns are not interpretable.

## Stage 5. Psychometric Validation and Failure-Mode Audit

Purpose: Separate plausible semantic stories from measurement evidence.

Validation ladder:

1. provisional ordinal DIF screening
2. sensitivity analysis around screening thresholds
3. formal ordinal DIF/MNLFA-style validation for selected scales/covariates

Failure-mode taxonomy:

- latent difference confusion
- construct-relevant content confusion
- wording artifact overcall
- stereotype/generic rationale
- true semantic DIF candidate
- empirical DIF with weak semantic cue

Deliverables:

- validation joined table
- top candidate casebook
- failure-mode codebook
- false-positive audit

Quality gate:

- success, false-positive, and false-negative cases are all shown.
- MNLFA/ordinal DIF results determine claim strength.
- qualitative rationales never enter the conclusion without model evidence.

## Stage 6. Robustness and Negative Controls

Purpose: Show the workflow is not a prompt artifact.

Recommended robustness lanes:

- prompt variant
- model family variant
- item/covariate order randomization
- shuffled covariate-label negative control
- original Korean vs translated wording comparison, if translation is used

Deliverables:

- robustness matrix
- negative-control results
- sensitivity summary

Quality gate:

- at least two robustness lanes completed before strong claims.
- negative controls do not produce excessive high-confidence hypotheses.

## Stage 7. Manuscript Decision

Decision types:

1. **Positive workflow paper**: LLM has clear incremental ranking utility and validated examples.
2. **Qualified/mixed evidence paper**: LLM is useful in some covariate lanes but shows important failure modes.
3. **Cautionary paper**: LLM performs weakly but reveals systematic psychometric risks.

Preferred current framing:

> Qualified/mixed evidence paper.

This is safest because the pilot already shows useful discrimination/Korean-proficiency signal but also age-related false positives and latent-vs-DIF confusion.

## Core Tables and Figures

Table 1. Prior work map: LLM/AI psychometrics, LLM-DIF prediction, item-review automation.

Table 2. MAPS scales, items, covariates, and item-covariate pair counts.

Table 3. LLM vs keyword baseline metrics overall and by covariate.

Table 4. Top-k item-covariate hypotheses with empirical validation status.

Table 5. Failure-mode taxonomy with examples.

Figure 1. Workflow diagram: item text -> LLM hypothesis -> baseline comparison -> DIF/MNLFA validation -> expert review.

Figure 2. Precision@k / AUPRC comparison by covariate.

Figure 3. Case-study panel: validated hypothesis vs plausible false positive vs missed empirical DIF.

## Unsafe Claims

Avoid:

- LLMs detect DIF.
- LLMs identify biased items.
- LLM rationales reveal the true cause of DIF.
- LLMs replace experts.
- high LLM probability means item bias.

Use:

- LLMs generate candidate DIF hypotheses.
- LLMs prioritize item-covariate pairs for follow-up validation.
- LLM rationales partially align with empirical DIF evidence in selected cases.
- LLM failure modes reveal the need for psychometric guardrails.

