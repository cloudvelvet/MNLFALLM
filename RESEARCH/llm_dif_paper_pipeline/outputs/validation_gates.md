# 검증 게이트와 가드레일

## Gate 1. Leakage Audit

통과 조건:

- generation prompt에 DIF 통계량, empirical label, prior flagged item ID, expert rationale, model result가 포함되지 않는다.

실패 조건:

- LLM이 직접 또는 간접적으로 정답지를 본다.

## Gate 2. Reproducibility Audit

통과 조건:

- prompt template, model name/version, parameter, batch file, timestamp, raw response가 저장되어 있다.

권장 최소 조건:

- item subset을 최소 2회 반복하거나 2개 이상의 prompt variant를 실행한다.

## Gate 3. Comparator Fairness Audit

통과 조건:

- keyword, LLM, human expert 비교가 모두 동일하게 정의된 item-covariate 단위를 사용한다.

human expert를 비교군으로 넣는 경우:

- 동일한 item text.
- 동일한 covariate definition.
- empirical DIF result 미제공.
- time/attempt budget 고정.

## Gate 4. Negative-Control Audit

통과 조건:

- shuffled covariate label 또는 null/simulated item이 허용 불가능한 수준의 high DIF probability를 받지 않는다.

목적:

- generic storytelling과 subgroup stereotyping을 탐지한다.

## Gate 5. Psychometric Validation

통과 조건:

- 최소한 focal top-ranked candidate는 preregistered ordinal DIF/MNLFA-style model로 검증한다.

claim strength:

- MNLFA/formal validation 전: "candidate hypotheses only."
- validation 후: "LLM-prioritized hypotheses showed partial empirical support."
- 절대 금지: "LLM proved DIF cause."

## Gate 6. Incremental Utility

통과 조건:

- LLM이 최소 하나의 지표 또는 이론적으로 의미 있는 covariate lane에서 keyword baseline을 넘어서는 가치를 보인다.

권장 지표:

- AUPRC / Average Precision.
- Precision@5.
- Precision@10.
- graded label이 있으면 NDCG@k.

## Gate 7. Failure-Mode Audit

논문에 들어가는 false positive와 false negative 사례는 다음 유형으로 코딩한다.

- latent difference confusion.
- construct-relevant content confusion.
- wording artifact overcall.
- stereotype/generic rationale.
- missed nonsemantic empirical DIF.
- plausible semantic DIF candidate.

## Gate 8. Claim-Faithfulness Audit

Abstract/Discussion 작성 전, 모든 주요 주장을 다음 표에 맞춰 점검한다.

| 주장 유형 | 허용되는 근거 |
|---|---|
| LLM이 hypothesis를 생성했다 | prompt output과 parsed result |
| LLM이 유용한 candidate를 prioritization했다 | ranking metric과 top-k validation |
| DIF가 존재한다 | empirical DIF/MNLFA model |
| mechanism이 causal하다 | 이 설계에서는 허용 안 됨 |
| item이 biased/unfair하다 | 별도의 substantive fairness review 없이는 허용 안 됨 |

## 금지 표현

- detects DIF
- proves DIF
- identifies biased items
- reveals the cause
- replaces expert review
- validates fairness

## 권장 표현

- generates candidate DIF hypotheses
- prioritizes item-covariate pairs
- provides semantically plausible rationales
- requires psychometric validation
- shows partial alignment with empirical DIF evidence
- exhibits failure modes requiring guardrails

