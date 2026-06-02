# 30문항 pilot 결과 정리 및 LLM rationale 코드북

이 문서는 MAPS LLM-DIF pilot의 1-4번 산출물을 묶은 작업 초안이다. 분석 단위는 문항-공변량 조합이며, LLM 산출물은 DIF 판정이 아니라 blind 상태에서 생성된 후보 가설로 해석한다.

## 1. 30문항 결과표 정리

30문항 pilot에서 총 137개 문항-공변량 조합이 생성되었고, provisional ordinal DIF screening 기준에서 45개 조합이 DIF positive로 분류되었다. `pilot_006 x gender`는 부모 문항에 성별 공변량이 적용되지 않아 empirical label과 keyword score가 비어 있었으며, threshold confusion table에서는 제외하였다.

| 구분 | n pairs | DIF+ | 평균 LLM 점수 | LLM AP | LLM P@5 | LLM P@10 | Keyword AP | Keyword P@5 | Keyword P@10 | 해석 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| 전체 | 137 | 45 | 41.68 | .534 | .600 | .700 | .469 | .600 | .700 | 전체 ranking은 LLM이 다소 우세하나 top-k는 동일 |
| age_c | 30 | 6 | 39.33 | .162 | .000 | .100 | .306 | .200 | .100 | 연령 관련 ranking은 약함 |
| discrim_any | 30 | 20 | 64.17 | .678 | .600 | .700 | .737 | .600 | .700 | 표면 단서가 강해 keyword가 더 강함 |
| gender | 17 | 5 | 31.18 | .362 | .400 | .300 | .283 | .200 | .200 | LLM이 약간 높지만 pair 수가 적음 |
| income_c | 30 | 1 | 21.17 | .033 | .000 | .000 | .500 | .200 | .100 | positive가 1개뿐이라 해석 제한 |
| korean_c | 30 | 13 | 48.00 | .691 | .800 | .600 | .347 | .000 | .300 | LLM의 가장 설득력 있는 강점 |

결과 해석의 핵심은 LLM의 전반적 우위가 아니라 공변량별 이질성이다. 한국어 능력처럼 문항 이해, 문화적 맥락, 응답 과정이 개입되는 공변량에서는 LLM이 keyword baseline보다 뚜렷하게 높은 AP를 보였다. 반대로 차별 경험처럼 문항에 직접적인 표면 단서가 많은 공변량에서는 keyword baseline이 더 높은 성능을 보였다.

### Threshold 보조 분석

| LLM score 기준 | TP | FP | FN | TN | Precision | Recall | Specificity | F1 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| >= 50 | 30 | 41 | 15 | 50 | .423 | .667 | .549 | .517 |
| >= 70 | 20 | 14 | 25 | 77 | .588 | .444 | .846 | .506 |

점수 70 이상을 후보 기준으로 쓰면 specificity는 비교적 높지만 recall은 낮다. 따라서 LLM은 모든 DIF 후보를 포괄적으로 찾는 detector라기보다, 연구자가 먼저 검토할 후보를 좁히는 triage 장치로 보는 것이 적절하다.

### LLM 점수 구간별 DIF positive 비율

| LLM score bin | valid n | DIF+ | DIF+ rate |
|---|---:|---:|---:|
| 0-19 | 51 | 12 | .235 |
| 20-39 | 10 | 1 | .100 |
| 40-59 | 20 | 5 | .250 |
| 60-79 | 34 | 14 | .412 |
| 80-100 | 21 | 13 | .619 |

점수 구간이 높아질수록 DIF positive 비율이 증가하는 경향은 있다. 다만 낮은 점수 구간에도 empirical positive가 남아 있으므로, LLM 저점이 곧 DIF 없음으로 해석되어서는 안 된다.

## 2. 상위 10개 LLM 후보

원자료 CSV: `pilot30_top10_llm_candidates.csv`

