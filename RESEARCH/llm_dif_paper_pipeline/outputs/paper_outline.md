# Paper Outline: LLM-assisted DIF Hypothesis Generation

## Abstract Skeleton

Background: DIF detection is central to fair and valid group comparison, but generating interpretable item-level hypotheses about why DIF may occur remains labor-intensive.

Objective: This study evaluates whether LLMs can generate semantically plausible DIF hypotheses for multicultural panel items and whether those hypotheses help prioritize psychometric validation.

Method: Using MAPS multicultural panel items, Gemini generates item-covariate DIF hypotheses. LLM scores are compared with keyword baselines and provisional ordinal DIF screening, with later MNLFA/ordinal DIF validation planned for focal scales.

Results: Report ranking utility, covariate-specific patterns, and case studies. Emphasize both alignment and failure modes.

Conclusion: LLMs should be treated as hypothesis-generation and triage tools, not standalone DIF detectors.

## Introduction

1. DIF and measurement invariance matter for longitudinal multicultural research.
2. Statistical DIF methods are strong at detection, but item-level explanatory hypothesis generation is still expert-intensive.
3. LLMs may help generate candidate mechanisms from item text and covariate context.
4. But LLMs may confuse latent trait differences, cultural stereotypes, and true measurement-function changes.
5. This paper evaluates the usefulness and risks of LLM-assisted DIF hypothesis generation.

## Related Work

1. DIF, item bias, impact, and measurement invariance.
2. MIMIC/MNLFA and covariate-rich DIF modeling.
3. Expert item review and qualitative DIF explanation.
4. AI/LLM in psychometric item generation and item review.
5. Direct LLM-DIF work:
   - Li et al. (2024) ChatGPT DIF poster.
   - Maeda & Lu (2025) LLM/XAI text-to-DIF prediction.
6. Gap: theory-guided, interpretable hypothesis generation linked to ordinal/MNLFA validation in longitudinal multicultural data.

## Method

### Data

- MAPS multicultural panel.
- Parent/youth item pools.
- Covariates: discrimination experience, Korean proficiency, income, age, gender where applicable.
- Item-covariate unit of analysis.

### LLM Prompting

- Prompt asks for threshold DIF probability, direction, confidence, and rationale.
- Prompt explicitly distinguishes latent trait differences from threshold DIF.
- No empirical DIF labels are included in the generation prompt.

### Baselines

- keyword baseline.
- optional lexical baseline.
- optional naive prompt baseline.

### Empirical DIF Screening

- provisional ordinal-logit DIF screen using keyed theta proxy.
- later formal MNLFA/ordinal DIF validation for selected scales.

### Evaluation

- AUPRC / Average Precision.
- Precision@k.
- covariate-stratified performance.
- qualitative failure-mode coding.

## Results

1. Descriptive map of item-covariate pairs.
2. Overall LLM vs keyword ranking performance.
3. Covariate-specific results.
4. Top-k hypotheses.
5. Case studies:
   - validated discrimination-linked DIF candidate.
   - Korean proficiency semantic candidate.
   - age false positive / latent-difference confusion.
   - empirical DIF missed by LLM.

## Discussion

1. LLMs appear more useful for hypothesis prioritization than final detection.
2. Keyword baselines can be strong when item wording directly names the covariate-relevant construct.
3. LLMs may add value for less literal semantic links, such as language proficiency.
4. LLMs can overgenerate plausible but psychometrically unsupported stories.
5. Formal DIF/MNLFA validation is non-negotiable.

## Limitations

- single dataset.
- pilot scale unless full 487 pair run is completed.
- Gemini model/version dependence.
- provisional labels are not gold standards.
- prompt sensitivity.
- no causal mechanism proof.

## Conclusion

LLMs can be evaluated as interpretable DIF hypothesis generators, but only inside a guarded psychometric workflow that separates semantic plausibility from measurement evidence.

