# What Is Needed for a Standalone AI + Psychometrics DIF Paper?

## Verdict

The weak version is not worth doing:

> "We asked an LLM to explain our MAPS DIF results."

That would be too post-hoc, too small, and too easy for reviewers to dismiss as
plausible narrative generation.

The publishable version is:

> "Can preregistered LLM-based semantic and mechanism hypotheses prospectively
> anticipate empirical DIF patterns, beyond simple text features and human expert
> baselines?"

This is a conditional go, but only with a stronger design than the current MAPS
8-item case study.

## Why MAPS Alone Is Too Small

The current MAPS acculturative-stress application has:

- 8 items.
- 4 DIF covariates: parent age, Korean proficiency, income, discrimination.
- 32 item-by-covariate prediction units.

That is too small for a credible standalone LLM prediction paper. One or two
items can dominate every metric. Waves should not be counted as independent
prediction units because the item text is unchanged.

Minimum viable target:

- at least 100-150 item-by-covariate units;
- preferably 20-30 positive DIF cases overall;
- ideally a second scale, second dataset, or external DIF benchmark.

## Required Study Design

### 1. Freeze the Gold Standard First

Before any LLM prompting, preregister the empirical DIF target:

- final psychometric model;
- DIF decision rule;
- practical effect-size threshold;
- treatment of threshold DIF and loading DIF;
- treatment of direction;
- sensitivity analyses.

For MAPS, the strongest target is stable item-level DIF from longitudinal ordinal
MNLFA, not wave-specific noise.

### 2. Use Blinded LLM Prediction

The LLM should receive only:

- item wording;
- response options;
- construct definition;
- broad target-population context;
- covariate definitions.

The LLM should not receive:

- empirical DIF results;
- item response distributions;
- posterior summaries;
- known "top DIF item" labels;
- analyst-written interpretations of the results.

### 3. Collect Structured Outputs

For every item-by-covariate pair:

- predicted probability of any DIF;
- predicted probability of threshold DIF;
- predicted probability of loading/nonuniform DIF;
- predicted direction if applicable;
- rank within covariate;
- short mechanism rationale;
- model self-confidence.

Save model name, version, prompt, temperature, seed, date, and full raw response.

### 4. Use Proper Metrics

Primary metrics should be ranking metrics because this is hypothesis generation:

- Average precision / AUPRC.
- Precision@k.
- NDCG@k.

Secondary metrics:

- AUROC.
- Recall@k.
- Brier score.
- Expected calibration error.
- Direction accuracy where direction is meaningful.

Use cluster bootstrap over items, not raw pair bootstrap.

### 5. Add Baselines

The LLM must be compared against:

- random ranking;
- human psychometrician ratings;
- simple lexical features such as item length, readability, sentiment, emotion
  words, family/economic vocabulary, and cultural-language markers;
- embedding similarity or bag-of-words models.

If the LLM does not beat simple lexical baselines, the paper becomes a useful
negative or cautionary result, not a strong AI-assisted psychometrics claim.

### 6. Add Robustness

Required robustness checks:

- multiple LLM families;
- multiple prompt wordings;
- item-order and covariate-order randomization;
- original Korean wording versus independent English translations;
- fake covariates or shuffled covariate labels as negative controls;
- counterfactual item rewrites targeting the mechanism the LLM claims matters;
- alternate empirical DIF thresholds.

### 7. Handle Governance

MAPS item wording may have data-use restrictions. Before using external APIs or
sharing prompts, confirm:

- whether exact item wording can be sent to commercial LLM services;
- whether exact item wording can be reproduced in a manuscript or supplement;
- whether prompts/responses can be made public;
- whether only paraphrases or synthetic item variants are allowed.

## Claim Language

Safe claim:

> LLMs can be evaluated as tools for generating DIF hypotheses from item text,
> but empirical psychometric models remain necessary for validation.

Unsafe claims:

- LLMs detect true DIF.
- LLMs prove why DIF occurs.
- LLMs replace MNLFA, IRT, or expert review.
- Agreement between LLM and MNLFA proves item bias.
- Non-flagged items are free from DIF.

## Recommended Paper Shape

Title candidate:

> AI-Assisted DIF Hypothesis Generation: Benchmarking Large Language Model Item
> Appraisals Against Longitudinal MNLFA Evidence

Core research questions:

1. Can LLMs rank item-by-covariate pairs by empirical DIF risk above chance?
2. Do LLM predictions outperform simple text-feature baselines?
3. Are LLM rationales judged useful by psychometric experts?
4. Are predictions robust across prompt wording, model family, and language
   translation?
5. Do counterfactual item edits shift LLM DIF predictions in theoretically
   expected directions?

## Practical Recommendation

Do not make this the next immediate paper unless you can add more items or a
second dataset. Keep the idea, but first finish the MAPS empirical MNLFA paper.

Best role in the dissertation:

- Main empirical psychometrics paper: MAPS MNLFA.
- Monte Carlo paper: longitudinal ordinal MNLFA recovery.
- Estimation paper: VI / Pathfinder / subset NUTS / full NUTS.
- Optional AI paper: LLM-assisted DIF hypothesis generation, only after adding
  external validation or more item content.