| rank | custom_id | scale | covariate | LLM score | DIF label | Keyword score | expected direction | 해석 |
|---:|---|---|---|---:|---|---:|---|---|
| 1 | pilot_027 | parent_acculturation | korean_c | 95 | TRUE | 65 | negative | 한국어 능력 관련 high-confidence TP |
| 2 | pilot_002 | parent_acculturative_stress | discrim_any | 90 | TRUE | 70 | positive | 차별 경험 관련 TP |
| 3 | pilot_007 | parent_acculturative_stress | discrim_any | 90 | FALSE | 70 | positive | 표면 단서 기반 FP |
| 4 | pilot_008 | parent_acculturative_stress | discrim_any | 90 | FALSE | 70 | positive | 표면 단서 기반 FP |
| 5 | pilot_009 | youth_acculturative_stress | discrim_any | 90 | TRUE | 70 | positive | 차별 경험 관련 TP |
| 6 | pilot_012 | youth_acculturative_stress | korean_c | 90 | TRUE | 65 | negative | 한국어 능력 관련 TP |
| 7 | pilot_016 | youth_acculturative_stress | discrim_any | 90 | TRUE | 70 | positive | 차별 경험 관련 TP |
| 8 | pilot_017 | youth_acculturative_stress | discrim_any | 90 | TRUE | 70 | positive | 차별 경험 관련 TP |
| 9 | pilot_026 | parent_acculturation | korean_c | 90 | TRUE | 65 | positive | 한국어 능력 관련 TP |
| 10 | pilot_028 | youth_worry | income_c | 90 | FALSE | 15 | negative | 소득-진로 걱정 연결을 과대평가한 FP |

상위 10개 중 7개가 provisional DIF positive였다. 그러나 3개 false positive가 모두 해석적으로 흥미로운 사례이므로, 결과 파트에서는 top-k 성능뿐 아니라 왜 LLM이 과대평가했는지를 사례로 제시하는 것이 좋다.

## 3. False positive / false negative 사례

원자료 CSV:

- `pilot30_false_positive_examples.csv`
- `pilot30_false_negative_examples.csv`

### 추천 false positive 사례

| 사례 | LLM score | DIF label | 해석 포인트 |
|---|---:|---|---|
| pilot_007 x discrim_any | 90 | FALSE | 문항 내용상 차별 경험과 잘 연결되지만 empirical screening에서는 지지되지 않음 |
| pilot_008 x discrim_any | 90 | FALSE | 차별/사회적 지위 관련 표면 단서가 LLM과 keyword 모두를 끌어올린 사례 |
| pilot_028 x income_c | 90 | FALSE | 소득 자원 논리를 worry 문항에 과대 적용한 사례 |
| pilot_028 x korean_c | 80 | FALSE | 한국어 능력과 진로 걱정의 실제 관련성을 threshold DIF처럼 해석한 사례 |
| pilot_009 x age_c | 75 | FALSE | 발달 단계 설명이 문항 기능 차이로 이어지지 않은 사례 |

### 추천 false negative 사례

| 사례 | LLM score | DIF label | 해석 포인트 |
|---|---:|---|---|
| pilot_012 x discrim_any | 0 | TRUE | LLM이 언어능력 스트레스를 차별 경험과 분리했지만 empirical DIF가 나타난 사례 |
| pilot_010 x gender | 5 | TRUE | 명시적 gender wording이 없어도 empirical gender DIF가 나타난 사례 |
| pilot_023 x age_c | 5 | TRUE | 이중문화수용 문항에서 연령 관련 DIF 가능성을 LLM이 놓친 사례 |
| pilot_025 x korean_c | 5 | TRUE | 문항이 단순하다는 이유로 한국어 능력 관련 DIF를 과소평가한 사례 |
| pilot_029 x income_c | 5 | TRUE | 가구 경제상황 걱정 문항에서 소득 관련 DIF를 impact로만 처리했을 가능성 |

이 사례 분석은 LLM의 성공보다 실패 조건을 보여주는 데 중요하다. 특히 false positive는 LLM이 그럴듯한 사회심리적 설명을 DIF 메커니즘으로 과잉 확장하는 위험을 보여주고, false negative는 표면적으로 단순해 보이는 문항에서도 empirical DIF가 나타날 수 있음을 보여준다.

## 4. LLM rationale 질적 코딩 코드북

### 코딩 단위와 원칙

코딩 단위는 LLM rationale 안에서 독립적인 설명 또는 가설을 구성하는 의미 단위로 둔다. 하나의 rationale에는 복수 코드를 부여할 수 있다. 유용 코드와 실패 코드는 동시에 부여될 수 있다. 예를 들어 문항 표현을 잘 짚었지만 방향성을 근거 없이 단정한 경우 `WORDING`과 `DIRECTION_UNSUPPORTED`를 함께 부여한다.

