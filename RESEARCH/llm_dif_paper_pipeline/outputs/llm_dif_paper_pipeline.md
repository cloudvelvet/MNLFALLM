# 학술논문 파이프라인: LLM 보조 DIF 가설 생성

## 작업 제목

**다문화 패널 문항에서 LLM 보조 DIF 가설 생성: MAPS 자료를 활용한 심리측정적 검증 파이프라인**

영문 제목 후보:

1. LLM-Assisted Hypothesis Generation for Differential Item Functioning in Multicultural Panel Data
2. Using Large Language Models to Generate Explanatory DIF Hypotheses: A Pilot Study with the MAPS Multicultural Panel
3. From Textual Cues to Psychometric Validation: LLM-Assisted DIF Hypothesis Generation in Multicultural Assessment
4. Can LLMs Help Explain Potential DIF? A Pilot Framework Combining Gemini, Keyword Baselines, and Ordinal DIF Models

## 중심 논지

이 논문은 LLM이 DIF를 탐지한다고 주장하지 않는다. 이 논문은 LLM이 문항 텍스트와 covariate 맥락을 바탕으로 해석 가능한 DIF 후보 가설을 생성하고, 그 후보들이 후속 심리측정 검증의 우선순위를 정하는 데 도움이 되는지를 평가한다.

## 선행연구 포지셔닝

이미 직접적인 선행연구가 있으므로 "LLM을 DIF에 처음 적용했다"는 주장은 하지 않는다.

가장 가까운 선행연구:

- Li, Marchong, & Aldib (2024), *The Use of ChatGPT to Facilitate Differential Item Functioning (DIF) Detection*. ChatGPT와 인간 평정자의 DIF 판단을 empirical `lordif` 결과와 비교한 work-in-progress 포스터.
- Maeda & Lu (2025), *Finding Words Associated with DIF: Predicting Differential Item Functioning Using LLMs and Explainable AI*. Journal of Educational Measurement. DOI: https://doi.org/10.1111/jedm.70017

안전한 novelty claim:

> 최근 연구들은 LLM 또는 Transformer 모형을 DIF 예측이나 문항 검토에 사용하기 시작했다. 그러나 LLM이 생성한 item-covariate rationale을 longitudinal, covariate-rich, ordinal DIF/MNLFA-style validation과 연결하는 해석 가능하고 이론 기반적인 가설 생성 workflow는 아직 충분히 개발되지 않았다.

## 연구질문

RQ1. LLM은 MAPS item-covariate pair에 대해 의미적으로 그럴듯한 DIF 후보 가설을 생성할 수 있는가?

RQ2. LLM은 후속 DIF 검증 대상의 우선순위를 정할 때 keyword baseline을 넘어서는 정보를 제공하는가?

RQ3. LLM의 유용성은 covariate 유형, 특히 차별경험, 한국어 능력, 소득, 연령, 성별에 따라 달라지는가?

RQ4. LLM은 어디서 실패하는가? 특히 latent trait difference와 measurement-function difference를 어떻게 혼동하는가?

RQ5. 이 workflow는 LLM을 DIF 판정기로 과장하지 않으면서 전문가 검토의 우선순위 설정을 보조할 수 있는가?

## 1단계. 연구 단위 동결과 leakage audit

목적: 전체 LLM 실행 전에 분석 단위, label 규칙, prompt 경계를 고정한다.

입력:

- MAPS 문항 텍스트와 covariate catalog
- `maps_llm_item_catalog_filled.csv`
- `maps_llm_full_item_covariate_pairs.csv`
- provisional DIF screening 규칙
- prompt template

산출물:

- `gold-standard-spec.md`
- `pair-registry.csv`
- `decision-rule-table.csv`
- `prompt-leakage-audit.md`

검증 게이트:

- 모든 item-covariate pair가 안정적인 ID를 가진다.
- LLM 생성 prompt 안에 empirical DIF label, 통계량, 사전 flagged item ID, 전문가 rationale이 포함되지 않는다.
- DIF label을 `screen-positive`, `validation-positive`, `indeterminate`로 분리한다.

Stop/Go:

- Go: pair registry와 leakage audit이 통과됨.
- Stop: prompt 입력에 outcome 정보가 포함됨.

## 2단계. 데이터, 문항 텍스트, baseline 준비

목적: LLM이 아닌 비교조건을 재현 가능하게 만든다.

입력:

- MAPS long analytic file
- item text
- covariate definition

산출물:

- item catalog
- pair catalog
- keyword baseline predictions
- 가능한 경우 lexical baseline predictions
- baseline design note

주요 baseline:

- keyword/covariate semantic marker score

선택 baseline:

- 문항 길이
- lexical diversity
- covariate-specific vocabulary flag

검증 게이트:

- 누락 item text 비율 0%.
- 모든 item-covariate pair에 baseline score가 있음.
- baseline script가 처음부터 재실행 가능함.

## 3단계. LLM 후보 가설 생성

목적: empirical DIF 결과를 보지 않은 상태에서 구조화된 DIF 후보 가설을 생성한다.

item-covariate pair별 출력:

- threshold DIF probability
- expected direction
- confidence
- rationale
- parse status

