# Validation Gates and Guardrails

## Gate 1. Leakage Audit

Pass condition:

- Generation prompts contain no DIF statistics, empirical labels, prior flagged item IDs, expert rationales, or model results.

Fail condition:

- The LLM sees the answer key, directly or indirectly.

## Gate 2. Reproducibility Audit

Pass condition:

- prompt template, model name/version, parameters, batch file, timestamp, and raw responses are saved.

Recommended minimum:

- repeat a subset of items at least twice or run two prompt variants.

## Gate 3. Comparator Fairness Audit

Pass condition:

- keyword, LLM, and any human expert comparison use defined inputs and comparable item-covariate units.

If human experts are used:

- same item text.
- same covariate definitions.
- no empirical DIF results.
- fixed time/attempt budget.

## Gate 4. Negative-Control Audit

Pass condition:

- shuffled covariate labels or null/simulated items do not receive high DIF probabilities at unacceptable rates.

Purpose:

- detect generic storytelling and subgroup stereotyping.

## Gate 5. Psychometric Validation

Pass condition:

- at least focal top-ranked candidates are tested with a preregistered ordinal DIF/MNLFA-style model.

Claim strength:

- without MNLFA/formal validation: "candidate hypotheses only."
- with validation: "LLM-prioritized hypotheses showed partial empirical support."
- never: "LLM proved DIF cause."

## Gate 6. Incremental Utility

Pass condition:

- LLM shows value beyond keyword baseline in at least one metric or one theoretically meaningful covariate lane.

Recommended metrics:

- AUPRC / Average Precision.
- Precision@5.
- Precision@10.
- NDCG@k if graded labels exist.

## Gate 7. Failure-Mode Audit

Every false positive and false negative sampled for the paper should be coded into:

- latent difference confusion.
- construct-relevant content confusion.
- wording artifact overcall.
- stereotype/generic rationale.
- missed nonsemantic empirical DIF.
- plausible semantic DIF candidate.

## Gate 8. Claim-Faithfulness Audit

Before writing abstract/discussion, check every major claim:

| Claim Type | Allowed Evidence |
|---|---|
| LLM generated hypotheses | prompt outputs and parsed results |
| LLM prioritized useful candidates | ranking metrics and top-k validation |
| DIF exists | empirical DIF/MNLFA model |
| mechanism is causal | not allowed from this design |
| item is biased/unfair | not allowed without substantive fairness review |

## Banned Wording

- detects DIF
- proves DIF
- identifies biased items
- reveals the cause
- replaces expert review
- validates fairness

## Preferred Wording

- generates candidate DIF hypotheses
- prioritizes item-covariate pairs
- provides semantically plausible rationales
- requires psychometric validation
- shows partial alignment with empirical DIF evidence
- exhibits failure modes requiring guardrails