핵심 판단 기준은 다음과 같다.

- 집단 평균 차이 또는 경험 차이는 그 자체로 DIF 근거가 아니다.
- DIF 가설이 되려면 동일 잠재특성 수준에서 특정 문항의 threshold 또는 응답 범주 사용이 달라질 수 있는 경로가 제시되어야 한다.
- 문항 텍스트, 응답 과정, 문화·언어 맥락, 공변량 특이 메커니즘 중 적어도 하나와 연결되어야 한다.
- LLM rationale은 증거가 아니라 후속 검토를 위한 가설이다.

### 유용 rationale 코드

| 코드 | 정의 | 포함 기준 | 제외 기준 |
|---|---|---|---|
| WORDING | 문항의 단어, 표현, 문장 구조, 모호성이 응답자 집단별 해석 차이를 만들 수 있다고 설명 | 특정 어휘, 구문, 표현 난도, 번역 가능성을 지적 | 단순히 "문항이 어렵다"라고만 말함 |
| RESPONSE_PROCESS | 이해, 회상, 판단, 사회적 바람직성, 응답 범주 선택 과정의 차이를 설명 | 응답자가 같은 trait 수준에서도 다르게 반응할 수 있는 과정을 제시 | 단순 경험 차이나 평균 차이만 설명 |
| CULTURE_LANGUAGE_CONTEXT | 문화 규범, 언어 능력, 관용 표현, 문화적 친숙성이 문항 해석에 영향을 줄 수 있다고 설명 | 문화·언어 맥락과 문항 의미를 구체적으로 연결 | 문화 차이를 일반론으로만 제시 |
| COVARIATE_MECHANISM | 특정 공변량이 문항 반응에 작동할 수 있는 경로를 설명 | 한국어 능력, 차별 경험, 소득, 성별, 연령 등과 문항 내용을 연결 | 집단 고정관념만 제시 |
| CONSTRUCT_RELEVANCE | impact와 DIF, construct-relevant 차이와 construct-irrelevant 차이를 구분 | 실제 잠재특성 차이와 문항 기능 차이를 구분하려고 함 | 모든 집단 차이를 DIF로 처리 |
| DIRECTIONAL_HYPOTHESIS | 어느 방향의 threshold 차이가 예상되는지 제시 | expected direction과 그 이유가 함께 제시됨 | 방향만 있고 근거가 없음 |
| TESTABLE_HYPOTHESIS | 후속 분석이나 전문가 검토로 확인 가능한 형태의 가설 제시 | subgroup, expected direction, mechanism이 검토 가능함 | 막연한 가능성만 말함 |
| ALTERNATIVE_EXPLANATION | DIF가 아니라 impact일 가능성 등 대안 설명을 인식 | competing explanation을 명시 | LLM 설명을 단정적으로만 제시 |

### 실패 rationale 코드

| 코드 | 정의 | 포함 기준 | 예시적 위험 |
|---|---|---|---|
| IMPACT_DIF_CONFUSION | 실제 집단 차이 또는 경험 차이를 곧 DIF로 해석 | "이 집단이 더 스트레스를 받으므로 DIF" 식 설명 | 잠재특성 차이와 문항 기능 차이 혼동 |
| NO_WITHIN_TRAIT_CONDITIONING | 동일 잠재특성 수준 조건을 고려하지 않음 | 집단별 평균 차이만 설명 | DIF의 핵심 조건 누락 |
| STEREOTYPE_GENDER_AGE | 성별·연령에 대한 고정관념적 설명 | "여학생은 관계에 민감", "나이가 많으면 걱정이 많음" 식 일반론 | 사회적 통념 재생산 |
| VAGUE_GENERALITY | 구체적 문항 근거 없는 모호한 설명 | "문화 차이 때문에 편향될 수 있음" | 검증 불가능 |
| ITEM_IRRELEVANT_SPECULATION | 문항 내용과 직접 연결되지 않는 추측 | 문항에 없는 가족, 경제, 학교 맥락을 끌어옴 | 설명은 그럴듯하지만 문항 근거 없음 |
| DIRECTION_UNSUPPORTED | 방향성은 말하지만 근거가 약함 | expected direction과 rationale이 연결되지 않음 | 방향 해석 불안정 |
| HALLUCINATED_ITEM_CONTENT | 실제 문항에 없는 단어, 상황, 응답 범주를 근거로 삼음 | 문항에 없는 내용을 설명의 핵심으로 사용 | 치명적 오류 코드 |
| OVERCLAIM_DIF | 후보 가설을 확정적 DIF 판정처럼 서술 | "명백한 DIF", "반드시 편향" | LLM 역할 과장 |
| CONSTRUCT_CONFUSION | 측정하려는 구인을 다른 구인으로 혼동 | 자아존중감 문항을 성실성, 지능 등으로 해석 | 구인타당도 훼손 |
| UNFAIR_ATTRIBUTION | 특정 집단의 결함이나 열등성으로 설명 | "이 집단은 이해력이 낮다" 식 표현 | 낙인적·비윤리적 해석 |

