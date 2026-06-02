# API 없이 수행한 pilot 보강 분석 요약

이 문서는 30문항 Gemini pilot 결과에 대해 추가로 수행한 API-free 보강 분석을 정리한다. 분석에는 bootstrap confidence interval, paired permutation test, threshold metric, rule-based rationale coding, TF-IDF lexical similarity baseline을 포함하였다. 모든 분석은 기존 결과 파일을 사용했으며, 새로운 LLM API 호출은 수행하지 않았다.

## 1. 분석 범위

- LLM output: 30문항, 137개 문항-공변량 조합
- Robustness metric에서 사용한 valid pairs: 136개
- 제외/비적용 row: `pilot_006 x gender`는 부모 문항에 성별 공변량이 적용되지 않아 empirical label과 keyword score가 비어 있었음
- Provisional DIF positive: 45개

## 2. Bootstrap CI와 permutation test

Bootstrap은 `custom_id`를 cluster 단위로 하여 2,000회 반복하였다. Permutation test는 같은 문항-공변량 조합 안에서 LLM score와 keyword score를 무작위 교환하는 paired permutation 방식으로 5,000회 수행하였다.

| group | LLM AP | Keyword AP | AP diff | Bootstrap 95% CI for diff | permutation p, two-sided | 해석 |
|---|---:|---:|---:|---:|---:|---|
| overall | .534 | .469 | .065 | [-.069, .163] | .386 | 전체적으로 LLM 우위 방향이나 불확실 |
| age_c | .162 | .306 | -.144 | [-.614, .044] | .061 | keyword 우위 경향, 단 pilot에서는 불확실 |
| discrim_any | .678 | .737 | -.059 | [-.123, .098] | .584 | keyword가 높지만 차이는 안정적이지 않음 |
| gender | .362 | .283 | .079 | [-.140, .399] | .699 | LLM 우위 방향이나 표본 작음 |
| income_c | .033 | .500 | -.467 | [-.967, -.300] | .131 | positive 1개라 성능 비교 해석 제한 |
| korean_c | .691 | .347 | .344 | [.015, .490] | .017 | LLM 우위가 가장 안정적으로 나타남 |

핵심은 전체 평균보다 공변량별 패턴이다. 전체 AP 차이는 LLM이 keyword보다 높았지만 bootstrap CI가 0을 포함하고 permutation test에서도 유의하지 않았다. 반면 한국어 능력 공변량에서는 LLM과 keyword의 AP 차이가 비교적 안정적으로 나타났다. 따라서 논문에서는 "LLM이 전반적으로 keyword보다 우수하다"보다 "한국어 능력처럼 언어·문화적 의미 연결이 필요한 공변량에서 LLM의 추가 가치가 나타났다"라고 쓰는 것이 안전하다.

## 3. Threshold metric

| LLM score 기준 | TP | FP | FN | TN | Precision | Recall | Specificity | F1 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| >= 50 | 30 | 41 | 15 | 50 | .423 | .667 | .549 | .517 |
| >= 70 | 20 | 14 | 25 | 77 | .588 | .444 | .846 | .506 |

점수 50 이상은 recall-oriented 기준이고, 점수 70 이상은 specificity-oriented 기준에 가깝다. 점수 70 기준에서 specificity는 .846으로 높지만 recall은 .444에 그쳤다. 이는 LLM이 empirical DIF screening을 대체하기보다 high-priority 후보를 줄이는 triage 도구에 더 적합함을 보여준다.

## 4. TF-IDF lexical similarity baseline

추가 baseline으로 item metadata와 covariate definition 사이의 TF-IDF cosine similarity를 계산하였다. 이 baseline은 LLM output이나 empirical label을 사용하지 않으며, keyword baseline보다 덜 수작업적인 lexical/metadata 기준선으로 사용하였다.

| group | LLM AP | Keyword AP | Lexical TF-IDF AP | 해석 |
|---|---:|---:|---:|---|
| overall | .534 | .469 | .265 | lexical baseline은 약함 |
| age_c | .162 | .306 | .175 | 모두 약함 |
| discrim_any | .678 | .737 | .573 | keyword가 가장 강함 |
| gender | .362 | .283 | .277 | LLM이 약간 높음 |
| income_c | .033 | .500 | .050 | positive 1개라 해석 제한 |
| korean_c | .691 | .347 | .403 | LLM이 두 baseline보다 높음 |

