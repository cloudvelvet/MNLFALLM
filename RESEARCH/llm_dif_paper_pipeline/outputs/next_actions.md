# Next Actions

## Immediate

1. Keep `MNLFALLM` separate from `MNLFA_STRESS`.
2. Preserve `MNLFALLM/llm-only-clean` as the clean LLM branch until main is explicitly rewritten.
3. Freeze the current prompt template and write `prompt_manifest.json`.
4. Run or schedule the full 105-item prompt set slowly with Gemini `-Resume`.
5. Rerun parse/eval after every successful batch.

## Analysis

1. Create a final pair registry for all 487 item-covariate pairs.
2. Create a gold-standard specification separating:
   - provisional screen-positive.
   - formal validation-positive.
   - indeterminate.
3. Extend metrics from pilot to full:
   - overall AUPRC.
   - by-covariate AUPRC.
   - Precision@5 and Precision@10.
   - top-k case list.
4. Build false-positive and false-negative audit tables.
5. Select 3-4 case studies for the paper.

## Paper

1. Use Maeda & Lu (2025) and Li et al. (2024) as direct prior work.
2. Frame novelty as theory-guided hypothesis generation, not first LLM-DIF work.
3. Draft Methods before Introduction so the claims stay tied to the design.
4. Do not write Discussion until validation gates are passed.

## Minimum Paper-Go Criteria

Proceed to a manuscript draft if at least one holds:

- LLM beats keyword baseline in a theoretically meaningful covariate lane.
- LLM top-k candidates include validated DIF examples.
- LLM failure modes are systematic and instructive enough for a cautionary methods paper.

Stop or downgrade if:

- LLM is uniformly worse than baseline.
- false positives are mostly generic stereotypes.
- no psychometric validation can be completed.