### 방법 파트 서술 초안

본 연구는 LLM이 생성한 DIF 후보 rationale의 심리측정적 유용성과 오류 양상을 평가하기 위해 질적 코드북을 구성하였다. 코딩 단위는 LLM 응답 내에서 독립적인 설명 또는 가설을 구성하는 의미 단위로 정의하였고, 하나의 단위에 복수의 코드를 부여할 수 있도록 하였다. 유용 rationale 코드는 문항 표현, 응답 과정, 문화·언어 맥락, 공변량 특이 메커니즘, 구성개념 관련성, 방향성 있는 가설, 검증 가능성, 대안 설명 인식 등을 포함하였다. 실패 rationale 코드는 impact와 DIF의 혼동, 동일 잠재특성 수준 조건의 누락, 성별·연령 고정관념, 모호한 일반론, 문항 무관 추측, 근거 없는 방향성, 환각된 문항 내용, DIF 과잉 단정, 구성개념 혼동, 낙인적 귀인을 포함하였다.

코더는 각 rationale이 단순한 집단 평균 차이를 설명하는지, 아니면 동일한 잠재특성 수준에서 특정 문항에 대한 반응 확률이 공변량에 따라 달라질 수 있는지를 중심으로 판단하였다. 특히 DIF 가설로 간주되기 위해서는 문항 내용과 연결된 구체적 메커니즘, 후속 검증 가능한 비교 조건, 가능할 경우 예상 방향성이 제시되어야 한다고 보았다. 반대로 문항 텍스트에 근거하지 않은 추측, 사회적 고정관념에 기반한 설명, 또는 실제 construct 차이를 문항 기능 차이로 오인한 설명은 실패 유형으로 코딩하였다.

## 결과 파트 문장 초안

30문항 pilot의 137개 문항-공변량 조합 중 provisional ordinal DIF screening 기준에서 45개 조합이 DIF 양성으로 분류되었다. LLM 점수에 따른 ranking 성능은 전체 AP = .534로 keyword baseline의 AP = .469보다 높았으며, 상위 5개 및 10개 후보의 precision은 각각 .600과 .700이었다. 그러나 상위 후보 precision은 keyword baseline과 동일하여, LLM의 장점은 최상위 후보 몇 개를 선별하는 성능보다 전체 후보 공간을 정렬하는 데서 제한적으로 나타났다. 공변량별로는 한국어 능력에서 LLM의 AP가 .691로 keyword baseline의 .347보다 크게 높았던 반면, 차별 경험에서는 keyword baseline이 .737로 LLM의 .678보다 높았다. 이는 LLM의 추가 가치가 표면 단서가 약하고 문항 이해 및 문화·언어적 맥락이 필요한 공변량에서 더 잘 나타나는 반면, 표면 어휘 단서가 강한 공변량에서는 단순 keyword 접근도 충분히 경쟁력 있음을 시사한다.

## 논의 파트 연결 문장

이 결과는 LLM을 DIF detector로 해석하기보다 psychometric triage layer로 해석해야 함을 보여준다. LLM은 일부 문항-공변량 조합에서 경험적 DIF 후보를 더 높은 순위에 배치했지만, 고점 false positive와 저점 false negative가 모두 존재하였다. 따라서 LLM rationale은 심리측정 근거가 아니라 후속 ordinal DIF 분석, 전문가 검토, 필요시 MNLFA-style validation에서 검증할 후보 가설로 제한되어야 한다.