필수 artifact:

- raw response JSONL
- parsed predictions CSV
- prompt manifest
- run log
- model/version/temperature settings

검증 게이트:

- parse 가능한 response 비율 90% 이상.
- 모든 prediction에 prompt version, model version, pair ID가 연결됨.
- conversation carryover 또는 result-aware prompting 없음.

Stop/Go:

- Go: parsing과 traceability가 통과됨.
- Conditional Go: API 실패가 제한적이고 `-Resume`으로 복구 가능함.
- Stop: prompt drift 또는 output parsing 문제로 pair-level 정렬이 신뢰 불가능함.

## 4단계. 1차 평가: 순위화 유용성

목적: LLM score가 완벽한 분류기인지가 아니라, 후속 검증 대상을 우선순위화하는 데 유용한지 평가한다.

주요 지표:

- Average Precision / AUPRC
- Precision@5와 Precision@10
- graded relevance가 생기면 NDCG@k

보조 지표:

- AUROC
- recall@k
- calibration summary
- covariate-specific error profile

필수 비교:

- LLM vs keyword baseline
- 가능하면 psychometric guardrail prompt vs naive prompt
- covariate-specific results

검증 게이트:

- 전체 지표와 covariate별 지표를 모두 보고한다.
- top-k item-covariate list를 보고한다.
- discrimination, Korean proficiency, income, age, gender를 분리한다.

Stop/Go:

- Go: LLM이 이론적으로 의미 있는 한 개 이상의 lane에서 keyword baseline과 동등하거나 더 낫거나, 실패 양상이 이론적으로 의미 있음.
- Conditional Go: 전체 성능은 약하지만 covariate-specific pattern 또는 failure mode가 cautionary paper로 의미 있음.
- Stop: LLM이 전반적으로 baseline보다 낮고 error pattern도 해석 불가능함.

## 5단계. 심리측정 검증과 failure-mode audit

목적: 의미적으로 그럴듯한 이야기를 실제 measurement evidence와 분리한다.

검증 사다리:

1. provisional ordinal DIF screening
2. screening threshold 주변 sensitivity analysis
3. 선택된 scale/covariate에 대한 formal ordinal DIF/MNLFA-style validation

failure-mode taxonomy:

- latent difference confusion
- construct-relevant content confusion
- wording artifact overcall
- stereotype/generic rationale
- true semantic DIF candidate
- empirical DIF with weak semantic cue

산출물:

- validation joined table
- top candidate casebook
- failure-mode codebook
- false-positive audit

검증 게이트:

- success, false positive, false negative 사례를 모두 제시한다.
- MNLFA/ordinal DIF 결과가 claim strength를 결정한다.
- qualitative rationale만으로 conclusion에 들어가지 않는다.

## 6단계. Robustness와 negative control

목적: 결과가 prompt artifact가 아님을 확인한다.

권장 robustness lane:

- prompt variant
- model family variant
- item/covariate order randomization
- shuffled covariate-label negative control
- 번역을 사용한 경우 original Korean vs translated wording 비교

산출물:

- robustness matrix
- negative-control results
- sensitivity summary

검증 게이트:

- 강한 claim 전 최소 2개 robustness lane 완료.
- negative control에서 과도한 high-confidence hypothesis가 나오지 않음.

## 7단계. 논문화 의사결정

논문 유형:

1. **Positive workflow paper**: LLM이 명확한 incremental ranking utility와 validated example을 보임.
2. **Qualified/mixed evidence paper**: LLM이 일부 covariate lane에서 유용하지만 중요한 failure mode도 보임.
3. **Cautionary paper**: LLM 성능은 약하지만 체계적인 심리측정적 위험을 보여줌.

현재 가장 안전한 프레이밍:

> Qualified/mixed evidence paper.

이유: pilot 결과에서 discrimination/Korean proficiency lane은 어느 정도 신호가 있었지만, age false positive와 latent-vs-DIF confusion도 함께 관찰되었기 때문이다.

## 핵심 표와 그림

Table 1. 선행연구 map: LLM/AI psychometrics, LLM-DIF prediction, item-review automation.

Table 2. MAPS scale, item, covariate, item-covariate pair 수.

Table 3. LLM vs keyword baseline 지표: 전체 및 covariate별.

Table 4. Top-k item-covariate hypothesis와 empirical validation status.

Table 5. Failure-mode taxonomy와 사례.

Figure 1. Workflow diagram: item text -> LLM hypothesis -> baseline comparison -> DIF/MNLFA validation -> expert review.

Figure 2. covariate별 Precision@k / AUPRC 비교.

Figure 3. Case-study panel: validated hypothesis vs plausible false positive vs missed empirical DIF.

## 위험한 주장

피해야 할 표현:

- LLMs detect DIF.
- LLMs identify biased items.
- LLM rationales reveal the true cause of DIF.
- LLMs replace experts.
- high LLM probability means item bias.

사용할 표현:

- LLMs generate candidate DIF hypotheses.
- LLMs prioritize item-covariate pairs for follow-up validation.
- LLM rationales partially align with empirical DIF evidence in selected cases.
- LLM failure modes reveal the need for psychometric guardrails.

