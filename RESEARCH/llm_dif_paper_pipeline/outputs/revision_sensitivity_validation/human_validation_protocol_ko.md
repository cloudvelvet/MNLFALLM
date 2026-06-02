# Human Validation Protocol

생성일: 2026-05-28

## 목적

LLM 판단근거가 실제 전문가 검토에 사용할 수 있는 DIF 후보 가설인지 확인한다. 이 검증은 empirical DIF 판정의 대체물이 아니라, LLM rationale의 질을 사람이 독립적으로 평가하는 절차다.

## 파일

- 코더용 블라인드 파일: `human_validation_blind_coding_sheet.csv`
- 분석용 key 파일: `human_validation_sample_key.csv`

코더에게는 블라인드 파일만 제공한다. key 파일에는 LLM 점수, keyword 점수, screening label, rule-based code가 포함되어 있으므로 코딩 완료 전에는 제공하지 않는다.

## 표본

총 116개 문항-공변량-지시문 조합을 표집하였다. 표본은 prompt 조건, LLM cutoff 70 기준의 TP/FP/FN/TN, 공변량, 고위험 rationale code가 섞이도록 구성하였다. 따라서 이 표본은 전체 비율 추정보다는 rule-based coding 검증과 사례 검토에 적합하다.

## 코딩 항목

각 코더는 다음 항목을 독립적으로 코딩한다.

| 변수 | 값 | 의미 |
|---|---|---|
| item_content_link_0_2 | 0, 1, 2 | 0=문항과 거의 연결 없음, 1=간접 연결, 2=문항 표현/응답과 직접 연결 |
| same_trait_condition_0_1 | 0, 1 | 동일 잠재특성 수준 조건을 명시하거나 실질적으로 반영했는가 |
| response_process_0_1 | 0, 1 | 이해, 해석, 회상, 판단, 응답 범주 사용 등 응답 과정 근거가 있는가 |
| testable_hypothesis_0_1 | 0, 1 | 후속 ordinal DIF/MNLFA/전문가 검토로 확인 가능한 가설인가 |
| impact_dif_confusion_0_1 | 0, 1 | 실제 잠재특성 차이나 일반 위험요인을 DIF 근거처럼 설명했는가 |
| stereotype_or_vague_0_1 | 0, 1 | 성별/연령 고정관념 또는 모호한 일반론에 의존하는가 |
| overall_plausibility_0_2 | 0, 1, 2 | 0=부적절, 1=검토 가능하나 약함, 2=우선 검토할 가치 있음 |

## 분석 계획

코딩 완료 후 다음을 계산한다.

1. 각 항목의 코더 간 일치도: Cohen's kappa 또는 weighted kappa.
2. rule-based code 대비 사람 코딩의 precision, recall, F1.
3. LLM 점수와 human plausibility 간 Spearman 상관.
4. Screening-positive 여부와 human plausibility 간 관계.
5. FP70와 FN70 사례에서 사람이 본 오류 유형 요약.

## 논문 보고 문장 초안

LLM 판단근거의 규칙 기반 코딩 결과를 검토하기 위해 prompt 조건, outcome 유형, 공변량, 고위험 코드가 층화되도록 116개 문항-공변량-지시문 조합을 표집하였다. 두 명의 코더는 empirical screening label과 LLM 점수를 보지 않은 상태에서 문항 내용 연결성, 같은 잠재특성 조건 명시, 응답 과정 근거, 검증 가능성, impact-DIF 혼동, 고정관념 또는 모호한 일반론 여부를 독립적으로 코딩하였다. 코딩 완료 후 범주별 일치도와 rule-based coding의 precision/recall을 산출하였다.