이 결과는 단순한 lexical metadata similarity만으로는 provisional DIF 후보를 충분히 정렬하기 어렵다는 점을 보여준다. 특히 한국어 능력에서 LLM은 keyword baseline과 lexical TF-IDF baseline을 모두 상회하였다.

## 5. Rationale coding 1차 자동 적용

코드북을 바탕으로 rule-based 1차 코딩을 수행하였다. 이 결과는 formal human coding이 아니라, rationale 유형을 빠르게 탐색하기 위한 예비 분류다. 따라서 논문에 넣을 때는 "automatic first-pass coding" 또는 "pilot coding"으로 제한해야 한다.

| code | overall flagged / n | rate | 해석 |
|---|---:|---:|---|
| RESPONSE_PROCESS | 115 / 136 | .846 | 대부분의 rationale이 해석, endorsement, threshold, response process 어휘를 포함 |
| TESTABLE_HYPOTHESIS | 109 / 136 | .801 | 상당수가 same latent 또는 threshold/differential 표현을 포함 |
| CONSTRUCT_RELEVANCE | 88 / 136 | .647 | latent/construct/true level 구분이 자주 등장 |
| CULTURE_LANGUAGE_CONTEXT | 68 / 136 | .500 | 문화·언어 맥락 설명이 절반 정도에서 등장 |
| WORDING | 48 / 136 | .353 | 문항 표현 또는 wording 직접 언급은 약 35% |
| NO_WITHIN_TRAIT_CONDITIONING | 31 / 136 | .228 | 동일 잠재수준 조건이 명시되지 않은 high-score rationale이 일부 존재 |
| STEREOTYPE_GENDER_AGE | 19 / 136 | .140 | 성별·연령 관련 일반론 가능성 |
| DIRECTION_UNSUPPORTED | 14 / 136 | .103 | 방향은 제시했지만 방향 근거가 약한 사례 |
| VAGUE_GENERALITY | 12 / 136 | .088 | 모호한 일반론 |
| IMPACT_DIF_CONFUSION | 2 / 136 | .015 | 자동 규칙 기준으로는 낮게 탐지됨. human coding 필요 |

이 자동 코딩 결과만으로 LLM rationale의 타당성을 판정해서는 안 된다. 특히 `IMPACT_DIF_CONFUSION`, `HALLUCINATED_ITEM_CONTENT`, `CONSTRUCT_CONFUSION`은 rule-based 탐지로 과소포착될 수 있으므로, 최종 논문에서는 human expert coding 또는 최소한 manual audit가 필요하다.

## 6. 논문에서 쓸 수 있는 핵심 문장

30문항 pilot의 robustness 분석은 LLM의 우위가 전체적으로 강하게 확정되는 수준은 아니지만, 공변량별로 의미 있는 차이를 보였다. 전체 AP는 LLM이 keyword baseline보다 높았으나(AP = .534 vs .469), cluster bootstrap 95% CI는 0을 포함하였고 paired permutation test도 유의하지 않았다. 반면 한국어 능력 공변량에서는 LLM의 AP가 keyword baseline보다 크게 높았으며(.691 vs .347), bootstrap CI와 permutation test에서도 비교적 안정적인 차이가 확인되었다. 이는 LLM의 추가 가치가 모든 문항-공변량 조합에서 보편적으로 나타난다기보다, 문항 이해, 응답 과정, 문화·언어적 맥락이 개입되는 공변량에서 더 분명하게 나타날 수 있음을 시사한다.

또한 score threshold 분석에서 LLM score 70 이상 기준은 높은 specificity(.846)를 보였지만 recall(.444)은 제한적이었다. 따라서 LLM은 empirical DIF screening을 대체하는 detector라기보다, 후속 전문가 검토와 MNLFA-style validation의 우선순위를 정하는 psychometric triage 도구로 해석하는 것이 적절하다.

## 7. 산출 파일

- `maps_llm_pilot_extensions.R`
- `llm_dif_output/maps_llm_pilot_bootstrap_ci.csv`
- `llm_dif_output/maps_llm_pilot_permutation_tests.csv`
- `llm_dif_output/maps_llm_pilot_threshold_metrics.csv`
- `llm_dif_output/maps_llm_pilot_rationale_code_flags.csv`
- `llm_dif_output/maps_llm_pilot_rationale_code_summary.csv`
- `llm_dif_output/maps_llm_pilot_lexical_baseline_predictions.csv`
- `llm_dif_output/maps_llm_pilot_extended_baseline_metrics.csv`
